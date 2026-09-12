import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/presentation/bloc/part_form_cubit.dart';
import 'package:apartment_maintenance_frontent/features/parts/presentation/bloc/parts_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PartsPage extends StatelessWidget {
  const PartsPage({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => getIt<PartsListBloc>()..add(const PartsRequested()),
      ),
      BlocProvider(create: (_) => getIt<PartFormCubit>()),
    ],
    child: const _PartsView(),
  );
}

class _PartsView extends StatefulWidget {
  const _PartsView();
  @override
  State<_PartsView> createState() => _PartsViewState();
}

class _PartsViewState extends State<_PartsView> {
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<PartFormCubit, PartFormState>(
    listener: (context, state) {
      if (state.status == PartFormStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Part updated.')));
        context.read<PartsListBloc>().add(const PartsRequested());
      }
      if (state.status == PartFormStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    child: BlocBuilder<PartsListBloc, PartsListState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Parts Inventory',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _open(context, '/parts/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add part'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search parts',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 350), () {
                        if (mounted) {
                          context.read<PartsListBloc>().add(
                            PartsSearchChanged(value),
                          );
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<bool?>(
                    initialValue: state.query.isActive,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: true, child: Text('Active')),
                      DropdownMenuItem(value: false, child: Text('Inactive')),
                    ],
                    onChanged: (v) => context.read<PartsListBloc>().add(
                      PartsStatusChanged(v),
                    ),
                  ),
                ),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<bool?>(
                    initialValue: state.query.lowStock,
                    decoration: const InputDecoration(labelText: 'Stock level'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All stock')),
                      DropdownMenuItem(value: true, child: Text('Low stock')),
                      DropdownMenuItem(value: false, child: Text('In stock')),
                    ],
                    onChanged: (v) => context.read<PartsListBloc>().add(
                      PartsLowStockChanged(v),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () =>
                      context.read<PartsListBloc>().add(const PartsRequested()),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _content(context, state)),
          ],
        ),
      ),
    ),
  );
  Widget _content(BuildContext context, PartsListState state) {
    if (state.result == null &&
        (state.status == PartsListStatus.initial ||
            state.status == PartsListStatus.loading)) {
      return const LoadingView(label: 'Loading parts');
    }
    if (state.status == PartsListStatus.failure && state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () =>
            context.read<PartsListBloc>().add(const PartsRequested()),
      );
    }
    final result = state.result;
    if (result == null || result.items.isEmpty) {
      return const EmptyView(message: 'No parts match the selected filters.');
    }
    return Column(
      children: [
        if (state.status == PartsListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 820
                ? SingleChildScrollView(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Part')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Unit price')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: result.items
                            .map(
                              (part) => DataRow(
                                cells: [
                                  DataCell(Text(part.name)),
                                  DataCell(
                                    Text(
                                      '${part.quantity} / min ${part.minimumStock}',
                                    ),
                                  ),
                                  DataCell(Text(_money(part.unitPrice))),
                                  DataCell(_stockChip(part)),
                                  DataCell(_actions(context, part)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                : ListView(
                    children: result.items
                        .map(
                          (part) => Card(
                            child: ListTile(
                              title: Text(part.name),
                              subtitle: Text(
                                'Stock ${part.quantity} • Minimum ${part.minimumStock} • ${_money(part.unitPrice)}',
                              ),
                              trailing: _actions(context, part),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        PaginationBar(
          page: result.page,
          totalPages: result.totalPages,
          pageSize: result.pageSize,
          onPageChanged: (v) =>
              context.read<PartsListBloc>().add(PartsPageChanged(v)),
          onPageSizeChanged: (v) =>
              context.read<PartsListBloc>().add(PartsPageSizeChanged(v)),
        ),
      ],
    );
  }

  Widget _stockChip(Part part) => Chip(
    label: Text(
      !part.isActive
          ? 'Inactive'
          : part.isLowStock
          ? 'LOW STOCK'
          : 'Active',
    ),
    avatar: Icon(
      part.isLowStock ? Icons.warning_amber : Icons.check_circle_outline,
      size: 18,
    ),
  );
  Widget _actions(BuildContext context, Part part) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Edit',
        onPressed: () => _open(context, '/parts/${part.id}/edit'),
        icon: const Icon(Icons.edit_outlined),
      ),
      IconButton(
        tooltip: 'Set stock',
        onPressed: () => _stock(context, part),
        icon: const Icon(Icons.inventory_2_outlined),
      ),
      IconButton(
        tooltip: part.isActive ? 'Deactivate' : 'Activate',
        onPressed: () =>
            context.read<PartFormCubit>().updateStatus(part.id, !part.isActive),
        icon: Icon(
          part.isActive
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
        ),
      ),
    ],
  );
  Future<void> _open(BuildContext context, String route) async {
    if (await context.push<bool>(route) == true && context.mounted) {
      context.read<PartsListBloc>().add(const PartsRequested());
    }
  }

  Future<void> _stock(BuildContext context, Part part) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _SetStockDialog(part: part),
    );
    if (value != null && context.mounted) {
      await context.read<PartFormCubit>().setStock(part.id, value);
    }
  }

  String _money(double value) => '₹${value.toStringAsFixed(2)}';
}

class _SetStockDialog extends StatefulWidget {
  const _SetStockDialog({required this.part});
  final Part part;
  @override
  State<_SetStockDialog> createState() => _SetStockDialogState();
}

class _SetStockDialogState extends State<_SetStockDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.part.quantity}',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Set ${widget.part.name} stock'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: 'Current quantity'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final parsed = int.tryParse(_controller.text);
          if (parsed != null && parsed >= 0) {
            Navigator.pop(context, parsed);
          }
        },
        child: const Text('Set stock'),
      ),
    ],
  );
}
