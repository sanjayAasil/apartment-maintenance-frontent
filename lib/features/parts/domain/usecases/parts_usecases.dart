import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/repositories/parts_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetParts {
  const GetParts(this._repository);
  final PartsRepository _repository;
  Future<PagedParts> call(PartQuery query) => _repository.getParts(query);
}

@injectable
class GetPart {
  const GetPart(this._repository);
  final PartsRepository _repository;
  Future<Part> call(String id) => _repository.getPart(id);
}

@injectable
class CreatePart {
  const CreatePart(this._repository);
  final PartsRepository _repository;
  Future<Part> call({
    required String name,
    String? description,
    required int quantity,
    required double unitPrice,
    required int minimumStock,
  }) => _repository.createPart(
    name: name,
    description: description,
    quantity: quantity,
    unitPrice: unitPrice,
    minimumStock: minimumStock,
  );
}

@injectable
class UpdatePart {
  const UpdatePart(this._repository);
  final PartsRepository _repository;
  Future<Part> call({
    required String id,
    required String name,
    String? description,
    required double unitPrice,
    required int minimumStock,
  }) => _repository.updatePart(
    id: id,
    name: name,
    description: description,
    unitPrice: unitPrice,
    minimumStock: minimumStock,
  );
}

@injectable
class UpdatePartStatus {
  const UpdatePartStatus(this._repository);
  final PartsRepository _repository;
  Future<Part> call(String id, bool value) =>
      _repository.updateStatus(id, value);
}

@injectable
class SetPartStock {
  const SetPartStock(this._repository);
  final PartsRepository _repository;
  Future<Part> call(String id, int quantity) =>
      _repository.setStock(id, quantity);
}
