import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/usecases/parts_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum PartFormStatus { initial, loading, loaded, submitting, success, failure }

class PartFormState extends Equatable {
  const PartFormState({
    this.status = PartFormStatus.initial,
    this.part,
    this.failure,
  });
  final PartFormStatus status;
  final Part? part;
  final Failure? failure;
  @override
  List<Object?> get props => [status, part, failure];
}

@injectable
class PartFormCubit extends Cubit<PartFormState> {
  PartFormCubit(
    this._get,
    this._create,
    this._update,
    this._status,
    this._stock,
  ) : super(const PartFormState());
  final GetPart _get;
  final CreatePart _create;
  final UpdatePart _update;
  final UpdatePartStatus _status;
  final SetPartStock _stock;
  Future<void> load(String id) async {
    emit(const PartFormState(status: PartFormStatus.loading));
    try {
      emit(PartFormState(status: PartFormStatus.loaded, part: await _get(id)));
    } catch (error) {
      emit(
        PartFormState(
          status: PartFormStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> create({
    required String name,
    String? description,
    required int quantity,
    required double unitPrice,
    required int minimumStock,
  }) => _submit(
    () => _create(
      name: name,
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
      minimumStock: minimumStock,
    ),
  );
  Future<void> update({
    required String id,
    required String name,
    String? description,
    required double unitPrice,
    required int minimumStock,
  }) => _submit(
    () => _update(
      id: id,
      name: name,
      description: description,
      unitPrice: unitPrice,
      minimumStock: minimumStock,
    ),
  );
  Future<void> updateStatus(String id, bool value) =>
      _submit(() => _status(id, value));
  Future<void> setStock(String id, int quantity) =>
      _submit(() => _stock(id, quantity));
  Future<void> _submit(Future<Part> Function() action) async {
    final previous = state.part;
    emit(PartFormState(status: PartFormStatus.submitting, part: previous));
    try {
      emit(PartFormState(status: PartFormStatus.success, part: await action()));
    } catch (error) {
      emit(
        PartFormState(
          status: PartFormStatus.failure,
          part: previous,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
