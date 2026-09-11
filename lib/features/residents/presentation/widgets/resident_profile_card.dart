import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:flutter/material.dart';

class ResidentProfileCard extends StatelessWidget {
  const ResidentProfileCard({required this.resident, this.actions, super.key});

  final Resident resident;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              resident.user.name.isEmpty
                  ? '?'
                  : resident.user.name[0].toUpperCase(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            resident.user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(resident.user.email, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          _InfoRow(label: 'Phone', value: resident.phone),
          _InfoRow(
            label: 'Apartment',
            value:
                '${resident.apartment.block}-${resident.apartment.unitNumber}',
          ),
          _InfoRow(label: 'Floor', value: '${resident.apartment.floor}'),
          _InfoRow(
            label: 'Move-in date',
            value: formatResidentDate(resident.moveInDate),
          ),
          _InfoRow(
            label: 'Resident status',
            value: resident.isActive ? 'Active' : 'Inactive',
          ),
          if (actions != null) ...[
            const Divider(height: 36),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

String formatResidentDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
