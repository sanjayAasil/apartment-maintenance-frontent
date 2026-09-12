import 'dart:async';

import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_comments_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_history_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/widgets/maintenance_history_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceActivitySections extends StatefulWidget {
  const MaintenanceActivitySections({required this.requestId, super.key});
  final String requestId;

  @override
  State<MaintenanceActivitySections> createState() =>
      _MaintenanceActivitySectionsState();
}

class _MaintenanceActivitySectionsState
    extends State<MaintenanceActivitySections> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<MaintenanceCommentsCubit>().load(widget.requestId));
    unawaited(context.read<MaintenanceHistoryCubit>().load(widget.requestId));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final comments = _CommentsCard(requestId: widget.requestId);
      final history = _HistoryCard(requestId: widget.requestId);
      if (constraints.maxWidth >= 760) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: comments),
            const SizedBox(width: 12),
            Expanded(child: history),
          ],
        );
      }
      return Column(children: [comments, const SizedBox(height: 12), history]);
    },
  );
}

class _CommentsCard extends StatefulWidget {
  const _CommentsCard({required this.requestId});
  final String requestId;

  @override
  State<_CommentsCard> createState() => _CommentsCardState();
}

class _CommentsCardState extends State<_CommentsCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: BlocConsumer<MaintenanceCommentsCubit, MaintenanceCommentsState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == MaintenanceCommentsStatus.submitSuccess) {
            _controller.clear();
            unawaited(
              context.read<MaintenanceHistoryCubit>().load(widget.requestId),
            );
          }
        },
        builder: (context, state) {
          final submitting =
              state.status == MaintenanceCommentsStatus.submitting;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Comments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (state.status == MaintenanceCommentsStatus.loading &&
                  state.comments.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.status == MaintenanceCommentsStatus.failure &&
                  state.comments.isEmpty)
                _InlineFailure(
                  message: state.failure!.message,
                  onRetry: () => unawaited(
                    context.read<MaintenanceCommentsCubit>().load(
                      widget.requestId,
                    ),
                  ),
                )
              else if (state.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No comments yet.'),
                )
              else
                ...state.comments.map(_CommentTile.new),
              const Divider(height: 28),
              TextField(
                controller: _controller,
                enabled: !submitting,
                minLines: 2,
                maxLines: 4,
                maxLength: 2000,
                decoration: InputDecoration(
                  labelText: 'Add a comment',
                  alignLabelWithHint: true,
                  errorText:
                      state.status == MaintenanceCommentsStatus.failure &&
                          state.failure?.kind == FailureKind.validation
                      ? state.failure!.message
                      : null,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: submitting
                      ? null
                      : () => context.read<MaintenanceCommentsCubit>().add(
                          widget.requestId,
                          _controller.text,
                        ),
                  icon: submitting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text('Send'),
                ),
              ),
              if (state.status == MaintenanceCommentsStatus.failure &&
                  state.comments.isNotEmpty &&
                  state.failure?.kind != FailureKind.validation)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.failure!.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _CommentTile extends StatelessWidget {
  const _CommentTile(this.comment);
  final MaintenanceComment comment;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(child: Text(comment.author.name.substring(0, 1))),
    title: Text('${comment.author.name} · ${_role(comment.author.role.name)}'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_timestamp(comment.createdAt)),
        const SizedBox(height: 4),
        Text(comment.message, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<MaintenanceHistoryCubit, MaintenanceHistoryState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Maintenance history',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (state.status == MaintenanceHistoryStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (state.status == MaintenanceHistoryStatus.failure)
              _InlineFailure(
                message: state.failure!.message,
                onRetry: () => unawaited(
                  context.read<MaintenanceHistoryCubit>().load(requestId),
                ),
              )
            else if (state.entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No history recorded yet.'),
              )
            else
              ...state.entries.map(_HistoryTile.new),
          ],
        ),
      ),
    ),
  );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.entry);
  final MaintenanceHistoryEntry entry;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.history),
    title: Text(maintenanceHistoryDescription(entry)),
    subtitle: Text(
      '${_timestamp(entry.createdAt)}${entry.actor == null ? '' : ' · ${entry.actor!.name}'}',
    ),
  );
}

class _InlineFailure extends StatelessWidget {
  const _InlineFailure({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ],
  );
}

String _timestamp(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}-${local.month.toString().padLeft(2, '0')}-${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String _role(String role) => '${role[0].toUpperCase()}${role.substring(1)}';
