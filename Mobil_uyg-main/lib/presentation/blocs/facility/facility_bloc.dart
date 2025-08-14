import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spor_salonu/data/models/facility_model.dart';
import 'package:spor_salonu/data/repositories/facility_repository.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_event.dart';
import 'package:spor_salonu/presentation/blocs/facility/facility_state.dart';

class FacilityBloc extends Bloc<FacilityEvent, FacilityState> {
  final FacilityRepository _facilityRepository;
  StreamSubscription<List<FacilityModel>>? _facilitiesSubscription;

  FacilityBloc({required FacilityRepository facilityRepository})
      : _facilityRepository = facilityRepository,
        super(FacilityInitial()) {
    on<LoadFacilities>(_onLoadFacilities);
    on<LoadFacilityDetails>(_onLoadFacilityDetails);
    on<_FacilitiesUpdated>(_onFacilitiesUpdated);
    on<_FacilityError>(_onFacilityError);
  }

  Future<void> _onLoadFacilities(
    LoadFacilities event,
    Emitter<FacilityState> emit,
  ) async {
    emit(FacilityLoading());
    try {
      // Cancel any existing subscription
      await _facilitiesSubscription?.cancel();
      
      // Use the facilities stream with a proper subscription
      _facilitiesSubscription = _facilityRepository.getFacilitiesStream().listen(
        (List<FacilityModel> facilities) {
          if (!isClosed) {
            add(_FacilitiesUpdated(facilities: facilities));
          }
        },
        onError: (error) {
          if (!isClosed) {
            add(_FacilityError(message: error.toString()));
          }
        },
      );
      
      // If stream setup is immediate, try to get initial data directly
      final initialFacilities = await _facilityRepository.getAllFacilities();
      emit(FacilitiesLoaded(facilities: initialFacilities));
    } catch (e) {
      // Fallback to regular method if stream doesn't work
      try {
        final facilities = await _facilityRepository.getAllFacilities();
        emit(FacilitiesLoaded(facilities: facilities));
      } catch (e2) {
        emit(FacilityError(message: e2.toString()));
      }
    }
  }

  Future<void> _onLoadFacilityDetails(
    LoadFacilityDetails event,
    Emitter<FacilityState> emit,
  ) async {
    emit(FacilityLoading());
    try {
      // Use new getFacilityById method
      final facility = await _facilityRepository.getFacilityById(event.facilityId);
      if (facility != null) {
        emit(FacilityDetailsLoaded(facility: facility));
      } else {
        emit(const FacilityError(message: 'Facility not found'));
      }
    } catch (e) {
      emit(FacilityError(message: e.toString()));
    }
  }

  // Handler for facilities updated from stream
  Future<void> _onFacilitiesUpdated(
    _FacilitiesUpdated event,
    Emitter<FacilityState> emit,
  ) async {
    emit(FacilitiesLoaded(facilities: event.facilities));
  }

  // Handler for facility errors
  Future<void> _onFacilityError(
    _FacilityError event,
    Emitter<FacilityState> emit,
  ) async {
    emit(FacilityError(message: event.message));
  }

  @override
  Future<void> close() {
    _facilitiesSubscription?.cancel();
    return super.close();
  }
}

// Private events for internal use
class _FacilitiesUpdated extends FacilityEvent {
  final List<FacilityModel> facilities;
  
  const _FacilitiesUpdated({required this.facilities});
  
  @override
  List<Object> get props => [facilities];
}

class _FacilityError extends FacilityEvent {
  final String message;
  
  const _FacilityError({required this.message});
  
  @override
  List<Object> get props => [message];
} 