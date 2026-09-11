import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/utils/validators.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_mutation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TechnicianFormPage extends StatelessWidget {
  const TechnicianFormPage({this.technicianId, super.key});
  final String? technicianId;
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) {
          final cubit = getIt<TechnicianMutationCubit>();
          unawaited(cubit.loadOptions());
          return cubit;
        },
      ),
      if (technicianId != null)
        BlocProvider(
          create: (_) =>
              getIt<TechnicianDetailsBloc>()
                ..add(TechnicianDetailsRequested(technicianId!)),
        ),
    ],
    child: _TechnicianFormView(technicianId: technicianId),
  );
}

class _TechnicianFormView extends StatefulWidget {
  const _TechnicianFormView({required this.technicianId});
  final String? technicianId;
  @override
  State<_TechnicianFormView> createState() => _TechnicianFormViewState();
}

class _TechnicianFormViewState extends State<_TechnicianFormView> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _experience = TextEditingController();
  String? _userId;
  bool _initialized = false;
  bool get _editing => widget.technicianId != null;

  @override
  void dispose() {
    _phone.dispose();
    _experience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = BlocConsumer<TechnicianMutationCubit, TechnicianMutationState>(
      listener: (context, state) {
        if (state.status == TechnicianMutationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editing
                    ? 'Technician updated successfully.'
                    : 'Technician created successfully.',
              ),
            ),
          );
          context.pop(true);
        } else if (state.status == TechnicianMutationStatus.failure &&
            state.users.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
      builder: (context, mutation) {
        if (!_editing &&
            (mutation.status == TechnicianMutationStatus.initial ||
                mutation.status == TechnicianMutationStatus.loadingOptions)) {
          return const LoadingView(label: 'Loading technician form');
        }
        if (!_editing &&
            mutation.status == TechnicianMutationStatus.failure &&
            mutation.users.isEmpty) {
          return ErrorView(
            message: mutation.failure!.message,
            onRetry: context.read<TechnicianMutationCubit>().loadOptions,
          );
        }
        return _form(context, mutation);
      },
    );
    if (!_editing) return form;
    return BlocBuilder<TechnicianDetailsBloc, TechnicianDetailsState>(
      builder: (context, details) {
        if (details.status == TechnicianDetailsStatus.initial ||
            details.status == TechnicianDetailsStatus.loading) {
          return const LoadingView(label: 'Loading technician');
        }
        if (details.status == TechnicianDetailsStatus.failure &&
            details.technician == null) {
          return ErrorView(
            message: details.failure!.message,
            onRetry: () => context.read<TechnicianDetailsBloc>().add(
              TechnicianDetailsRequested(widget.technicianId!),
            ),
          );
        }
        if (!_initialized && details.technician != null) {
          _populate(details.technician!);
        }
        return form;
      },
    );
  }

  Widget _form(BuildContext context, TechnicianMutationState state) {
    final submitting = state.status == TechnicianMutationStatus.submitting;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back to technicians',
              onPressed: submitting ? null : () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            Text(
              _editing ? 'Edit technician' : 'Add technician',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_editing) ...[
                        DropdownButtonFormField<String>(
                          key: const Key('technicianUser'),
                          initialValue: _userId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Technician user',
                          ),
                          items: state.users
                              .map(
                                (user) => DropdownMenuItem(
                                  value: user.id,
                                  child: Text(
                                    '${user.name} — ${user.email}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: submitting
                              ? null
                              : (value) => setState(() => _userId = value),
                          validator: (value) => value == null
                              ? 'Select a technician user.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        key: const Key('technicianPhone'),
                        controller: _phone,
                        enabled: !submitting,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('technicianExperience'),
                        controller: _experience,
                        enabled: !submitting,
                        decoration: const InputDecoration(
                          labelText: 'Experience years',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final years = int.tryParse(value?.trim() ?? '');
                          if (years == null) return 'Enter a whole number.';
                          if (years < 0) {
                            return 'Experience cannot be negative.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          key: const Key('saveTechnicianButton'),
                          onPressed: submitting ? null : _submit,
                          icon: submitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _editing ? 'Save changes' : 'Create technician',
                          ),
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
  }

  void _populate(Technician technician) {
    _userId = technician.userId;
    _phone.text = technician.phone;
    _experience.text = technician.experienceYears.toString();
    _initialized = true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final years = int.parse(_experience.text.trim());
    final cubit = context.read<TechnicianMutationCubit>();
    if (_editing) {
      unawaited(cubit.update(widget.technicianId!, _phone.text, years));
    } else {
      unawaited(cubit.create(_userId!, _phone.text, years));
    }
  }
}
