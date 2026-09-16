import 'dart:async';
import 'dart:math' as math;

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    if (user?.role != UserRole.admin) {
      return const Center(child: Text('Access denied'));
    }
    return BlocProvider(
      create: (_) {
        final cubit = getIt<DashboardCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) {
      final data = state.data;
      if (data == null) {
        if (state.status == DashboardStatus.failure) {
          return ErrorView(
            message: state.failure!.message,
            onRetry: () => unawaited(context.read<DashboardCubit>().load()),
          );
        }
        return const LoadingView(label: 'Loading dashboard');
      }
      return RefreshIndicator(
        onRefresh: () => context.read<DashboardCubit>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: state.status == DashboardStatus.refreshing
                          ? null
                          : () => _selectRange(context, state.range!),
                      icon: const Icon(Icons.date_range_outlined),
                      label: const Text('Date range'),
                    ),
                    TextButton(
                      onPressed: state.status == DashboardStatus.refreshing
                          ? null
                          : () => unawaited(
                              context.read<DashboardCubit>().load(
                                DashboardRange.thisMonth(),
                              ),
                            ),
                      child: const Text('This month'),
                    ),
                    IconButton(
                      tooltip: 'Refresh dashboard',
                      onPressed: state.status == DashboardStatus.refreshing
                          ? null
                          : () => unawaited(
                              context.read<DashboardCubit>().load(),
                            ),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
            if (state.status == DashboardStatus.refreshing)
              const LinearProgressIndicator(),
            if (state.failure != null)
              MaterialBanner(
                content: Text(
                  'Refresh failed: ${state.failure!.message} Showing the last successful report.',
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        unawaited(context.read<DashboardCubit>().load()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              'Live operational snapshot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'Today and this month use UTC calendar dates. Snapshot cards do not change with the report filter.',
            ),
            const SizedBox(height: 12),
            _SummaryCards(summary: data.summary),
            const SizedBox(height: 24),
            Text(
              'Reports: ${DashboardRange.date(state.range!.from)} to ${DashboardRange.date(state.range!.to)} (UTC)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 760
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _Panel(
                        title: 'Requests by status',
                        subtitle: 'Requests created in the selected period',
                        child: _CountBars(
                          items: data.statuses
                              .map((item) => (item.label, item.count))
                              .toList(),
                          empty:
                              'No maintenance requests created for this period.',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _Panel(
                        title: 'Requests by category',
                        subtitle: 'Requests created in the selected period',
                        child: _CountBars(
                          items: data.categories
                              .map((item) => (item.categoryName, item.count))
                              .toList(),
                          empty: 'No category report data for this period.',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _Panel(
                        title: 'Maintenance cost',
                        subtitle:
                            'Recorded parts usage and work notes created in this period',
                        child: Column(
                          children: [
                            _value('Parts', _money(data.cost.partsCost)),
                            _value('Labor', _money(data.cost.laborCost)),
                            _value('Other', _money(data.cost.otherCost)),
                            const Divider(),
                            _value('Total cost', _money(data.cost.totalCost)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _Panel(
                        title: 'Feedback summary',
                        subtitle: 'Feedback submitted in the selected period',
                        child: data.feedback.totalFeedback == 0
                            ? const Text(
                                'No feedback submitted yet for this period.',
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _value(
                                    'Average rating',
                                    '${data.feedback.averageRating!.toStringAsFixed(2)} / 5',
                                  ),
                                  _value(
                                    'Total feedback',
                                    '${data.feedback.totalFeedback}',
                                  ),
                                  const SizedBox(height: 8),
                                  _CountBars(
                                    items: [
                                      for (
                                        var rating = 5;
                                        rating >= 1;
                                        rating--
                                      )
                                        (
                                          '$rating stars',
                                          data.feedback.ratings['$rating'] ?? 0,
                                        ),
                                    ],
                                    empty: 'No feedback submitted yet.',
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _Panel(
                        title: 'Average resolution time',
                        subtitle:
                            'Created to resolved; resolved in the selected period',
                        child: data.resolution.resolvedRequests == 0
                            ? const Text(
                                'No resolved maintenance requests for this period.',
                              )
                            : Column(
                                children: [
                                  _value(
                                    'Average hours',
                                    data.resolution.averageHours!
                                        .toStringAsFixed(2),
                                  ),
                                  _value(
                                    'Average minutes',
                                    data.resolution.averageMinutes!
                                        .toStringAsFixed(1),
                                  ),
                                  _value(
                                    'Resolved requests',
                                    '${data.resolution.resolvedRequests}',
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Technician workload',
              subtitle:
                  'Active jobs are live. Resolved jobs are credited to the final active assignment in the selected period.',
              child: data.workload.isEmpty
                  ? const Text('No technician profiles available.')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Technician')),
                          DataColumn(label: Text('Active jobs'), numeric: true),
                          DataColumn(label: Text('In progress'), numeric: true),
                          DataColumn(label: Text('Resolved'), numeric: true),
                          DataColumn(label: Text('Available')),
                          DataColumn(label: Text('Active profile')),
                        ],
                        rows: data.workload
                            .map(
                              (item) => DataRow(
                                cells: [
                                  DataCell(Text(item.name)),
                                  DataCell(Text('${item.activeAssignments}')),
                                  DataCell(Text('${item.inProgressRequests}')),
                                  DataCell(Text('${item.resolvedCount}')),
                                  DataCell(
                                    Text(item.isAvailable ? 'Yes' : 'No'),
                                  ),
                                  DataCell(Text(item.isActive ? 'Yes' : 'No')),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Low stock parts',
              subtitle: 'Active parts where stock is at or below the minimum',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.lowStockParts.isEmpty)
                    const Text('No low-stock parts.')
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Part')),
                          DataColumn(
                            label: Text('Current stock'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Minimum stock'),
                            numeric: true,
                          ),
                        ],
                        rows: data.lowStockParts
                            .map(
                              (part) => DataRow(
                                cells: [
                                  DataCell(Text(part.name)),
                                  DataCell(Text('${part.quantity}')),
                                  DataCell(Text('${part.minimumStock}')),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (data.lowStockTotal > data.lowStockParts.length)
                    Text(
                      'Showing ${data.lowStockParts.length} of ${data.lowStockTotal} low-stock parts. View Parts for the complete inventory.',
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.go('/parts'),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Manage parts'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  Future<void> _selectRange(BuildContext context, DashboardRange range) async {
    final selection = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366)),
      initialDateRange: DateTimeRange(
        start: DateTime(range.from.year, range.from.month, range.from.day),
        end: DateTime(range.to.year, range.to.month, range.to.day),
      ),
    );
    if (selection != null && context.mounted) {
      await context.read<DashboardCubit>().load(
        DashboardRange(
          from: DateTime.utc(
            selection.start.year,
            selection.start.month,
            selection.start.day,
          ),
          to: DateTime.utc(
            selection.end.year,
            selection.end.month,
            selection.end.day,
          ),
        ),
      );
    }
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});
  final DashboardSummary summary;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1100
          ? 4
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      final values = [
        ('Total Requests', summary.totalRequests),
        ('Open Requests', summary.openRequests),
        ('Assigned Requests', summary.assignedRequests),
        ('In Progress', summary.inProgressRequests),
        ('Urgent Requests', summary.urgentRequests),
        ('Resolved Today', summary.resolvedToday),
        ('Closed This Month', summary.closedThisMonth),
        ('Active Technicians', summary.activeTechnicians),
        ('Available Technicians', summary.availableTechnicians),
        ('Active Residents', summary.activeResidents),
        ('Low Stock Parts', summary.lowStockParts),
      ];
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: values
            .map(
              (item) => SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1),
                        const SizedBox(height: 8),
                        Text(
                          '${item.$2}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title, subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _CountBars extends StatelessWidget {
  const _CountBars({required this.items, required this.empty});
  final List<(String, int)> items;
  final String empty;
  @override
  Widget build(BuildContext context) {
    final maximum = items.fold<int>(
      0,
      (value, item) => math.max(value, item.$2),
    );
    if (maximum == 0) return Text(empty);
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  _value(item.$1, '${item.$2}'),
                  const SizedBox(height: 4),
                  Semantics(
                    label: '${item.$1}: ${item.$2}',
                    child: LinearProgressIndicator(
                      value: item.$2 / maximum,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

Widget _value(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Row(
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  ),
);
String _money(double value) => '₹${value.toStringAsFixed(2)}';
