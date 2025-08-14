import 'package:equatable/equatable.dart';

abstract class FacilityEvent extends Equatable {
  const FacilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadFacilities extends FacilityEvent {
  const LoadFacilities();
  
  @override
  List<Object?> get props => [];
}

class LoadFacilityDetails extends FacilityEvent {
  final String facilityId;
  
  const LoadFacilityDetails({required this.facilityId});
  
  @override
  List<Object?> get props => [facilityId];
} 