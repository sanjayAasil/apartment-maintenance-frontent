import 'package:apartment_maintenance_frontent/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ngrok browser-warning detection', () {
    for (final host in [
      'unloaded-shimmy-secluding.ngrok-free.dev',
      'example.ngrok-free.app',
      'example.ngrok.app',
      'example.ngrok.dev',
      'example.ngrok.io',
      'EXAMPLE.NGROK-FREE.DEV',
    ]) {
      test('recognizes $host', () {
        expect(AppConfig.isNgrokHost(host), isTrue);
      });
    }

    for (final host in [
      'localhost',
      'api.example.com',
      'notngrok-free.dev',
      'example.ngrok-free.dev.attacker.test',
    ]) {
      test('does not treat $host as ngrok', () {
        expect(AppConfig.isNgrokHost(host), isFalse);
      });
    }
  });
}
