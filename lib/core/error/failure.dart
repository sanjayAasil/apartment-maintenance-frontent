import 'package:equatable/equatable.dart';

enum FailureKind {
  validation,
  unauthenticated,
  forbidden,
  notFound,
  conflict,
  timeout,
  connection,
  server,
  malformedResponse,
  unknown,
}

class Failure extends Equatable implements Exception {
  const Failure({
    required this.kind,
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final FailureKind kind;
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [kind, message, statusCode, fieldErrors];
}
