import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_assignment_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_comments_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_history_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/widgets/maintenance_activity_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MaintenanceRequestDetailsPage extends StatelessWidget {
  const MaintenanceRequestDetailsPage({required this.requestId, super.key});
  final String requestId;
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<MaintenanceRequestDetailsBloc>()
              ..add(MaintenanceRequestDetailsRequested(requestId)),
      ),
      BlocProvider(create: (_) => getIt<MaintenanceRequestFormCubit>()),
      BlocProvider(create: (_) => getIt<MaintenanceAssignmentCubit>()),
      BlocProvider(create: (_) => getIt<MaintenanceCommentsCubit>()),
      BlocProvider(create: (_) => getIt<MaintenanceHistoryCubit>()),
    ],
    child: BlocListener<MaintenanceAssignmentCubit, MaintenanceAssignmentState>(
      listener: (context, state) {
        if (state.status == MaintenanceAssignmentStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Technician assignment updated.')),
          );
          context.read<MaintenanceRequestDetailsBloc>().add(
            MaintenanceRequestDetailsRequested(requestId),
          );
        } else if (state.status == MaintenanceAssignmentStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
      child: MaintenanceRequestDetailsView(requestId: requestId),
    ),
  );
}

class MaintenanceRequestDetailsView extends StatelessWidget {
  const MaintenanceRequestDetailsView({required this.requestId, super.key});
  final String requestId;
  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<MaintenanceRequestFormCubit, MaintenanceRequestFormState>(
    listener: (context, state) {
      if (state.status == MaintenanceRequestFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Request marked ${state.request!.status.label.toLowerCase()}.',
            ),
          ),
        );
        context.read<MaintenanceRequestDetailsBloc>().add(
          MaintenanceRequestDetailsRequested(requestId),
        );
      }
      if (state.status == MaintenanceRequestFormStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    child:
        BlocBuilder<
          MaintenanceRequestDetailsBloc,
          MaintenanceRequestDetailsState
        >(
          builder: (context, state) {
            if (state.status == MaintenanceRequestDetailsStatus.initial ||
                state.status == MaintenanceRequestDetailsStatus.loading) {
              return const LoadingView(label: 'Loading maintenance request');
            }
            if (state.status == MaintenanceRequestDetailsStatus.failure) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => context
                    .read<MaintenanceRequestDetailsBloc>()
                    .add(MaintenanceRequestDetailsRequested(requestId)),
              );
            }
            final request = state.request!;
            final user = context.select((AuthBloc bloc) => bloc.state.user);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 900,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          if (request.status == MaintenanceRequestStatus.open &&
                              user?.role != UserRole.technician)
                            OutlinedButton.icon(
                              onPressed: () => context.go(
                                '/maintenance-requests/${request.id}/edit',
                              ),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(request.status.label)),
                          Chip(
                            label: Text('${request.priority.label} priority'),
                          ),
                          Chip(label: Text(request.category.name)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(request.description),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            spacing: 42,
                            runSpacing: 20,
                            children: [
                              _fact(
                                'Apartment',
                                '${request.apartment.block}-${request.apartment.unitNumber} (Floor ${request.apartment.floor})',
                              ),
                              _fact('Resident', request.resident.user.name),
                              _fact('Email', request.resident.user.email),
                              _fact('Phone', request.resident.phone),
                              _fact('Created', _date(request.createdAt)),
                              if (request.resolvedAt != null)
                                _fact('Resolved', _date(request.resolvedAt!)),
                              if (request.closedAt != null)
                                _fact('Closed', _date(request.closedAt!)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (user?.role == UserRole.admin)
                        _AdminAssignmentPanel(request: request)
                      else
                        _AssignmentSummary(
                          assignment: request.activeAssignment,
                        ),
                      const SizedBox(height: 20),
                      MaintenanceActivitySections(requestId: request.id),
                      const SizedBox(height: 20),
                      _actions(context, request, user),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
  );

  Widget _fact(String label, String value) => SizedBox(
    width: 230,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value),
      ],
    ),
  );
  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}';
  Widget _actions(
    BuildContext context,
    MaintenanceRequest request,
    AppUser? user,
  ) {
    final targets = <MaintenanceRequestStatus>[];
    if (user?.role != UserRole.technician &&
        request.status == MaintenanceRequestStatus.open) {
      targets.add(MaintenanceRequestStatus.cancelled);
    }
    if (user?.role == UserRole.admin &&
        request.status == MaintenanceRequestStatus.assigned) {
      targets.add(MaintenanceRequestStatus.cancelled);
    }
    if (user?.role == UserRole.admin &&
        request.status == MaintenanceRequestStatus.inProgress) {
      targets.add(MaintenanceRequestStatus.resolved);
    }
    if (user?.role != UserRole.technician &&
        request.status == MaintenanceRequestStatus.resolved) {
      targets.add(MaintenanceRequestStatus.closed);
    }
    if (user?.role == UserRole.technician &&
        request.status == MaintenanceRequestStatus.assigned) {
      targets.add(MaintenanceRequestStatus.inProgress);
    }
    if (user?.role == UserRole.technician &&
        request.status == MaintenanceRequestStatus.inProgress) {
      targets.add(MaintenanceRequestStatus.resolved);
    }
    if (targets.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      children: targets
          .map(
            (status) => FilledButton.tonalIcon(
              onPressed: () => _confirmStatus(context, request, status),
              icon: Icon(
                status == MaintenanceRequestStatus.cancelled
                    ? Icons.cancel_outlined
                    : status == MaintenanceRequestStatus.resolved
                    ? Icons.check_circle_outline
                    : Icons.lock_outline,
              ),
              label: Text(
                status == MaintenanceRequestStatus.cancelled
                    ? 'Cancel request'
                    : status == MaintenanceRequestStatus.inProgress
                    ? 'Start work'
                    : status == MaintenanceRequestStatus.resolved &&
                          user?.role == UserRole.technician
                    ? 'Resolve'
                    : 'Mark ${status.label.toLowerCase()}',
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _confirmStatus(
    BuildContext context,
    MaintenanceRequest request,
    MaintenanceRequestStatus status,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('${status.label} request?'),
            content: Text(
              'Change “${request.title}” to ${status.label.toLowerCase()}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep current'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) {
      await context.read<MaintenanceRequestFormCubit>().updateStatus(
        request.id,
        status,
      );
    }
  }
}

class _AssignmentSummary extends StatelessWidget {
  const _AssignmentSummary({required this.assignment});
  final MaintenanceAssignment? assignment;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned technician',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (assignment == null)
            const Text('No technician is currently assigned.')
          else ...[
            Text(
              assignment!.technician.user.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('${assignment!.technician.experienceYears} years experience'),
            Text(
              assignment!.technician.skills
                  .map((skill) => skill.category.name)
                  .join(', '),
            ),
          ],
        ],
      ),
    ),
  );
}

class _AdminAssignmentPanel extends StatefulWidget {
  const _AdminAssignmentPanel({required this.request});
  final MaintenanceRequest request;
  @override
  State<_AdminAssignmentPanel> createState() => _AdminAssignmentPanelState();
}

class _AdminAssignmentPanelState extends State<_AdminAssignmentPanel> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<MaintenanceAssignmentCubit>().load(widget.request));
  }

  @override
  void didUpdateWidget(covariant _AdminAssignmentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.status != widget.request.status ||
        oldWidget.request.activeAssignment?.id !=
            widget.request.activeAssignment?.id) {
      unawaited(
        context.read<MaintenanceAssignmentCubit>().load(widget.request),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<MaintenanceAssignmentCubit, MaintenanceAssignmentState>(
    builder: (context, state) {
      final active = widget.request.activeAssignment;
      final busy =
          state.status == MaintenanceAssignmentStatus.loading ||
          state.status == MaintenanceAssignmentStatus.submitting;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AssignmentSummary(assignment: active),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            children: [
              if (widget.request.status == MaintenanceRequestStatus.open &&
                  active == null)
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => _selectTechnician(context, state, false),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Assign technician'),
                ),
              if (widget.request.status == MaintenanceRequestStatus.assigned &&
                  active != null) ...[
                OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () => _selectTechnician(context, state, true),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Reassign'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _confirmUnassign(context),
                  icon: const Icon(Icons.person_remove_outlined),
                  label: const Text('Unassign'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Assignment history',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (state.status == MaintenanceAssignmentStatus.loading)
            const LinearProgressIndicator()
          else if (state.history.isEmpty)
            const Text('No assignment history yet.')
          else
            ...state.history.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.isActive ? Icons.engineering : Icons.history,
                ),
                title: Text(item.technician.user.name),
                subtitle: Text(
                  item.isActive
                      ? 'Assigned ${_timestamp(item.assignedAt)} • Current'
                      : 'Assigned ${_timestamp(item.assignedAt)} • Unassigned ${_timestamp(item.unassignedAt!)}',
                ),
              ),
            ),
        ],
      );
    },
  );

  Future<void> _selectTechnician(
    BuildContext context,
    MaintenanceAssignmentState state,
    bool reassign,
  ) async {
    final currentId = widget.request.activeAssignment?.technicianId;
    final options = state.availableTechnicians
        .where((item) => item.id != currentId)
        .toList();
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other available matching technicians were found.'),
        ),
      );
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(reassign ? 'Reassign technician' : 'Assign technician'),
        children: options
            .map(
              (technician) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, technician.id),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(technician.user.name),
                  subtitle: Text(
                    '${technician.experienceYears} years • ${technician.skills.map((skill) => skill.category.name).join(', ')}',
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null || !context.mounted) return;
    final cubit = context.read<MaintenanceAssignmentCubit>();
    if (reassign) {
      await cubit.reassign(widget.request.id, selected);
    } else {
      await cubit.assign(widget.request.id, selected);
    }
  }

  Future<void> _confirmUnassign(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Unassign technician?'),
            content: const Text(
              'The request will return to Open and the assignment will remain in history.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep assigned'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Unassign'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) {
      await context.read<MaintenanceAssignmentCubit>().unassign(
        widget.request.id,
      );
    }
  }

  String _timestamp(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
