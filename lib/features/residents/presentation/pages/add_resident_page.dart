import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/utils/validators.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_mutation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddResidentPage extends StatelessWidget {
  const AddResidentPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = getIt<ResidentMutationCubit>();
      unawaited(cubit.loadOptions());
      return cubit;
    },
    child: const _AddResidentView(),
  );
}

class _AddResidentView extends StatefulWidget {
  const _AddResidentView();
  @override
  State<_AddResidentView> createState() => _AddResidentViewState();
}

class _AddResidentViewState extends State<_AddResidentView> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _moveInDate = TextEditingController();
  String? _userId;
  String? _apartmentId;

  @override
  void dispose() {
    _phone.dispose();
    _moveInDate.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ResidentMutationCubit, ResidentMutationState>(
    listener: (context, state) {
      if (state.status == ResidentMutationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resident created successfully.')),
        );
        context.pop(true);
      } else if (state.status == ResidentMutationStatus.failure &&
          state.users.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    builder: (context, state) {
      if ((state.status == ResidentMutationStatus.initial ||
              state.status == ResidentMutationStatus.loadingOptions) &&
          state.users.isEmpty &&
          state.apartments.isEmpty) {
        return const LoadingView(label: 'Loading resident form');
      }
      if (state.status == ResidentMutationStatus.failure &&
          state.users.isEmpty &&
          state.apartments.isEmpty) {
        return ErrorView(
          message: state.failure!.message,
          onRetry: context.read<ResidentMutationCubit>().loadOptions,
        );
      }
      final submitting = state.status == ResidentMutationStatus.submitting;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Header(title: 'Add resident', submitting: submitting),
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
                        DropdownButtonFormField<String>(
                          key: const Key('residentUser'),
                          initialValue: _userId,
                          decoration: const InputDecoration(
                            labelText: 'Resident user',
                          ),
                          items: state.users
                              .map(
                                (user) => DropdownMenuItem(
                                  value: user.id,
                                  child: Text('${user.name} — ${user.email}'),
                                ),
                              )
                              .toList(),
                          onChanged: submitting
                              ? null
                              : (value) => setState(() => _userId = value),
                          validator: (value) =>
                              value == null ? 'Select a resident user.' : null,
                        ),
                        if (state.users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'No active users with the RESIDENT role are available.',
                            ),
                          ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: const Key('residentApartment'),
                          initialValue: _apartmentId,
                          decoration: const InputDecoration(
                            labelText: 'Apartment',
                          ),
                          items: state.apartments
                              .map(
                                (apartment) => DropdownMenuItem(
                                  value: apartment.id,
                                  child: Text(
                                    '${apartment.block}-${apartment.unitNumber}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: submitting
                              ? null
                              : (value) => setState(() => _apartmentId = value),
                          validator: (value) =>
                              value == null ? 'Select an apartment.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('residentPhone'),
                          controller: _phone,
                          enabled: !submitting,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
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
                            icon: submitting
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: const Text('Create resident'),
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
    },
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    unawaited(
      context.read<ResidentMutationCubit>().create(
        _userId!,
        _apartmentId!,
        _phone.text,
        _moveInDate.text,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.submitting});
  final String title;
  final bool submitting;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Back to residents',
        onPressed: submitting ? null : () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
    ],
  );
}
