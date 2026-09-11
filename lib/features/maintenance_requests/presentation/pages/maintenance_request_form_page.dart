import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MaintenanceRequestFormPage extends StatelessWidget {
  const MaintenanceRequestFormPage({this.requestId, super.key});
  final String? requestId;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = getIt<MaintenanceRequestFormCubit>();
      unawaited(cubit.load(id: requestId));
      return cubit;
    },
    child: _MaintenanceRequestFormView(requestId: requestId),
  );
}

class _MaintenanceRequestFormView extends StatefulWidget {
  const _MaintenanceRequestFormView({this.requestId});
  final String? requestId;
  @override
  State<_MaintenanceRequestFormView> createState() =>
      _MaintenanceRequestFormViewState();
}

class _MaintenanceRequestFormViewState
    extends State<_MaintenanceRequestFormView> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _categoryId;
  MaintenancePriority _priority = MaintenancePriority.medium;
  bool _initialized = false;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<MaintenanceRequestFormCubit, MaintenanceRequestFormState>(
    listener: (context, state) {
      if (!_initialized &&
          state.status == MaintenanceRequestFormStatus.loaded) {
        final item = state.request;
        _title.text = item?.title ?? '';
        _description.text = item?.description ?? '';
        _categoryId = item?.categoryId;
        _priority = item?.priority ?? MaintenancePriority.medium;
        _initialized = true;
        setState(() {});
      }
      if (state.status == MaintenanceRequestFormStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.requestId == null
                  ? 'Maintenance request created.'
                  : 'Maintenance request updated.',
            ),
          ),
        );
        context.go('/maintenance-requests/${state.request!.id}');
      }
      if (state.status == MaintenanceRequestFormStatus.failure &&
          _initialized) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
      }
    },
    builder: (context, state) {
      if (!_initialized &&
          (state.status == MaintenanceRequestFormStatus.initial ||
              state.status == MaintenanceRequestFormStatus.loading)) {
        return const LoadingView(label: 'Loading request form');
      }
      if (!_initialized &&
          state.status == MaintenanceRequestFormStatus.failure) {
        return ErrorView(
          message: state.failure!.message,
          onRetry: () => context.read<MaintenanceRequestFormCubit>().load(
            id: widget.requestId,
          ),
        );
      }
      final submitting =
          state.status == MaintenanceRequestFormStatus.submitting;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 720,
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.requestId == null
                        ? 'New Maintenance Request'
                        : 'Edit Maintenance Request',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: state.categories
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                    onChanged: submitting
                        ? null
                        : (value) => setState(() => _categoryId = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    maxLength: 120,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3) return 'Enter at least 3 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 2000,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 10) {
                        return 'Enter at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MaintenancePriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: MaintenancePriority.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: submitting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: submitting ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: submitting ? null : _submit,
                        child: Text(submitting ? 'Saving…' : 'Save request'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  void _submit() {
    if (!_key.currentState!.validate() || _categoryId == null) return;
    final cubit = context.read<MaintenanceRequestFormCubit>();
    if (widget.requestId == null) {
      unawaited(
        cubit.create(_categoryId!, _title.text, _description.text, _priority),
      );
    } else {
      unawaited(
        cubit.update(
          widget.requestId!,
          _categoryId!,
          _title.text,
          _description.text,
          _priority,
        ),
      );
    }
  }
}
