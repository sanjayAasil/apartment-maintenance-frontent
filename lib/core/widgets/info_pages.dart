import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user)!;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Signed in as ${user.role.apiValue.toLowerCase()}.'),
                const SizedBox(height: 16),
                const Text(
                  'Apartment and maintenance modules will appear here after '
                  'their backend contracts are available.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 64),
          const SizedBox(height: 16),
          Text(
            'Access denied',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('You do not have permission to view this page.'),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to overview'),
          ),
        ],
      ),
    ),
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('404', style: Theme.of(context).textTheme.displayLarge),
          const Text('The page you requested does not exist.'),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Go home'),
          ),
        ],
      ),
    ),
  );
}
