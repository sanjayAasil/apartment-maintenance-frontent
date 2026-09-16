import 'package:apartment_maintenance_frontent/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.tone = AppTone.neutral,
    this.icon,
    super.key,
  });
  final String label;
  final AppTone tone;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    avatar: icon == null ? null : Icon(icon, size: 15, color: tone.foreground),
    backgroundColor: tone.background,
    labelStyle: TextStyle(
      color: tone.foreground,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    visualDensity: VisualDensity.compact,
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase().replaceAll(' ', '_');
    final tone = switch (normalized) {
      'OPEN' => AppTone.blue,
      'ASSIGNED' => AppTone.purple,
      'IN_PROGRESS' => AppTone.warning,
      'RESOLVED' || 'ACTIVE' || 'AVAILABLE' => AppTone.success,
      'CANCELLED' => AppTone.danger,
      'CLOSED' => AppTone.success,
      _ => AppTone.neutral,
    };
    return AppBadge(
      label: status,
      tone: tone,
      icon: switch (normalized) {
        'RESOLVED' ||
        'CLOSED' ||
        'ACTIVE' ||
        'AVAILABLE' => Icons.check_circle_outline,
        'CANCELLED' => Icons.cancel_outlined,
        'IN_PROGRESS' => Icons.schedule,
        _ => null,
      },
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip(this.priority, {super.key});
  final String priority;
  @override
  Widget build(BuildContext context) => AppBadge(
    label: priority,
    tone: switch (priority.toUpperCase()) {
      'LOW' => AppTone.info,
      'MEDIUM' => AppTone.blue,
      'HIGH' => AppTone.warning,
      'URGENT' => AppTone.danger,
      _ => AppTone.neutral,
    },
    icon: Icons.flag_outlined,
  );
}

class StockChip extends StatelessWidget {
  const StockChip({
    required this.quantity,
    required this.minimumStock,
    super.key,
  });
  final int quantity, minimumStock;
  @override
  Widget build(BuildContext context) => AppBadge(
    label: quantity == 0
        ? 'Out of stock'
        : quantity <= minimumStock
        ? 'Low stock'
        : 'In stock',
    tone: quantity == 0
        ? AppTone.danger
        : quantity <= minimumStock
        ? AppTone.warning
        : AppTone.success,
    icon: Icons.inventory_2_outlined,
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      );
      if (constraints.maxWidth < 500) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: heading),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.lg),
            action!,
          ],
        ],
      );
    },
  );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
    super.key,
  });
  final String title, value;
  final IconData icon;
  final AppTone tone;
  @override
  Widget build(BuildContext context) => Card(
    color: tone.background,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tone.foreground, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              color: tone.foreground,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: tone.foreground,
              fontSize: 32,
            ),
          ),
        ],
      ),
    ),
  );
}
