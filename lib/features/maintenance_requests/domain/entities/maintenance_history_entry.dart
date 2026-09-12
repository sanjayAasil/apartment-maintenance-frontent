import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:equatable/equatable.dart';

enum MaintenanceHistoryAction {
  requestCreated('REQUEST_CREATED', 'Request created'),
  requestUpdated('REQUEST_UPDATED', 'Request updated'),
  statusChanged('STATUS_CHANGED', 'Status changed'),
  technicianAssigned('TECHNICIAN_ASSIGNED', 'Technician assigned'),
  technicianReassigned('TECHNICIAN_REASSIGNED', 'Technician reassigned'),
  technicianUnassigned('TECHNICIAN_UNASSIGNED', 'Technician unassigned'),
  commentAdded('COMMENT_ADDED', 'Comment added'),
  categoryChanged('CATEGORY_CHANGED', 'Category changed'),
  priorityChanged('PRIORITY_CHANGED', 'Priority changed'),
  workNoteCreated('WORK_NOTE_CREATED', 'Work note created'),
  workNoteUpdated('WORK_NOTE_UPDATED', 'Work note updated'),
  partAdded('PART_ADDED', 'Part added'),
  partRemoved('PART_REMOVED', 'Part removed'),
  unknown('UNKNOWN', 'Request updated');

  const MaintenanceHistoryAction(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static MaintenanceHistoryAction fromApi(String value) => values.firstWhere(
    (item) => item.apiValue == value,
    orElse: () => unknown,
  );
}

class MaintenanceHistoryEntry extends Equatable {
  const MaintenanceHistoryEntry({
    required this.id,
    required this.maintenanceRequestId,
    required this.action,
    required this.createdAt,
    this.userId,
    this.oldValue,
    this.newValue,
    this.metadata,
    this.actor,
  });

  final String id;
  final String maintenanceRequestId;
  final String? userId;
  final MaintenanceHistoryAction action;
  final String? oldValue;
  final String? newValue;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final MaintenanceActor? actor;

  @override
  List<Object?> get props => [
    id,
    maintenanceRequestId,
    userId,
    action,
    oldValue,
    newValue,
    metadata,
    createdAt,
    actor,
  ];
}
