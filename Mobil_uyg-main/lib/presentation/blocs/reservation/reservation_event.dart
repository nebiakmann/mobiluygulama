part of 'reservation_bloc.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserReservations extends ReservationEvent {
  final String userId;

  const LoadUserReservations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateReservation extends ReservationEvent {
  final String facilityId;
  final DateTime date;
  final int hourSlot;

  const CreateReservation({
    required this.facilityId,
    required this.date,
    required this.hourSlot,
  });

  @override
  List<Object?> get props => [facilityId, date, hourSlot];
}

class CancelReservation extends ReservationEvent {
  final String reservationId;

  const CancelReservation({required this.reservationId});

  @override
  List<Object?> get props => [reservationId];
}

class CheckSlotAvailability extends ReservationEvent {
  final String facilityId;
  final DateTime date;
  final int hourSlot;

  const CheckSlotAvailability({
    required this.facilityId,
    required this.date,
    required this.hourSlot,
  });

  @override
  List<Object?> get props => [facilityId, date, hourSlot];
}

class LoadDailyReservationCounts extends ReservationEvent {
  final String facilityId;
  final DateTime date;

  const LoadDailyReservationCounts({
    required this.facilityId,
    required this.date,
  });

  @override
  List<Object?> get props => [facilityId, date];
}

class _ReservationsUpdated extends ReservationEvent {
  final List<ReservationModel> reservations;
  final Map<String, FacilityModel> facilities;

  const _ReservationsUpdated({
    required this.reservations,
    required this.facilities,
  });

  @override
  List<Object?> get props => [reservations, facilities];
}

// YENİ EKLENEN CLEANUP EVENT'LERİ
class StartCleanupService extends ReservationEvent {
  const StartCleanupService();
}

class StopCleanupService extends ReservationEvent {
  const StopCleanupService();
}

class PerformManualCleanup extends ReservationEvent {
  const PerformManualCleanup();
}