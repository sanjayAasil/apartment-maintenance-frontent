import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/users_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<UsersListBloc>()..add(const UsersRequested()),
    child: const _UsersView(),
  );
}

class _UsersView extends StatefulWidget {
  const _UsersView();
  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  Timer? _searchDebounce;
  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<UsersListBloc, UsersListState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Users', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              _filters(context, state),
              const SizedBox(height: 16),
              Expanded(child: _content(context, state)),
            ],
          ),
        ),
      );

  Widget _filters(BuildContext context, UsersListState state) => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SizedBox(
        width: 300,
        child: TextField(
          key: const Key('usersSearch'),
          decoration: const InputDecoration(
            labelText: 'Search name or email',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _searchDebounce?.cancel();
            _searchDebounce = Timer(const Duration(milliseconds: 350), () {
              if (mounted) {
                context.read<UsersListBloc>().add(UsersSearchChanged(value));
              }
            });
          },
        ),
      ),
      DropdownMenu<UserRole?>(
        width: 190,
        label: const Text('Role'),
        initialSelection: state.query.role,
        onSelected: (role) =>
            context.read<UsersListBloc>().add(UsersRoleChanged(role)),
        dropdownMenuEntries: [
          const DropdownMenuEntry(value: null, label: 'All roles'),
          ...UserRole.values.map(
            (role) => DropdownMenuEntry(value: role, label: role.apiValue),
          ),
        ],
      ),
      DropdownMenu<bool?>(
        width: 180,
        label: const Text('Status'),
        initialSelection: state.query.isActive,
        onSelected: (active) =>
            context.read<UsersListBloc>().add(UsersActiveChanged(active)),
        dropdownMenuEntries: const [
          DropdownMenuEntry(value: null, label: 'All statuses'),
          DropdownMenuEntry(value: true, label: 'Active'),
          DropdownMenuEntry(value: false, label: 'Inactive'),
        ],
      ),
      IconButton.filledTonal(
        tooltip: 'Refresh users',
        onPressed: () =>
            context.read<UsersListBloc>().add(const UsersRequested()),
        icon: const Icon(Icons.refresh),
      ),
    ],
  );

  Widget _content(BuildContext context, UsersListState state) {
    if (state.result == null &&
        (state.status == UsersListStatus.initial ||
            state.status == UsersListStatus.loading)) {
      return const LoadingView(label: 'Loading users');
    }
    if (state.status == UsersListStatus.failure && state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () =>
            context.read<UsersListBloc>().add(const UsersRequested()),
      );
    }
    if (state.status == UsersListStatus.empty ||
        state.result?.items.isEmpty == true) {
      return const EmptyView(message: 'No users match the selected filters.');
    }
    final result = state.result;
    if (result == null) {
      return ErrorView(
        message: 'Users could not be displayed.',
        onRetry: () =>
            context.read<UsersListBloc>().add(const UsersRequested()),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (state.status == UsersListStatus.loading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: result.items
                      .map(
                        (user) => DataRow(
                          onSelectChanged: (_) =>
                              context.go('/users/${user.id}'),
                          cells: [
                            DataCell(Text(user.name)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.role.apiValue)),
                            DataCell(_StatusChip(active: user.isActive)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: PaginationBar(
              page: result.page,
              totalPages: result.totalPages,
              pageSize: result.pageSize,
              onPageChanged: (page) =>
                  context.read<UsersListBloc>().add(UsersPageChanged(page)),
              onPageSizeChanged: (size) =>
                  context.read<UsersListBloc>().add(UsersPageSizeChanged(size)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(active ? Icons.check_circle : Icons.block, size: 18),
    label: Text(active ? 'Active' : 'Inactive'),
  );
}
