import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/widgets/resident_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResidentDetailsPage extends StatelessWidget {
  const ResidentDetailsPage({required this.residentId, super.key});
  final String residentId;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<ResidentDetailsBloc>()
              ..add(ResidentDetailsRequested(residentId)),
      ),
      BlocProvider(
        create: (_) {
          final cubit = getIt<ResidentMutationCubit>();
          unawaited(cubit.loadOptions());
          return cubit;
        },
      ),
    ],
    child: _ResidentDetailsView(residentId: residentId),
  );
}

class _ResidentDetailsView extends StatelessWidget {
  const _ResidentDetailsView({required this.residentId});
  final String residentId;

  @override
  Widget build(BuildContext context) =>
      BlocListener<ResidentMutationCubit, ResidentMutationState>(
        listener: (context, state) {
          if (state.status == ResidentMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resident updated successfully.')),
            );
            context.read<ResidentDetailsBloc>().add(
              ResidentDetailsRequested(residentId),
            );
          } else if (state.status == ResidentMutationStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
          }
        },
        child: BlocBuilder<ResidentDetailsBloc, ResidentDetailsState>(
          builder: (context, state) {
            if (state.status == ResidentDetailsStatus.initial ||
                state.status == ResidentDetailsStatus.loading) {
              return const LoadingView(label: 'Loading resident details');
            }
            if (state.status == ResidentDetailsStatus.failure) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => context.read<ResidentDetailsBloc>().add(
                  ResidentDetailsRequested(residentId),
                ),
              );
            }
            return _ResidentDetailsContent(resident: state.resident!);
          },
        ),
      );
}

class _ResidentDetailsContent extends StatelessWidget {
  const _ResidentDetailsContent({required this.resident});
  final Resident resident;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Back to residents',
            onPressed: () => context.go('/residents'),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Text(
            'Resident details',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      const SizedBox(height: 20),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ResidentProfileCard(
            resident: resident,
            actions: [
              OutlinedButton.icon(
                onPressed: () => unawaited(_changeApartment(context)),
                icon: const Icon(Icons.apartment_outlined),
                label: const Text('Change apartment'),
              ),
              OutlinedButton.icon(
                onPressed: () => unawaited(_toggleStatus(context)),
                icon: Icon(
                  resident.isActive ? Icons.block : Icons.check_circle,
                ),
                label: Text(resident.isActive ? 'Deactivate' : 'Activate'),
              ),
              FilledButton.icon(
                onPressed: () => unawaited(_edit(context)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit resident'),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Future<void> _edit(BuildContext context) async {
    final updated = await context.push<bool>('/residents/${resident.id}/edit');
    if (updated == true && context.mounted) {
      context.read<ResidentDetailsBloc>().add(
        ResidentDetailsRequested(resident.id),
      );
    }
  }

  Future<void> _toggleStatus(BuildContext context) async {
    final confirmed = await showConfirmation(
      context,
      title: resident.isActive
          ? 'Deactivate resident ${resident.user.name}?'
          : 'Activate resident ${resident.user.name}?',
      message: resident.isActive
          ? 'The resident profile will become inactive. The user account will remain unchanged.'
          : 'The resident profile will become active. The user account will remain unchanged.',
      confirmLabel: resident.isActive ? 'Deactivate' : 'Activate',
    );
    if (confirmed && context.mounted) {
      await context.read<ResidentMutationCubit>().updateStatus(
        resident.id,
        !resident.isActive,
      );
    }
  }

  Future<void> _changeApartment(BuildContext context) async {
    final mutation = context.read<ResidentMutationCubit>();
    final apartmentId = await showDialog<String>(
      context: context,
      builder: (_) => _ChangeApartmentDialog(
        currentApartment: resident.apartment,
        apartments: mutation.state.apartments,
      ),
    );
    if (apartmentId == null || !context.mounted) return;
    final confirmed = await showConfirmation(
      context,
      title: 'Change apartment?',
      message: 'Move ${resident.user.name} to the selected apartment?',
      confirmLabel: 'Change apartment',
    );
    if (confirmed && context.mounted) {
      await mutation.changeApartment(resident.id, apartmentId);
    }
  }
}

class _ChangeApartmentDialog extends StatefulWidget {
  const _ChangeApartmentDialog({
    required this.currentApartment,
    required this.apartments,
  });
  final Apartment currentApartment;
  final List<Apartment> apartments;

  @override
  State<_ChangeApartmentDialog> createState() => _ChangeApartmentDialogState();
}

class _ChangeApartmentDialogState extends State<_ChangeApartmentDialog> {
  late String _selected = widget.currentApartment.id;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change apartment'),
    content: SizedBox(
      width: 420,
      child: _options.isEmpty
          ? const Text('Apartment options could not be loaded. Try again.')
          : DropdownButtonFormField<String>(
              initialValue: _selected,
              decoration: const InputDecoration(labelText: 'Apartment'),
              items: _options
                  .map(
                    (apartment) => DropdownMenuItem(
                      value: apartment.id,
                      child: Text('${apartment.block}-${apartment.unitNumber}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
            ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _options.isEmpty
            ? null
            : () => Navigator.pop(context, _selected),
        child: const Text('Continue'),
      ),
    ],
  );

  List<Apartment> get _options {
    final byId = {
      widget.currentApartment.id: widget.currentApartment,
      for (final apartment in widget.apartments) apartment.id: apartment,
    };
    return byId.values.toList();
  }
}
