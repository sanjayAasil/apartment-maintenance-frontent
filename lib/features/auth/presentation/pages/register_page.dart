import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/utils/validators.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/registration_cubit.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/widgets/auth_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<RegistrationCubit>(),
    child: const _RegisterView(),
  );
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();
  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          if (state.status == RegistrationStatus.success) {
            context.read<AuthBloc>().add(AuthUserAuthenticated(state.user!));
          }
        },
        child: AuthCard(
          title: 'Create your account',
          subtitle: 'Registration creates a resident account.',
          child: BlocBuilder<RegistrationCubit, RegistrationState>(
            builder: (context, state) {
              final loading = state.status == RegistrationStatus.loading;
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.failure != null) ...[
                      MaterialBanner(
                        content: Text(state.failure!.message),
                        actions: const [SizedBox.shrink()],
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      key: const Key('registerName'),
                      controller: _name,
                      enabled: !loading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('registerEmail'),
                      controller: _email,
                      enabled: !loading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('registerPassword'),
                      controller: _password,
                      enabled: !loading,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: 'Use at least 8 characters.',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('registerSubmit'),
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: loading ? null : () => context.go('/login'),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    unawaited(
      context.read<RegistrationCubit>().submit(
        _name.text,
        _email.text.trim(),
        _password.text,
      ),
    );
  }
}
