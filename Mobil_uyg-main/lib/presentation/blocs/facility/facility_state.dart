import 'package:equatable/equatable.dart';
import 'package:spor_salonu/data/models/facility_model.dart';

abstract class FacilityState extends Equatable {
  const FacilityState();

  @override
  List<Object?> get props => [];
}

class FacilityInitial extends FacilityState {}

class FacilityLoading extends FacilityState {}

class FacilitiesLoaded extends FacilityState {
  final List<FacilityModel> facilities;

  const FacilitiesLoaded({required this.facilities});

  @override
  List<Object?> get props => [facilities];
}

class FacilityDetailsLoaded extends FacilityState {
  final FacilityModel facility;

  const FacilityDetailsLoaded({required this.facility});

  @override
  List<Object?> get props => [facility];
}

class FacilityError extends FacilityState {
  final String message;

  const FacilityError({required this.message});

  @override
  List<Object?> get props => [message];
} 