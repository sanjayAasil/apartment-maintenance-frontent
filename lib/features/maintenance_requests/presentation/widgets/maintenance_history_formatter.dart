import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';

String maintenanceHistoryDescription(MaintenanceHistoryEntry entry) {
  final metadata = entry.metadata ?? const <String, dynamic>{};
  switch (entry.action) {
    case MaintenanceHistoryAction.requestCreated:
      return 'Request created';
    case MaintenanceHistoryAction.requestUpdated:
      final fields = (metadata['fields'] as List?)?.cast<String>() ?? const [];
      return fields.isEmpty
          ? 'Request details updated'
          : 'Updated ${fields.join(' and ')}';
    case MaintenanceHistoryAction.statusChanged:
      return 'Status changed from ${_readable(entry.oldValue)} to ${_readable(entry.newValue)}';
    case MaintenanceHistoryAction.technicianAssigned:
      return '${metadata['technicianName'] ?? 'Technician'} assigned';
    case MaintenanceHistoryAction.technicianReassigned:
      return 'Reassigned from ${metadata['previousTechnicianName'] ?? 'previous technician'} to ${metadata['technicianName'] ?? 'new technician'}';
    case MaintenanceHistoryAction.technicianUnassigned:
      return '${metadata['technicianName'] ?? 'Technician'} unassigned';
    case MaintenanceHistoryAction.commentAdded:
      return 'Comment added';
    case MaintenanceHistoryAction.categoryChanged:
      return 'Category changed from ${metadata['previousCategoryName'] ?? 'previous category'} to ${metadata['categoryName'] ?? 'new category'}';
    case MaintenanceHistoryAction.priorityChanged:
      return 'Priority changed from ${_readable(entry.oldValue)} to ${_readable(entry.newValue)}';
    case MaintenanceHistoryAction.unknown:
      return 'Request updated';
  }
}

String _readable(String? value) {
  if (value == null || value.isEmpty) return 'none';
  return value
      .toLowerCase()
      .split('_')
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
