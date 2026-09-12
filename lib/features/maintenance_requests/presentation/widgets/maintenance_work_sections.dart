import 'dart:async';

import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_work.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_work_cubit.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceWorkSections extends StatefulWidget {
  const MaintenanceWorkSections({
    required this.request,
    required this.user,
    super.key,
  });
  final MaintenanceRequest request;
  final AppUser? user;
  @override
  State<MaintenanceWorkSections> createState() =>
      _MaintenanceWorkSectionsState();
}

class _MaintenanceWorkSectionsState extends State<MaintenanceWorkSections> {
  bool get editable =>
      widget.user?.role == UserRole.technician &&
      widget.request.status == MaintenanceRequestStatus.inProgress;
  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<MaintenanceWorkCubit>().load(
        widget.request.id,
        loadInventory: editable,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<MaintenanceWorkCubit, MaintenanceWorkState>(
    listener: (context, state) {
      if (state.status == MaintenanceWorkStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repair details updated.')),
        );
      }
      if (state.status == MaintenanceWorkStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    builder: (context, state) {
      if (state.status == MaintenanceWorkStatus.loading && state.cost == null) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      }
      final busy = state.status == MaintenanceWorkStatus.submitting;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Work summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (editable)
                        TextButton.icon(
                          onPressed: busy
                              ? null
                              : () => _editNote(context, state),
                          icon: Icon(
                            state.note == null
                                ? Icons.add
                                : Icons.edit_outlined,
                          ),
                          label: Text(state.note == null ? 'Add note' : 'Edit'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (state.note == null)
                    const Text(
                      'No diagnosis or work summary has been recorded.',
                    )
                  else ...[
                    const Text(
                      'Diagnosis',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(state.note!.diagnosis),
                    const SizedBox(height: 10),
                    const Text(
                      'Work performed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(state.note!.workPerformed),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Parts used',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (editable)
                        TextButton.icon(
                          onPressed: busy
                              ? null
                              : () => _addPart(context, state),
                          icon: const Icon(Icons.add),
                          label: const Text('Add part'),
                        ),
                    ],
                  ),
                  if (state.usages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No parts have been recorded.'),
                    ),
                  ...state.usages.map(
                    (usage) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(usage.part.name),
                      subtitle: Text(
                        '${usage.quantity} × ${_money(usage.unitPrice)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _money(usage.total),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (editable)
                            IconButton(
                              tooltip: 'Remove usage',
                              onPressed: busy
                                  ? null
                                  : () => context
                                        .read<MaintenanceWorkCubit>()
                                        .removePart(usage.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (state.cost != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Cost summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _cost('Parts', state.cost!.partsCost),
                    _cost('Labor', state.cost!.laborCost),
                    _cost('Other', state.cost!.otherCost),
                    const Divider(),
                    _cost('Total', state.cost!.totalCost, strong: true),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _cost(String label, double value, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ),
        Text(
          _money(value),
          style: strong ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    ),
  );
  static String _money(double value) => '₹${value.toStringAsFixed(2)}';

  Future<void> _editNote(
    BuildContext context,
    MaintenanceWorkState state,
  ) async {
    final values = await showDialog<(String, String, double, double)>(
      context: context,
      builder: (_) => _WorkNoteDialog(note: state.note),
    );
    if (values != null && context.mounted) {
      await context.read<MaintenanceWorkCubit>().saveNote(
        diagnosis: values.$1,
        workPerformed: values.$2,
        laborCost: values.$3,
        otherCost: values.$4,
      );
    }
  }

  Future<void> _addPart(
    BuildContext context,
    MaintenanceWorkState state,
  ) async {
    if (state.availableParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active parts are available.')),
      );
      return;
    }
    final result = await showDialog<(String, int)>(
      context: context,
      builder: (_) => _AddPartDialog(parts: state.availableParts),
    );
    if (result != null && context.mounted) {
      await context.read<MaintenanceWorkCubit>().addPart(result.$1, result.$2);
    }
  }
}

class _WorkNoteDialog extends StatefulWidget {
  const _WorkNoteDialog({this.note});
  final MaintenanceWorkNote? note;
  @override
  State<_WorkNoteDialog> createState() => _WorkNoteDialogState();
}

class _WorkNoteDialogState extends State<_WorkNoteDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _diagnosis;
  late final TextEditingController _work;
  late final TextEditingController _labor;
  late final TextEditingController _other;

  @override
  void initState() {
    super.initState();
    _diagnosis = TextEditingController(text: widget.note?.diagnosis);
    _work = TextEditingController(text: widget.note?.workPerformed);
    _labor = TextEditingController(
      text: (widget.note?.laborCost ?? 0).toStringAsFixed(2),
    );
    _other = TextEditingController(
      text: (widget.note?.otherCost ?? 0).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _diagnosis.dispose();
    _work.dispose();
    _labor.dispose();
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.note == null ? 'Add work note' : 'Edit work note'),
    content: SizedBox(
      width: 560,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _diagnosis,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _work,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Work performed'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _labor,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Labor cost',
                      ),
                      validator: _amount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _other,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Other cost',
                      ),
                      validator: _amount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            Navigator.pop(context, (
              _diagnosis.text,
              _work.text,
              double.parse(_labor.text),
              double.parse(_other.text),
            ));
          }
        },
        child: const Text('Save'),
      ),
    ],
  );

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;
  static String? _amount(String? value) {
    final number = double.tryParse(value ?? '');
    return number == null || number < 0 ? 'Enter zero or more.' : null;
  }
}

class _AddPartDialog extends StatefulWidget {
  const _AddPartDialog({required this.parts});
  final List<Part> parts;
  @override
  State<_AddPartDialog> createState() => _AddPartDialogState();
}

class _AddPartDialogState extends State<_AddPartDialog> {
  final _key = GlobalKey<FormState>();
  final _quantity = TextEditingController(text: '1');
  late String _partId = widget.parts.first.id;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.parts.firstWhere((part) => part.id == _partId);
    return AlertDialog(
      title: const Text('Add part used'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _partId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Part'),
                items: widget.parts
                    .map(
                      (part) => DropdownMenuItem(
                        value: part.id,
                        child: Text(
                          '${part.name} — ${part.quantity} available — ${_MaintenanceWorkSectionsState._money(part.unitPrice)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _partId = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantity,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  helperText: 'Available: ${selected.quantity}',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 1) return 'Enter at least 1.';
                  if (parsed > selected.quantity) {
                    return 'Only ${selected.quantity} available.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_key.currentState!.validate()) {
              Navigator.pop(context, (_partId, int.parse(_quantity.text)));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
