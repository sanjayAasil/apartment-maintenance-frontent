import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/utils/validators.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/user_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/user_edit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({required this.userId, super.key});
  final String userId;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<UserDetailsBloc>()..add(UserDetailsRequested(userId)),
      ),
      BlocProvider(create: (_) => getIt<UserEditCubit>()),
    ],
    child: _UserDetailsView(userId: userId),
  );
}

class _UserDetailsView extends StatelessWidget {
  const _UserDetailsView({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) =>
      BlocListener<UserEditCubit, UserEditState>(
        listener: (context, state) {
          if (state.status == UserEditStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully.')),
            );
            context.read<UserDetailsBloc>().add(
              UserDetailsRequested(state.user!.id),
            );
          } else if (state.status == UserEditStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
          }
        },
        child: BlocBuilder<UserDetailsBloc, UserDetailsState>(
          builder: (context, state) {
            if (state.status == UserDetailsStatus.loading ||
                state.status == UserDetailsStatus.initial) {
              return const LoadingView(label: 'Loading user details');
            }
            if (state.status == UserDetailsStatus.failure) {
              return ErrorView(
                message: state.failure!.message,
                onRetry: () => context.read<UserDetailsBloc>().add(
                  UserDetailsRequested(userId),
                ),
              );
            }
            return _UserDetailsContent(user: state.user!);
          },
        ),
      );
}

class _UserDetailsContent extends StatelessWidget {
  const _UserDetailsContent({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Back to users',
            onPressed: () => context.go('/users'),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'User details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(user.email, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(label: Text(user.role.apiValue)),
                      Chip(label: Text(user.isActive ? 'Active' : 'Inactive')),
                    ],
                  ),
                  const Divider(height: 40),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _toggleStatus(context),
                        icon: Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                        ),
                        label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _edit(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit user'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Future<void> _toggleStatus(BuildContext context) async {
    final confirmed = await showConfirmation(
      context,
      title: user.isActive ? 'Deactivate user?' : 'Activate user?',
      message: user.isActive
          ? '${user.name} will no longer be able to sign in.'
          : '${user.name} will be allowed to sign in again.',
      confirmLabel: user.isActive ? 'Deactivate' : 'Activate',
    );
    if (confirmed && context.mounted) {
      await context.read<UserEditCubit>().setActive(user.id, !user.isActive);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final result = await showDialog<_EditResult>(
      context: context,
      builder: (_) => _EditUserDialog(user: user),
    );
    if (result != null && context.mounted) {
      await context.read<UserEditCubit>().update(
        user.id,
        result.name,
        result.email,
        result.role,
      );
    }
  }
}

class _EditResult {
  const _EditResult(this.name, this.email, this.role);
  final String name;
  final String email;
  final UserRole role;
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({required this.user});
  final AppUser user;
  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late UserRole _role;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.name);
    _email = TextEditingController(text: widget.user.email);
    _role = widget.user.role;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit user'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: UserRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.apiValue),
                    ),
                  )
                  .toList(),
              onChanged: (role) {
                if (role != null) _role = role;
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
          if (_key.currentState?.validate() == true) {
            Navigator.pop(context, _EditResult(_name.text, _email.text, _role));
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
