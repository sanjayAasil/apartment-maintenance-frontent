import 'dart:async';

import 'package:apartment_maintenance_frontent/app/theme/app_colors.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_feedback.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_feedback_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceFeedbackSection extends StatefulWidget {
  const MaintenanceFeedbackSection({
    required this.requestId,
    required this.user,
    super.key,
  });

  final String requestId;
  final AppUser? user;

  @override
  State<MaintenanceFeedbackSection> createState() =>
      _MaintenanceFeedbackSectionState();
}

class _MaintenanceFeedbackSectionState
    extends State<MaintenanceFeedbackSection> {
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    unawaited(context.read<MaintenanceFeedbackCubit>().load(widget.requestId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: BlocConsumer<MaintenanceFeedbackCubit, MaintenanceFeedbackState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == MaintenanceFeedbackStatus.submitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thank you for your feedback.')),
            );
          }
        },
        builder: (context, state) {
          final feedback = state.feedback;
          final submitting =
              state.status == MaintenanceFeedbackStatus.submitting;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.user?.role == UserRole.resident
                    ? 'Maintenance feedback'
                    : 'Resident feedback',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (state.status == MaintenanceFeedbackStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (feedback != null)
                _FeedbackView(feedback: feedback)
              else if (state.status == MaintenanceFeedbackStatus.failure &&
                  widget.user?.role != UserRole.resident)
                _FailureView(
                  message: state.failure!.message,
                  onRetry: () => unawaited(
                    context.read<MaintenanceFeedbackCubit>().load(
                      widget.requestId,
                    ),
                  ),
                )
              else if (widget.user?.role != UserRole.resident)
                const Text('No feedback has been submitted.')
              else ...[
                const Text('Rate Maintenance Service'),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Service rating, $_rating of 5 stars selected',
                  child: Wrap(
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        tooltip: '$value ${value == 1 ? 'star' : 'stars'}',
                        onPressed: submitting
                            ? null
                            : () => setState(() => _rating = value),
                        icon: Icon(
                          value <= _rating ? Icons.star : Icons.star_border,
                          color: AppTone.warning.foreground,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  enabled: !submitting,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                if (state.status == MaintenanceFeedbackStatus.failure)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.failure!.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: submitting
                        ? null
                        : () => context.read<MaintenanceFeedbackCubit>().submit(
                            widget.requestId,
                            _rating,
                            _commentController.text,
                          ),
                    icon: submitting
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rate_review_outlined),
                    label: const Text('Submit feedback'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    ),
  );
}

class _FeedbackView extends StatelessWidget {
  const _FeedbackView({required this.feedback});
  final MaintenanceFeedback feedback;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        label: '${feedback.rating} out of 5 stars',
        child: Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < feedback.rating ? Icons.star : Icons.star_border,
              color: AppTone.warning.foreground,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text('Submitted by ${feedback.resident.name}'),
      Text(_date(feedback.createdAt)),
      if (feedback.comment?.isNotEmpty == true) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTone.warning.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(feedback.comment!),
        ),
      ],
    ],
  );

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}-${local.month.toString().padLeft(2, '0')}-${local.year}';
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ],
  );
}
