import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps backend validation messages and field errors', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/users'),
      response: Response(
        requestOptions: RequestOptions(path: '/users'),
        statusCode: 422,
        data: {
          'message': ['email must be an email', 'name should not be empty'],
        },
      ),
    );
    final failure = mapApiError(error);
    expect(failure.kind, FailureKind.validation);
    expect(failure.fieldErrors['email'], 'email must be an email');
    expect(failure.fieldErrors['name'], 'name should not be empty');
  });

  test('maps timeout and connection errors', () {
    final timeout = mapApiError(
      DioException(
        requestOptions: RequestOptions(path: '/users'),
        type: DioExceptionType.receiveTimeout,
      ),
    );
    final connection = mapApiError(
      DioException(
        requestOptions: RequestOptions(path: '/users'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(timeout.kind, FailureKind.timeout);
    expect(connection.kind, FailureKind.connection);
  });
}
