import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technicians_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TechniciansPage extends StatelessWidget {
  const TechniciansPage({super.key});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<TechniciansListBloc>()..add(const TechniciansRequested()),
      ),
      BlocProvider(
        create: (_) {
          final cubit = getIt<TechnicianMutationCubit>();
          unawaited(cubit.loadOptions());
          return cubit;
        },
      ),
    ],
    child: const _TechniciansView(),
  );
}

class _TechniciansView extends StatefulWidget {
  const _TechniciansView();
  @override
  State<_TechniciansView> createState() => _TechniciansViewState();
}

class _TechniciansViewState extends State<_TechniciansView> {
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<TechnicianMutationCubit, TechnicianMutationState>(
    listener: (context, state) {
      if (state.status == TechnicianMutationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Technician updated successfully.')),
        );
        context.read<TechniciansListBloc>().add(const TechniciansRequested());
      } else if (state.status == TechnicianMutationStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    child: BlocBuilder<TechniciansListBloc, TechniciansListState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Technicians',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                FilledButton.icon(
                  key: const Key('addTechnicianButton'),
                  onPressed: () =>
                      unawaited(_open(context, '/technicians/new')),
                  icon: const Icon(Icons.add),
                  label: const Text('Add technician'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    key: const Key('techniciansSearch'),
                    decoration: const InputDecoration(
                      labelText: 'Search name or email',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 350), () {
                        if (mounted) {
                          context.read<TechniciansListBloc>().add(
                            TechniciansSearchChanged(value),
                          );
                        }
                      });
                    },
                  ),
                ),
                _booleanFilter(
                  key: const Key('technicianActiveFilter'),
                  label: 'Status',
                  value: state.query.isActive,
                  trueText: 'Active',
                  falseText: 'Inactive',
                  onChanged: (value) => context.read<TechniciansListBloc>().add(
                    TechniciansActiveFilterChanged(value),
                  ),
                ),
                _booleanFilter(
                  key: const Key('technicianAvailabilityFilter'),
                  label: 'Availability',
                  value: state.query.isAvailable,
                  trueText: 'Available',
                  falseText: 'Unavailable',
                  onChanged: (value) => context.read<TechniciansListBloc>().add(
                    TechniciansAvailabilityFilterChanged(value),
                  ),
                ),
                BlocBuilder<TechnicianMutationCubit, TechnicianMutationState>(
                  builder: (context, options) => SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String?>(
                      initialValue: state.query.categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Skill'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All skills'),
                        ),
                        ...options.categories.map(
                          (category) => DropdownMenuItem<String?>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => context
                          .read<TechniciansListBloc>()
                          .add(TechniciansCategoryFilterChanged(value)),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Refresh technicians',
                  onPressed: () => context.read<TechniciansListBloc>().add(
                    const TechniciansRequested(),
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
    ),
  );

  Widget _booleanFilter({
    required Key key,
    required String label,
    required bool? value,
    required String trueText,
    required String falseText,
    required ValueChanged<bool?> onChanged,
  }) => SizedBox(
    width: 180,
    child: DropdownButtonFormField<bool?>(
      key: key,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<bool?>(value: null, child: Text('All')),
        DropdownMenuItem<bool?>(value: true, child: Text(trueText)),
        DropdownMenuItem<bool?>(value: false, child: Text(falseText)),
      ],
      onChanged: onChanged,
    ),
  );

  Widget _content(BuildContext context, TechniciansListState state) {
    if (state.result == null &&
        (state.status == TechniciansListStatus.initial ||
            state.status == TechniciansListStatus.loading)) {
      return const LoadingView(label: 'Loading technicians');
    }
    if (state.status == TechniciansListStatus.failure && state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () => context.read<TechniciansListBloc>().add(
          const TechniciansRequested(),
        ),
      );
    }
    if (state.status == TechniciansListStatus.empty ||
        state.result?.items.isEmpty == true) {
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            EmptyView(message: 'No technicians match the selected filters.'),
          ],
        ),
      );
    }
    final result = state.result!;
    return Column(
      children: [
        if (state.status == TechniciansListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: result.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _card(context, result.items[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: PaginationBar(
            page: result.page,
            totalPages: result.totalPages,
            pageSize: result.pageSize,
            onPageChanged: (page) => context.read<TechniciansListBloc>().add(
              TechniciansPageChanged(page),
            ),
            onPageSizeChanged: (size) => context
                .read<TechniciansListBloc>()
                .add(TechniciansPageSizeChanged(size)),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, Technician technician) => Card(
    child: ListTile(
      onTap: () => context.push('/technicians/${technician.id}'),
      leading: CircleAvatar(
        child: Text(
          technician.user.name.isEmpty
              ? '?'
              : technician.user.name[0].toUpperCase(),
        ),
      ),
      title: Text(technician.user.name),
      subtitle: Text(
        '${technician.user.email} • ${technician.phone}\n${technician.experienceYears} ${technician.experienceYears == 1 ? 'year' : 'years'} • ${technician.isAvailable ? 'Available' : 'Unavailable'} • ${technician.isActive ? 'Active' : 'Inactive'}\n${technician.skills.isEmpty ? 'No skills' : technician.skills.map((skill) => skill.category.name).join(', ')}',
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        tooltip: 'Technician actions',
        onSelected: (value) {
          if (value == 'edit') {
            unawaited(_open(context, '/technicians/${technician.id}/edit'));
          } else if (value == 'status') {
            unawaited(_confirmStatus(context, technician));
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(
            value: 'status',
            child: Text(technician.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    ),
  );

  Future<void> _confirmStatus(
    BuildContext context,
    Technician technician,
  ) async {
    final value = !technician.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${value ? 'Activate' : 'Deactivate'} ${technician.user.name}?',
        ),
        content: const Text(
          'Technician profile status is separate from the User account status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(value ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TechnicianMutationCubit>().updateStatus(
        technician.id,
        value,
      );
    }
  }

  Future<void> _open(BuildContext context, String path) async {
    final changed = await context.push<bool>(path);
    if (changed == true && context.mounted) {
      context.read<TechniciansListBloc>().add(const TechniciansRequested());
    }
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<TechniciansListBloc>().add(const TechniciansRequested());
    await context.read<TechniciansListBloc>().stream.firstWhere(
      (state) => state.status != TechniciansListStatus.loading,
    );
  }
}
