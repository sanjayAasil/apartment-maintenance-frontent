import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';

abstract interface class PartsRepository {
  Future<PagedParts> getParts(PartQuery query);
  Future<Part> getPart(String id);
  Future<Part> createPart({
    required String name,
    String? description,
    required int quantity,
    required double unitPrice,
    required int minimumStock,
  });
  Future<Part> updatePart({
    required String id,
    required String name,
    String? description,
    required double unitPrice,
    required int minimumStock,
  });
  Future<Part> updateStatus(String id, bool isActive);
  Future<Part> setStock(String id, int quantity);
}
