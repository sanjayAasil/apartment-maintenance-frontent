import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/create_apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/update_apartment.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum ApartmentFormStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  success,
  failure,
}

class ApartmentFormState extends Equatable {
  const ApartmentFormState({
    this.status = ApartmentFormStatus.initial,
    this.apartment,
    this.failure,
  });

  final ApartmentFormStatus status;
  final Apartment? apartment;
  final Failure? failure;

  @override
  List<Object?> get props => [status, apartment, failure];
}

@injectable
class ApartmentFormCubit extends Cubit<ApartmentFormState> {
  ApartmentFormCubit(this._getApartment, this._create, this._update)
    : super(const ApartmentFormState());

  final GetApartment _getApartment;
  final CreateApartment _create;
  final UpdateApartment _update;

  Future<void> load(String id) async {
    emit(const ApartmentFormState(status: ApartmentFormStatus.loading));
    try {
      emit(
        ApartmentFormState(
          status: ApartmentFormStatus.loaded,
          apartment: await _getApartment(id),
        ),
      );
    } catch (error) {
      emit(
        ApartmentFormState(
          status: ApartmentFormStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> create(String block, int floor, String unitNumber) async {
    emit(const ApartmentFormState(status: ApartmentFormStatus.creating));
    try {
      emit(
        ApartmentFormState(
          status: ApartmentFormStatus.success,
          apartment: await _create(block, floor, unitNumber),
        ),
      );
    } catch (error) {
      emit(
        ApartmentFormState(
          status: ApartmentFormStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> update(
    String id,
    String block,
    int floor,
    String unitNumber,
  ) async {
    emit(
      ApartmentFormState(
        status: ApartmentFormStatus.updating,
        apartment: state.apartment,
      ),
    );
    try {
      emit(
        ApartmentFormState(
          status: ApartmentFormStatus.success,
          apartment: await _update(id, block, floor, unitNumber),
        ),
      );
    } catch (error) {
      emit(
        ApartmentFormState(
          status: ApartmentFormStatus.failure,
          apartment: state.apartment,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
