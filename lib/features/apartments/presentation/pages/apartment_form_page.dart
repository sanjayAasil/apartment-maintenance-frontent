import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/presentation/bloc/apartment_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApartmentFormPage extends StatelessWidget {
  const ApartmentFormPage({this.apartmentId, super.key});
  final String? apartmentId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = getIt<ApartmentFormCubit>();
      final id = apartmentId;
      if (id != null) unawaited(cubit.load(id));
      return cubit;
    },
    child: _ApartmentFormView(apartmentId: apartmentId),
  );
}

class _ApartmentFormView extends StatefulWidget {
  const _ApartmentFormView({required this.apartmentId});
  final String? apartmentId;

  @override
  State<_ApartmentFormView> createState() => _ApartmentFormViewState();
}

class _ApartmentFormViewState extends State<_ApartmentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _block = TextEditingController();
  final _floor = TextEditingController();
  final _unitNumber = TextEditingController();
  bool _initialized = false;

  bool get _editing => widget.apartmentId != null;

  @override
  void dispose() {
    _block.dispose();
    _floor.dispose();
    _unitNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ApartmentFormCubit, ApartmentFormState>(
    listener: (context, state) {
      if (state.status == ApartmentFormStatus.loaded && !_initialized) {
        _populate(state.apartment!);
      } else if (state.status == ApartmentFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editing
                  ? 'Apartment updated successfully.'
                  : 'Apartment created successfully.',
            ),
          ),
        );
        context.pop(true);
      } else if (state.status == ApartmentFormStatus.failure &&
          (!_editing || state.apartment != null)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    builder: (context, state) {
      if (_editing &&
          (state.status == ApartmentFormStatus.initial ||
              state.status == ApartmentFormStatus.loading)) {
        return const LoadingView(label: 'Loading apartment');
      }
      if (_editing &&
          state.status == ApartmentFormStatus.failure &&
          state.apartment == null) {
        return ErrorView(
          message: state.failure!.message,
          onRetry: () =>
              context.read<ApartmentFormCubit>().load(widget.apartmentId!),
        );
      }
      final submitting =
          state.status == ApartmentFormStatus.creating ||
          state.status == ApartmentFormStatus.updating;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to apartments',
                onPressed: submitting ? null : () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                _editing ? 'Edit apartment' : 'Add apartment',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const Key('apartmentBlock'),
                          controller: _block,
                          enabled: !submitting,
                          decoration: const InputDecoration(labelText: 'Block'),
                          textCapitalization: TextCapitalization.characters,
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('apartmentFloor'),
                          controller: _floor,
                          enabled: !submitting,
                          decoration: const InputDecoration(labelText: 'Floor'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              int.tryParse(value?.trim() ?? '') == null
                              ? 'Enter a whole number.'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const Key('apartmentUnitNumber'),
                          controller: _unitNumber,
                          enabled: !submitting,
                          decoration: const InputDecoration(
                            labelText: 'Unit number',
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            key: const Key('saveApartmentButton'),
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
                              _editing ? 'Save changes' : 'Create apartment',
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
    },
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  void _populate(Apartment apartment) {
    _block.text = apartment.block;
    _floor.text = apartment.floor.toString();
    _unitNumber.text = apartment.unitNumber;
    _initialized = true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<ApartmentFormCubit>();
    final floor = int.parse(_floor.text.trim());
    if (_editing) {
      unawaited(
        cubit.update(widget.apartmentId!, _block.text, floor, _unitNumber.text),
      );
    } else {
      unawaited(cubit.create(_block.text, floor, _unitNumber.text));
    }
  }
}
