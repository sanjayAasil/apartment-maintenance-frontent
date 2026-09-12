import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/presentation/bloc/part_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PartFormPage extends StatelessWidget {
  const PartFormPage({this.partId, super.key});
  final String? partId;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = getIt<PartFormCubit>();
      if (partId != null) unawaited(cubit.load(partId!));
      return cubit;
    },
    child: _PartForm(partId: partId),
  );
}

class _PartForm extends StatefulWidget {
  const _PartForm({this.partId});
  final String? partId;
  @override
  State<_PartForm> createState() => _PartFormState();
}

class _PartFormState extends State<_PartForm> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController(text: '0');
  final _price = TextEditingController();
  final _minimum = TextEditingController(text: '0');
  bool _initialized = false;
  bool get editing => widget.partId != null;
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _quantity.dispose();
    _price.dispose();
    _minimum.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<PartFormCubit, PartFormState>(
    listener: (context, state) {
      if (state.status == PartFormStatus.loaded && !_initialized) {
        _populate(state.part!);
      }
      if (state.status == PartFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(editing ? 'Part updated.' : 'Part created.')),
        );
        context.pop(true);
      } else if (state.status == PartFormStatus.failure &&
          (!editing || state.part != null)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    builder: (context, state) {
      if (editing &&
          (state.status == PartFormStatus.initial ||
              state.status == PartFormStatus.loading)) {
        return const LoadingView(label: 'Loading part');
      }
      if (editing &&
          state.status == PartFormStatus.failure &&
          state.part == null) {
        return ErrorView(
          message: state.failure!.message,
          onRetry: () => context.read<PartFormCubit>().load(widget.partId!),
        );
      }
      final busy = state.status == PartFormStatus.submitting;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: busy ? null : context.pop,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                editing ? 'Edit part' : 'Add part',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _key,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _name,
                          enabled: !busy,
                          maxLength: 120,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: _required,
                        ),
                        TextFormField(
                          controller: _description,
                          enabled: !busy,
                          maxLength: 500,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                          ),
                        ),
                        Row(
                          children: [
                            if (!editing)
                              Expanded(
                                child: TextFormField(
                                  controller: _quantity,
                                  enabled: !busy,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Opening stock',
                                  ),
                                  validator: _whole,
                                ),
                              ),
                            if (!editing) const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _price,
                                enabled: !busy,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Unit price (₹)',
                                ),
                                validator: _money,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _minimum,
                                enabled: !busy,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Minimum stock',
                                ),
                                validator: _whole,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: busy ? null : _submit,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(
                              editing ? 'Save changes' : 'Create part',
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
      value == null || value.trim().isEmpty ? 'Required.' : null;
  String? _whole(String? value) {
    final number = int.tryParse(value ?? '');
    return number == null || number < 0 ? 'Enter zero or more.' : null;
  }

  String? _money(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number < 0 ? 'Enter a valid amount.' : null;
  }

  void _populate(Part part) {
    _name.text = part.name;
    _description.text = part.description ?? '';
    _price.text = part.unitPrice.toStringAsFixed(2);
    _minimum.text = '${part.minimumStock}';
    _initialized = true;
  }

  void _submit() {
    if (!_key.currentState!.validate()) return;
    final cubit = context.read<PartFormCubit>();
    if (editing) {
      unawaited(
        cubit.update(
          id: widget.partId!,
          name: _name.text,
          description: _description.text,
          unitPrice: double.parse(_price.text),
          minimumStock: int.parse(_minimum.text),
        ),
      );
    } else {
      unawaited(
        cubit.create(
          name: _name.text,
          description: _description.text,
          quantity: int.parse(_quantity.text),
          unitPrice: double.parse(_price.text),
          minimumStock: int.parse(_minimum.text),
        ),
      );
    }
  }
}
