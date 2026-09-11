import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart';
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
    ],
    child: _MaintenanceRequestDetailsView(requestId: requestId),
  );
}

class _MaintenanceRequestDetailsView extends StatelessWidget {
  const _MaintenanceRequestDetailsView({required this.requestId});
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
                          if (request.status == MaintenanceRequestStatus.open)
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
    if (request.status == MaintenanceRequestStatus.open) {
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
    if (request.status == MaintenanceRequestStatus.resolved) {
      targets.add(MaintenanceRequestStatus.closed);
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
