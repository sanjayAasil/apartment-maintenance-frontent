import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/utils/validators.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/widgets/resident_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditResidentPage extends StatelessWidget {
  const EditResidentPage({required this.residentId, super.key});
  final String residentId;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<ResidentDetailsBloc>()
              ..add(ResidentDetailsRequested(residentId)),
      ),
      BlocProvider(create: (_) => getIt<ResidentMutationCubit>()),
    ],
    child: _EditResidentView(residentId: residentId),
  );
}

class _EditResidentView extends StatefulWidget {
  const _EditResidentView({required this.residentId});
  final String residentId;
  @override
  State<_EditResidentView> createState() => _EditResidentViewState();
}

class _EditResidentViewState extends State<_EditResidentView> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _moveInDate = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _phone.dispose();
    _moveInDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ResidentMutationCubit, ResidentMutationState>(
        listener: (context, state) {
          if (state.status == ResidentMutationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resident updated successfully.')),
            );
            context.pop(true);
          } else if (state.status == ResidentMutationStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
          }
        },
        child: BlocBuilder<ResidentDetailsBloc, ResidentDetailsState>(
          builder: (context, details) {
            if (details.status == ResidentDetailsStatus.initial ||
                details.status == ResidentDetailsStatus.loading) {
              return const LoadingView(label: 'Loading resident');
            }
            if (details.status == ResidentDetailsStatus.failure) {
              return ErrorView(
                message: details.failure!.message,
                onRetry: () => context.read<ResidentDetailsBloc>().add(
                  ResidentDetailsRequested(widget.residentId),
                ),
              );
            }
            final resident = details.resident!;
            if (!_initialized) _populate(resident);
            return BlocBuilder<ResidentMutationCubit, ResidentMutationState>(
              builder: (context, mutation) => _form(
                context,
                resident,
                mutation.status == ResidentMutationStatus.submitting,
              ),
            );
          },
        ),
      );

  Widget _form(BuildContext context, Resident resident, bool submitting) =>
      ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to resident',
                onPressed: submitting ? null : () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                'Edit resident',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          resident.user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(resident.user.email),
                        const SizedBox(height: 20),
                        TextFormField(
                          key: const Key('residentPhone'),
                          controller: _phone,
                          enabled: !submitting,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('residentMoveInDate'),
                          controller: _moveInDate,
                          enabled: !submitting,
                          decoration: const InputDecoration(
                            labelText: 'Move-in date',
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) =>
                              Validators.date(value, 'Move-in date'),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            key: const Key('saveResidentButton'),
                            onPressed: submitting ? null : _submit,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  void _populate(Resident resident) {
    _phone.text = resident.phone;
    _moveInDate.text = formatResidentDate(resident.moveInDate);
    _initialized = true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    unawaited(
      context.read<ResidentMutationCubit>().update(
        widget.residentId,
        _phone.text,
        _moveInDate.text,
      ),
    );
  }
}
