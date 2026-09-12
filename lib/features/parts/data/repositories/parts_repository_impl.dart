import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/datasources/parts_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/models/part_model.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/repositories/parts_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PartsRepository)
class PartsRepositoryImpl implements PartsRepository {
  const PartsRepositoryImpl(this._remote);
  final PartsRemoteDataSource _remote;
  @override
  Future<PagedParts> getParts(PartQuery query) async {
    try {
      final result = await _remote.getParts(query);
      return PagedParts(
        items: result.items
            .map((item) => item.toEntity())
            .toList(growable: false),
        total: result.total,
        page: result.page,
        pageSize: result.limit,
      );
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Part> getPart(String id) => _map(() => _remote.getPart(id));
  @override
  Future<Part> createPart({
    required String name,
    String? description,
    required int quantity,
    required double unitPrice,
    required int minimumStock,
  }) => _map(
    () => _remote.createPart({
      'name': name.trim(),
      'description': description?.trim(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'minimumStock': minimumStock,
    }),
  );
  @override
  Future<Part> updatePart({
    required String id,
    required String name,
    String? description,
    required double unitPrice,
    required int minimumStock,
  }) => _map(
    () => _remote.updatePart(id, {
      'name': name.trim(),
      'description': description?.trim(),
      'unitPrice': unitPrice,
      'minimumStock': minimumStock,
    }),
  );
  @override
  Future<Part> updateStatus(String id, bool isActive) =>
      _map(() => _remote.updateStatus(id, isActive));
  @override
  Future<Part> setStock(String id, int quantity) =>
      _map(() => _remote.setStock(id, quantity));

  Future<Part> _map(Future<PartModel> Function() action) async {
    try {
      return (await action()).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
