import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_categories_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_category_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MaintenanceCategoriesPage extends StatelessWidget {
  const MaintenanceCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<MaintenanceCategoriesListBloc>()
              ..add(const MaintenanceCategoriesRequested()),
      ),
      BlocProvider(create: (_) => getIt<MaintenanceCategoryFormCubit>()),
    ],
    child: const _MaintenanceCategoriesView(),
  );
}

class _MaintenanceCategoriesView extends StatefulWidget {
  const _MaintenanceCategoriesView();
  @override
  State<_MaintenanceCategoriesView> createState() =>
      _MaintenanceCategoriesViewState();
}

class _MaintenanceCategoriesViewState
    extends State<_MaintenanceCategoriesView> {
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<MaintenanceCategoryFormCubit, MaintenanceCategoryFormState>(
    listener: (context, state) {
      if (state.status == MaintenanceCategoryFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.category!.isActive
                  ? '${state.category!.name} activated.'
                  : '${state.category!.name} deactivated.',
            ),
          ),
        );
        context.read<MaintenanceCategoriesListBloc>().add(
          const MaintenanceCategoriesRequested(),
        );
      } else if (state.status == MaintenanceCategoryFormStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    child:
        BlocBuilder<
          MaintenanceCategoriesListBloc,
          MaintenanceCategoriesListState
        >(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Maintenance Categories',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    FilledButton.icon(
                      key: const Key('addCategoryButton'),
                      onPressed: () => unawaited(_openCreate(context)),
                      icon: const Icon(Icons.add),
                      label: const Text('Add category'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 320,
                      child: TextField(
                        key: const Key('categoriesSearch'),
                        decoration: const InputDecoration(
                          labelText: 'Search name or description',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          _searchDebounce?.cancel();
                          _searchDebounce = Timer(
                            const Duration(milliseconds: 350),
                            () {
                              if (mounted) {
                                context
                                    .read<MaintenanceCategoriesListBloc>()
                                    .add(
                                      MaintenanceCategoriesSearchChanged(value),
                                    );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      child: DropdownButtonFormField<bool?>(
                        key: const Key('categoryStatusFilter'),
                        initialValue: state.query.isActive,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All statuses'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) =>
                            context.read<MaintenanceCategoriesListBloc>().add(
                              MaintenanceCategoriesStatusFilterChanged(value),
                            ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Refresh categories',
                      onPressed: () => context
                          .read<MaintenanceCategoriesListBloc>()
                          .add(const MaintenanceCategoriesRequested()),
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

  Widget _content(BuildContext context, MaintenanceCategoriesListState state) {
    if (state.result == null &&
        (state.status == MaintenanceCategoriesListStatus.initial ||
            state.status == MaintenanceCategoriesListStatus.loading)) {
      return const LoadingView(label: 'Loading maintenance categories');
    }
    if (state.status == MaintenanceCategoriesListStatus.failure &&
        state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () => context.read<MaintenanceCategoriesListBloc>().add(
          const MaintenanceCategoriesRequested(),
        ),
      );
    }
    if (state.status == MaintenanceCategoriesListStatus.empty ||
        state.result?.items.isEmpty == true) {
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            EmptyView(message: 'No categories match the selected filters.'),
          ],
        ),
      );
    }
    final result = state.result;
    if (result == null) {
      return ErrorView(
        message: 'Maintenance categories could not be displayed.',
        onRetry: () => context.read<MaintenanceCategoriesListBloc>().add(
          const MaintenanceCategoriesRequested(),
        ),
      );
    }
    return Column(
      children: [
        if (state.status == MaintenanceCategoriesListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 850) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: result.items
                            .map((category) => _row(context, category))
                            .toList(),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: result.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _card(context, result.items[index]),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: PaginationBar(
            page: result.page,
            totalPages: result.totalPages,
            pageSize: result.pageSize,
            onPageChanged: (page) => context
                .read<MaintenanceCategoriesListBloc>()
                .add(MaintenanceCategoriesPageChanged(page)),
            onPageSizeChanged: (size) => context
                .read<MaintenanceCategoriesListBloc>()
                .add(MaintenanceCategoriesPageSizeChanged(size)),
          ),
        ),
      ],
    );
  }

  DataRow _row(BuildContext context, MaintenanceCategory category) => DataRow(
    cells: [
      DataCell(Text(category.name)),
      DataCell(
        SizedBox(
          width: 360,
          child: Text(
            category.description ?? '—',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(_statusChip(category.isActive)),
      DataCell(_actions(context, category)),
    ],
  );

  Widget _card(BuildContext context, MaintenanceCategory category) => Card(
    child: ListTile(
      leading: CircleAvatar(
        child: Icon(
          category.isActive ? Icons.build_outlined : Icons.pause_outlined,
        ),
      ),
      title: Text(category.name),
      subtitle: Text(
        '${category.description?.isNotEmpty == true ? category.description : 'No description'}\n${category.isActive ? 'Active' : 'Inactive'}',
      ),
      isThreeLine: true,
      trailing: _actions(context, category),
    ),
  );

  Widget _statusChip(bool active) => Chip(
    avatar: Icon(
      active ? Icons.check_circle_outline : Icons.pause_circle_outline,
      size: 18,
    ),
    label: Text(active ? 'Active' : 'Inactive'),
  );

  Widget _actions(BuildContext context, MaintenanceCategory category) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Edit category',
        onPressed: () => unawaited(_openEdit(context, category.id)),
        icon: const Icon(Icons.edit_outlined),
      ),
      IconButton(
        tooltip: category.isActive
            ? 'Deactivate category'
            : 'Activate category',
        onPressed: () => unawaited(_confirmStatus(context, category)),
        icon: Icon(
          category.isActive
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
        ),
      ),
    ],
  );

  Future<void> _refresh(BuildContext context) async {
    context.read<MaintenanceCategoriesListBloc>().add(
      const MaintenanceCategoriesRequested(),
    );
    await context.read<MaintenanceCategoriesListBloc>().stream.firstWhere(
      (state) => state.status != MaintenanceCategoriesListStatus.loading,
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/maintenance-categories/new');
    if (created == true && context.mounted) {
      context.read<MaintenanceCategoriesListBloc>().add(
        const MaintenanceCategoriesRequested(),
      );
    }
  }

  Future<void> _openEdit(BuildContext context, String id) async {
    final updated = await context.push<bool>(
      '/maintenance-categories/$id/edit',
    );
    if (updated == true && context.mounted) {
      context.read<MaintenanceCategoriesListBloc>().add(
        const MaintenanceCategoriesRequested(),
      );
    }
  }

  Future<void> _confirmStatus(
    BuildContext context,
    MaintenanceCategory category,
  ) async {
    final activating = !category.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${activating ? 'Activate' : 'Deactivate'} ${category.name}?',
        ),
        content: Text(
          activating
              ? 'This category will be available for new operations.'
              : 'The category stays available for historical records but should not be selected for new operations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(activating ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<MaintenanceCategoryFormCubit>().updateStatus(
        category.id,
        activating,
      );
    }
  }
}
