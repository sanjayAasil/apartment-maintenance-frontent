import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_categories_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_requests_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MaintenanceRequestsPage extends StatelessWidget {
  const MaintenanceRequestsPage({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<MaintenanceRequestsListBloc>()
              ..add(const MaintenanceRequestsRequested()),
      ),
      BlocProvider(
        create: (_) =>
            getIt<MaintenanceCategoriesListBloc>()
              ..add(const MaintenanceCategoriesRequested()),
      ),
    ],
    child: const _MaintenanceRequestsView(),
  );
}

class _MaintenanceRequestsView extends StatefulWidget {
  const _MaintenanceRequestsView();
  @override
  State<_MaintenanceRequestsView> createState() =>
      _MaintenanceRequestsViewState();
}

class _MaintenanceRequestsViewState extends State<_MaintenanceRequestsView> {
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final resident = user?.role == UserRole.resident;
    final technician = user?.role == UserRole.technician;
    return BlocBuilder<
      MaintenanceRequestsListBloc,
      MaintenanceRequestsListState
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
                    resident
                        ? 'My Maintenance Requests'
                        : technician
                        ? 'My Jobs'
                        : 'Maintenance Requests',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                if (resident)
                  FilledButton.icon(
                    onPressed: () => context.go('/maintenance-requests/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('New request'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search requests',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 350), () {
                        if (mounted) {
                          context.read<MaintenanceRequestsListBloc>().add(
                            MaintenanceRequestsSearchChanged(value),
                          );
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<MaintenanceRequestStatus?>(
                    isExpanded: true,
                    initialValue: state.query.status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All statuses'),
                      ),
                      ...MaintenanceRequestStatus.values.map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => context
                        .read<MaintenanceRequestsListBloc>()
                        .add(MaintenanceRequestsStatusChanged(value)),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<MaintenancePriority?>(
                    isExpanded: true,
                    initialValue: state.query.priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All priorities'),
                      ),
                      ...MaintenancePriority.values.map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => context
                        .read<MaintenanceRequestsListBloc>()
                        .add(MaintenanceRequestsPriorityChanged(value)),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child:
                      BlocBuilder<
                        MaintenanceCategoriesListBloc,
                        MaintenanceCategoriesListState
                      >(
                        builder: (context, categoriesState) =>
                            DropdownButtonFormField<String?>(
                              initialValue: state.query.categoryId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All categories'),
                                ),
                                ...?categoriesState.result?.items.map(
                                  (item) => DropdownMenuItem<String?>(
                                    value: item.id,
                                    child: Text(item.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) => context
                                  .read<MaintenanceRequestsListBloc>()
                                  .add(
                                    MaintenanceRequestsCategoryChanged(value),
                                  ),
                            ),
                      ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Refresh',
                  onPressed: () => context
                      .read<MaintenanceRequestsListBloc>()
                      .add(const MaintenanceRequestsRequested()),
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
  }

  Widget _content(BuildContext context, MaintenanceRequestsListState state) {
    if (state.result == null &&
        (state.status == MaintenanceRequestsListStatus.initial ||
            state.status == MaintenanceRequestsListStatus.loading)) {
      return const LoadingView(label: 'Loading maintenance requests');
    }
    if (state.status == MaintenanceRequestsListStatus.failure &&
        state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () => context.read<MaintenanceRequestsListBloc>().add(
          const MaintenanceRequestsRequested(),
        ),
      );
    }
    if (state.result?.items.isEmpty != false) {
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            EmptyView(message: 'No maintenance requests match these filters.'),
          ],
        ),
      );
    }
    final result = state.result!;
    return Column(
      children: [
        if (state.status == MaintenanceRequestsListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Request')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Apartment')),
                          DataColumn(label: Text('Priority')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Resident')),
                        ],
                        rows: result.items
                            .map(
                              (item) => DataRow(
                                onSelectChanged: (_) => context.go(
                                  '/maintenance-requests/${item.id}',
                                ),
                                cells: [
                                  DataCell(Text(item.title)),
                                  DataCell(Text(item.category.name)),
                                  DataCell(
                                    Text(
                                      '${item.apartment.block}-${item.apartment.unitNumber}',
                                    ),
                                  ),
                                  DataCell(_chip(item.priority.label)),
                                  DataCell(_chip(item.status.label)),
                                  DataCell(Text(item.resident.user.name)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: result.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = result.items[index];
                    return Card(
                      child: ListTile(
                        onTap: () =>
                            context.go('/maintenance-requests/${item.id}'),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.category.name} • ${item.apartment.block}-${item.apartment.unitNumber}\n${item.priority.label} • ${item.status.label}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
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
                .read<MaintenanceRequestsListBloc>()
                .add(MaintenanceRequestsPageChanged(page)),
            onPageSizeChanged: (size) => context
                .read<MaintenanceRequestsListBloc>()
                .add(MaintenanceRequestsPageSizeChanged(size)),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label) => Chip(label: Text(label));
  Future<void> _refresh(BuildContext context) async {
    context.read<MaintenanceRequestsListBloc>().add(
      const MaintenanceRequestsRequested(),
    );
    await context.read<MaintenanceRequestsListBloc>().stream.firstWhere(
      (state) => state.status != MaintenanceRequestsListStatus.loading,
    );
  }
}
