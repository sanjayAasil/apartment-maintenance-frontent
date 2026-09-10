import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: TokenStorage)
class BrowserTokenStorage implements TokenStorage {
  BrowserTokenStorage(this._preferences);
  static const _key = 'apartment_maintenance_access_token';
  final SharedPreferences _preferences;

  @override
  Future<void> clear() async => _preferences.remove(_key);

  @override
  Future<String?> read() async => _preferences.getString(_key);

  @override
  Future<void> write(String token) async => _preferences.setString(_key, token);
}
