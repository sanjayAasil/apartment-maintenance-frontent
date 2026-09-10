import 'dart:async';

import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SessionCoordinator {
  SessionCoordinator(this._storage);
  final TokenStorage _storage;
  final _invalidations = StreamController<void>.broadcast();
  bool _invalidating = false;

  Stream<void> get invalidations => _invalidations.stream;

  Future<void> invalidate() async {
    if (_invalidating) return;
    _invalidating = true;
    await _storage.clear();
    _invalidations.add(null);
  }

  void reset() => _invalidating = false;
}
