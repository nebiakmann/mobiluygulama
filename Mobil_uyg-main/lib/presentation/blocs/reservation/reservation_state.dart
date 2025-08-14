part of 'reservation_bloc.dart';

abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class UserReservationsLoaded extends ReservationState {
  final List<ReservationModel> upcomingReservations;
  final List<ReservationModel> pastReservations;
  final Map<String, FacilityModel> facilities;

  const UserReservationsLoaded({
    required this.upcomingReservations,
    required this.pastReservations,
    required this.facilities,
  });

  @override
  List<Object?> get props => [upcomingReservations, pastReservations, facilities];
}

class ReservationCreated extends ReservationState {
  final String reservationId;

  const ReservationCreated({required this.reservationId});

  @override
  List<Object?> get props => [reservationId];
}

class SlotAvailabilityChecked extends ReservationState {
  final bool isAvailable;
  final int currentCount;
  final int maxCapacity;

  const SlotAvailabilityChecked({
    required this.isAvailable,
    required this.currentCount,
    required this.maxCapacity,
  });

  @override
  List<Object?> get props => [isAvailable, currentCount, maxCapacity];
}

class DailyReservationCountsLoaded extends ReservationState {
  final DateTime date;
  final Map<int, int> hourlyCounts;
  final int maxCapacity;

  const DailyReservationCountsLoaded({
    required this.date,
    required this.hourlyCounts,
    required this.maxCapacity,
  });

  @override
  List<Object?> get props => [date, hourlyCounts, maxCapacity];
}

class ReservationError extends ReservationState {
  final String message;

  const ReservationError(this.message);

  @override
  List<Object?> get props => [message];
}

// YENİ EKLENEN CLEANUP STATE'LERİ
class CleanupServiceStatusChanged extends ReservationState {
  final bool isRunning;

  const CleanupServiceStatusChanged({required this.isRunning});

  @override
  List<Object?> get props => [isRunning];
}

class ManualCleanupCompleted extends ReservationState {
  const ManualCleanupCompleted();
}