import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:dio/dio.dart';

Failure mapApiError(Object error) {
  if (error is Failure) return error;
  if (error is! DioException) {
    return Failure(kind: FailureKind.unknown, message: error.toString());
  }
  final status = error.response?.statusCode;
  final extracted = _extractMessages(error.response?.data);
  final kind = switch (status) {
    400 || 422 => FailureKind.validation,
    401 => FailureKind.unauthenticated,
    403 => FailureKind.forbidden,
    404 => FailureKind.notFound,
    409 => FailureKind.conflict,
    final code? when code >= 500 => FailureKind.server,
    _
        when error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout =>
      FailureKind.timeout,
    _ when error.type == DioExceptionType.connectionError =>
      FailureKind.connection,
    _ => FailureKind.unknown,
  };
  return Failure(
    kind: kind,
    message: extracted.message ?? _defaultMessage(status, error.type),
    statusCode: status,
    fieldErrors: extracted.fields,
  );
}

({String? message, Map<String, String> fields}) _extractMessages(dynamic data) {
  if (data is! Map) return (message: null, fields: const {});
  final raw = data['message'];
  if (raw is String) return (message: raw, fields: const {});
  if (raw is List) {
    final messages = raw.whereType<String>().toList();
    final fields = <String, String>{};
    for (final item in messages) {
      final match = RegExp(r'^([A-Za-z][A-Za-z0-9_]*)\s').firstMatch(item);
      if (match != null) fields.putIfAbsent(match.group(1)!, () => item);
    }
    return (
      message: messages.isEmpty ? null : messages.join('\n'),
      fields: fields,
    );
  }
  if (data['error'] is String) {
    return (message: data['error'] as String, fields: const {});
  }
  return (message: null, fields: const {});
}

String _defaultMessage(int? status, DioExceptionType type) => switch (status) {
  400 => 'The request is invalid.',
  401 => 'Your session is invalid or has expired.',
  403 => 'You do not have permission to perform this action.',
  404 => 'The requested resource was not found.',
  409 => 'This change conflicts with existing data.',
  422 => 'Some values are invalid.',
  final code? when code >= 500 => 'The server could not complete the request.',
  _
      when type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout =>
    'The request timed out.',
  _ when type == DioExceptionType.connectionError =>
    'Could not connect to the server.',
  _ => 'Something went wrong. Please try again.',
};
