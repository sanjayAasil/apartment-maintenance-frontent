import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/routing/route_access.dart';
import 'package:apartment_maintenance_frontent/core/widgets/pagination_bar.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/presentation/bloc/apartments_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApartmentsPage extends StatelessWidget {
  const ApartmentsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<ApartmentsListBloc>()..add(const ApartmentsRequested()),
    child: const _ApartmentsView(),
  );
}

class _ApartmentsView extends StatefulWidget {
  const _ApartmentsView();

  @override
  State<_ApartmentsView> createState() => _ApartmentsViewState();
}

class _ApartmentsViewState extends State<_ApartmentsView> {
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ApartmentsListBloc, ApartmentsListState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Apartments',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (RouteAccess.canManageApartments(
                    context.select((AuthBloc bloc) => bloc.state.user),
                  ))
                    FilledButton.icon(
                      key: const Key('addApartmentButton'),
                      onPressed: () => unawaited(_openCreate(context)),
                      icon: const Icon(Icons.add),
                      label: const Text('Add apartment'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      key: const Key('apartmentsSearch'),
                      decoration: const InputDecoration(
                        labelText: 'Search block or unit',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(
                          const Duration(milliseconds: 350),
                          () {
                            if (mounted) {
                              context.read<ApartmentsListBloc>().add(
                                ApartmentsSearchChanged(value),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Refresh apartments',
                    onPressed: () => context.read<ApartmentsListBloc>().add(
                      const ApartmentsRequested(),
                    ),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _content(context, state)),
            ],
          ),
        ),
      );

  Widget _content(BuildContext context, ApartmentsListState state) {
    if (state.result == null &&
        (state.status == ApartmentsListStatus.initial ||
            state.status == ApartmentsListStatus.loading)) {
      return const LoadingView(label: 'Loading apartments');
    }
    if (state.status == ApartmentsListStatus.failure && state.result == null) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () =>
            context.read<ApartmentsListBloc>().add(const ApartmentsRequested()),
      );
    }
    if (state.status == ApartmentsListStatus.empty ||
        state.result?.items.isEmpty == true) {
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            EmptyView(message: 'No apartments match the selected filters.'),
          ],
        ),
      );
    }
    final result = state.result;
    if (result == null) {
      return ErrorView(
        message: 'Apartments could not be displayed.',
        onRetry: () =>
            context.read<ApartmentsListBloc>().add(const ApartmentsRequested()),
      );
    }
    final canEdit = RouteAccess.canManageApartments(
      context.read<AuthBloc>().state.user,
    );
    return Column(
      children: [
        if (state.status == ApartmentsListStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: result.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _ApartmentCard(
                apartment: result.items[index],
                canEdit: canEdit,
                onEdit: () =>
                    unawaited(_openEdit(context, result.items[index].id)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: PaginationBar(
            page: result.page,
            totalPages: result.totalPages,
            pageSize: result.pageSize,
            onPageChanged: (page) => context.read<ApartmentsListBloc>().add(
              ApartmentsPageChanged(page),
            ),
            onPageSizeChanged: (size) => context.read<ApartmentsListBloc>().add(
              ApartmentsPageSizeChanged(size),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<ApartmentsListBloc>().add(const ApartmentsRequested());
    await context.read<ApartmentsListBloc>().stream.firstWhere(
      (state) => state.status != ApartmentsListStatus.loading,
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/apartments/new');
    if (created == true && context.mounted) {
      context.read<ApartmentsListBloc>().add(const ApartmentsRequested());
    }
  }

  Future<void> _openEdit(BuildContext context, String id) async {
    final updated = await context.push<bool>('/apartments/$id/edit');
    if (updated == true && context.mounted) {
      context.read<ApartmentsListBloc>().add(const ApartmentsRequested());
    }
  }
}

class _ApartmentCard extends StatelessWidget {
  const _ApartmentCard({
    required this.apartment,
    required this.canEdit,
    required this.onEdit,
  });

  final Apartment apartment;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.apartment)),
      title: Text('Block ${apartment.block}'),
      subtitle: Text('Unit ${apartment.unitNumber}\nFloor ${apartment.floor}'),
      isThreeLine: true,
      trailing: canEdit
          ? IconButton(
              tooltip: 'Edit apartment',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            )
          : null,
    ),
  );
}
