import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/residents_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/widgets/resident_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResidentsPage extends StatelessWidget {
  const ResidentsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ResidentsListBloc>()..add(const ResidentsRequested()),
    child: const _ResidentsView(),
  );
}

class _ResidentsView extends StatefulWidget {
  const _ResidentsView();
  @override
  State<_ResidentsView> createState() => _ResidentsViewState();
}

class _ResidentsViewState extends State<_ResidentsView> {
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ResidentsListBloc, ResidentsListState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Residents',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  FilledButton.icon(
                    key: const Key('addResidentButton'),
                    onPressed: () => unawaited(_openCreate(context)),
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Add resident'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      key: const Key('residentsSearch'),
                      decoration: const InputDecoration(
                        labelText: 'Search name or email',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 350),
                          () {
                            if (mounted) {
                              context.read<ResidentsListBloc>().add(
                                ResidentsSearchChanged(value),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  DropdownMenu<bool?>(
                    width: 180,
                    label: const Text('Status'),
                    initialSelection: state.query.isActive,
                    onSelected: (value) => context
                        .read<ResidentsListBloc>()
                        .add(ResidentsActiveChanged(value)),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: null, label: 'All statuses'),
                      DropdownMenuEntry(value: true, label: 'Active'),
                      DropdownMenuEntry(value: false, label: 'Inactive'),
                    ],
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Refresh residents',
                    onPressed: () => context.read<ResidentsListBloc>().add(
                      const ResidentsRequested(),
                    ),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _content(context, state)),
            ],
          ),
        ),
      );

  Widget _content(BuildContext context, ResidentsListState state) {
    if (state.result == null &&
        (state.status == ResidentsListStatus.initial ||
            state.status == ResidentsListStatus.loading)) {
      return const LoadingView(label: 'Loading residents');
    }
    if (state.status == ResidentsListStatus.failure && state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () =>
            context.read<ResidentsListBloc>().add(const ResidentsRequested()),
      );
    }
    if (state.status == ResidentsListStatus.empty ||
        state.result?.items.isEmpty == true) {
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            EmptyView(message: 'No residents match the selected filters.'),
          ],
        ),
      );
    }
    final result = state.result!;
    return Column(
      children: [
        if (state.status == ResidentsListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 850
                  ? _ResidentTable(
                      residents: result.items,
                      onOpen: (id) => unawaited(_openDetails(context, id)),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: result.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _ResidentListCard(
                        resident: result.items[index],
                        onTap: () => unawaited(
                          _openDetails(context, result.items[index].id),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: PaginationBar(
            page: result.page,
            totalPages: result.totalPages,
            pageSize: result.pageSize,
            onPageChanged: (page) => context.read<ResidentsListBloc>().add(
              ResidentsPageChanged(page),
            ),
            onPageSizeChanged: (size) => context.read<ResidentsListBloc>().add(
              ResidentsPageSizeChanged(size),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<ResidentsListBloc>().add(const ResidentsRequested());
    await context.read<ResidentsListBloc>().stream.firstWhere(
      (state) => state.status != ResidentsListStatus.loading,
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/residents/new');
    if (created == true && context.mounted) {
      context.read<ResidentsListBloc>().add(const ResidentsRequested());
    }
  }

  Future<void> _openDetails(BuildContext context, String id) async {
    await context.push<void>('/residents/$id');
    if (context.mounted) {
      context.read<ResidentsListBloc>().add(const ResidentsRequested());
    }
  }
}

class _ResidentTable extends StatelessWidget {
  const _ResidentTable({required this.residents, required this.onOpen});
  final List<Resident> residents;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Apartment')),
            DataColumn(label: Text('Move-in')),
            DataColumn(label: Text('Status')),
          ],
          rows: residents
              .map(
                (resident) => DataRow(
                  onSelectChanged: (_) => onOpen(resident.id),
                  cells: [
                    DataCell(Text(resident.user.name)),
                    DataCell(Text(resident.user.email)),
                    DataCell(Text(resident.phone)),
                    DataCell(
                      Text(
                        '${resident.apartment.block}-${resident.apartment.unitNumber}',
                      ),
                    ),
                    DataCell(Text(formatResidentDate(resident.moveInDate))),
                    DataCell(
                      Chip(
                        label: Text(resident.isActive ? 'Active' : 'Inactive'),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

class _ResidentListCard extends StatelessWidget {
  const _ResidentListCard({required this.resident, required this.onTap});
  final Resident resident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(resident.user.name),
      subtitle: Text(
        '${resident.user.email}\n'
        '${resident.apartment.block}-${resident.apartment.unitNumber} • '
        '${resident.phone}',
      ),
      isThreeLine: true,
      trailing: Chip(label: Text(resident.isActive ? 'Active' : 'Inactive')),
    ),
  );
}
