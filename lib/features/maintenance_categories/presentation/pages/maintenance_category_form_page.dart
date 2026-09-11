import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_category_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MaintenanceCategoryFormPage extends StatelessWidget {
  const MaintenanceCategoryFormPage({this.categoryId, super.key});
  final String? categoryId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = getIt<MaintenanceCategoryFormCubit>();
      if (categoryId != null) unawaited(cubit.load(categoryId!));
      return cubit;
    },
    child: _MaintenanceCategoryFormView(categoryId: categoryId),
  );
}

class _MaintenanceCategoryFormView extends StatefulWidget {
  const _MaintenanceCategoryFormView({required this.categoryId});
  final String? categoryId;
  @override
  State<_MaintenanceCategoryFormView> createState() =>
      _MaintenanceCategoryFormViewState();
}

class _MaintenanceCategoryFormViewState
    extends State<_MaintenanceCategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  bool _initialized = false;
  bool get _editing => widget.categoryId != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<MaintenanceCategoryFormCubit, MaintenanceCategoryFormState>(
        listener: (context, state) {
          if (state.status == MaintenanceCategoryFormStatus.loaded &&
              !_initialized) {
            _populate(state.category!);
          } else if (state.status == MaintenanceCategoryFormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _editing
                      ? 'Category updated successfully.'
                      : 'Category created successfully.',
                ),
              ),
            );
            context.pop(true);
          } else if (state.status == MaintenanceCategoryFormStatus.failure &&
              (!_editing || state.category != null)) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
          }
        },
        builder: (context, state) {
          if (_editing &&
              (state.status == MaintenanceCategoryFormStatus.initial ||
                  state.status == MaintenanceCategoryFormStatus.loading)) {
            return const LoadingView(label: 'Loading category');
          }
          if (_editing &&
              state.status == MaintenanceCategoryFormStatus.failure &&
              state.category == null) {
            return ErrorView(
              message: state.failure!.message,
              onRetry: () => context.read<MaintenanceCategoryFormCubit>().load(
                widget.categoryId!,
              ),
            );
          }
          final submitting =
              state.status == MaintenanceCategoryFormStatus.submitting;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back to categories',
                    onPressed: submitting ? null : () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _editing ? 'Edit category' : 'Add category',
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
                            TextFormField(
                              key: const Key('categoryName'),
                              controller: _name,
                              enabled: !submitting,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              textCapitalization: TextCapitalization.words,
                              maxLength: 100,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Category name is required.'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: const Key('categoryDescription'),
                              controller: _description,
                              enabled: !submitting,
                              decoration: const InputDecoration(
                                labelText: 'Description (optional)',
                              ),
                              maxLength: 500,
                              minLines: 3,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                key: const Key('saveCategoryButton'),
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
                                  _editing ? 'Save changes' : 'Create category',
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

  void _populate(MaintenanceCategory category) {
    _name.text = category.name;
    _description.text = category.description ?? '';
    _initialized = true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final description = _description.text.trim();
    final cubit = context.read<MaintenanceCategoryFormCubit>();
    if (_editing) {
      unawaited(cubit.update(widget.categoryId!, _name.text, description));
    } else {
      unawaited(cubit.create(_name.text, description));
    }
  }
}
