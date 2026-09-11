import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_mutation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TechnicianDetailsPage extends StatelessWidget {
  const TechnicianDetailsPage({required this.technicianId, super.key});
  final String technicianId;
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<TechnicianDetailsBloc>()
              ..add(TechnicianDetailsRequested(technicianId)),
      ),
      BlocProvider(
        create: (_) {
          final cubit = getIt<TechnicianMutationCubit>();
          unawaited(cubit.loadOptions());
          return cubit;
        },
      ),
    ],
    child: _TechnicianDetailsView(technicianId: technicianId),
  );
}

class _TechnicianDetailsView extends StatefulWidget {
  const _TechnicianDetailsView({required this.technicianId});
  final String technicianId;
  @override
  State<_TechnicianDetailsView> createState() => _TechnicianDetailsViewState();
}

class _TechnicianDetailsViewState extends State<_TechnicianDetailsView> {
  String? _selectedCategory;

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<TechnicianMutationCubit, TechnicianMutationState>(
    listener: (context, state) {
      if (state.status == TechnicianMutationStatus.success) {
        setState(() => _selectedCategory = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Technician updated successfully.')),
        );
        context.read<TechnicianDetailsBloc>().add(
          TechnicianDetailsRequested(widget.technicianId),
        );
      } else if (state.status == TechnicianMutationStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    child: BlocBuilder<TechnicianDetailsBloc, TechnicianDetailsState>(
      builder: (context, state) {
        if (state.technician == null &&
            (state.status == TechnicianDetailsStatus.initial ||
                state.status == TechnicianDetailsStatus.loading)) {
          return const LoadingView(label: 'Loading technician');
        }
        if (state.technician == null &&
            state.status == TechnicianDetailsStatus.failure) {
          return ErrorView(
            message: state.failure!.message,
            onRetry: () => context.read<TechnicianDetailsBloc>().add(
              TechnicianDetailsRequested(widget.technicianId),
            ),
          );
        }
        final technician = state.technician!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back to technicians',
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    technician.user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final changed = await context.push<bool>(
                      '/technicians/${technician.id}/edit',
                    );
                    if (changed == true && context.mounted) {
                      context.read<TechnicianDetailsBloc>().add(
                        TechnicianDetailsRequested(technician.id),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 420,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _line(Icons.email_outlined, technician.user.email),
                          _line(Icons.phone_outlined, technician.phone),
                          _line(
                            Icons.work_history_outlined,
                            '${technician.experienceYears} ${technician.experienceYears == 1 ? 'year' : 'years'} experience',
                          ),
                          _line(
                            Icons.verified_user_outlined,
                            technician.isActive
                                ? 'Active profile'
                                : 'Inactive profile',
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Available for assignment'),
                            value: technician.isAvailable,
                            onChanged:
                                state.status == TechnicianDetailsStatus.loading
                                ? null
                                : (value) => unawaited(
                                    context
                                        .read<TechnicianMutationCubit>()
                                        .updateAvailability(
                                          technician.id,
                                          value,
                                        ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 520, child: _skills(context, technician)),
              ],
            ),
          ],
        );
      },
    ),
  );

  Widget _skills(BuildContext context, Technician technician) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Skills', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (technician.skills.isEmpty)
            const Text('No skills assigned.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: technician.skills
                  .map(
                    (skill) => InputChip(
                      label: Text(skill.category.name),
                      onDeleted: () => unawaited(
                        _removeSkill(context, technician, skill.categoryId),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          BlocBuilder<TechnicianMutationCubit, TechnicianMutationState>(
            builder: (context, mutation) {
              final assigned = technician.skills
                  .map((skill) => skill.categoryId)
                  .toSet();
              final available = mutation.categories
                  .where((category) => !assigned.contains(category.id))
                  .toList();
              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('technicianSkillSelector'),
                      initialValue: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Add skill'),
                      items: available
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      onChanged:
                          mutation.status == TechnicianMutationStatus.submitting
                          ? null
                          : (value) =>
                                setState(() => _selectedCategory = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    key: const Key('addTechnicianSkillButton'),
                    onPressed:
                        _selectedCategory == null ||
                            mutation.status ==
                                TechnicianMutationStatus.submitting
                        ? null
                        : () => unawaited(
                            context.read<TechnicianMutationCubit>().addSkill(
                              technician.id,
                              _selectedCategory!,
                            ),
                          ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );

  Widget _line(IconData icon, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(value)),
      ],
    ),
  );

  Future<void> _removeSkill(
    BuildContext context,
    Technician technician,
    String categoryId,
  ) async {
    final skill = technician.skills.firstWhere(
      (item) => item.categoryId == categoryId,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${skill.category.name}?'),
        content: const Text(
          'This removes only the technician-skill relationship.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TechnicianMutationCubit>().removeSkill(
        technician.id,
        categoryId,
      );
    }
  }
}
