import 'package:apartment_maintenance_frontent/core/utils/validators.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/widgets/auth_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthCard(
    title: 'Welcome back',
    subtitle: 'Sign in to manage your apartment community.',
    child: BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (before, after) =>
          before.status != after.status || before.failure != after.failure,
      builder: (context, state) {
        final loading = state.status == AuthStatus.authenticating;
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
                key: const Key('loginEmail'),
                controller: _email,
                enabled: !loading,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('loginPassword'),
                controller: _password,
                enabled: !loading,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
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
                key: const Key('loginSubmit'),
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: loading ? null : () => context.go('/register'),
                child: const Text('Create a resident account'),
              ),
            ],
          ),
        );
      },
    ),
  );

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: _email.text.trim(), password: _password.text),
    );
  }
}
