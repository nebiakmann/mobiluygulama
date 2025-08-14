import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spor_salonu/data/models/reservation_model.dart';
import 'package:spor_salonu/data/models/facility_model.dart';
import 'package:spor_salonu/data/repositories/reservation_repository.dart';
import 'package:spor_salonu/data/repositories/facility_repository.dart';
import 'package:spor_salonu/services/reservation_cleanup_service.dart';

part 'reservation_event.dart';
part 'reservation_state.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository _reservationRepository;
  final FacilityRepository _facilityRepository;
  late final ReservationCleanupService _cleanupService; // late ile tanımla
  StreamSubscription<List<ReservationModel>>? _reservationsSubscription;

  ReservationBloc({
    required ReservationRepository reservationRepository,
    required FacilityRepository facilityRepository,
  }) : _reservationRepository = reservationRepository,
        _facilityRepository = facilityRepository,
        super(ReservationInitial()) {

    // Cleanup service'i repository ile initialize et
    _cleanupService = ReservationCleanupService(
        reservationRepository: _reservationRepository
    );

    // Event handler'ları kaydet
    on<LoadUserReservations>(_onLoadUserReservations);
    on<CreateReservation>(_onCreateReservation);
    on<CancelReservation>(_onCancelReservation);
    on<CheckSlotAvailability>(_onCheckSlotAvailability);
    on<LoadDailyReservationCounts>(_onLoadDailyReservationCounts);
    on<_ReservationsUpdated>(_onReservationsUpdated);
    on<StartCleanupService>(_onStartCleanupService);
    on<StopCleanupService>(_onStopCleanupService);
    on<PerformManualCleanup>(_onPerformManualCleanup);

    // Otomatik cleanup servisini başlat
    _cleanupService.startCleanupService();
  }

  // YENİ EKLENEN EVENT HANDLER'LARI
  Future<void> _onStartCleanupService(
      StartCleanupService event,
      Emitter<ReservationState> emit,
      ) async {
    _cleanupService.startCleanupService();
    emit(CleanupServiceStatusChanged(isRunning: true));
  }

  Future<void> _onStopCleanupService(
      StopCleanupService event,
      Emitter<ReservationState> emit,
      ) async {
    _cleanupService.stopCleanupService();
    emit(CleanupServiceStatusChanged(isRunning: false));
  }

  Future<void> _onPerformManualCleanup(
      PerformManualCleanup event,
      Emitter<ReservationState> emit,
      ) async {
    emit(ReservationLoading());
    try {
      await _cleanupService.performManualCleanup();

      // Kullanıcı rezervasyonlarını yeniden yükle
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        add(LoadUserReservations(userId: user.uid));
      }

      emit(ManualCleanupCompleted());
    } catch (e) {
      emit(ReservationError('Cleanup failed: ${e.toString()}'));
    }
  }

  // GÜNCELLENMİŞ REZERVASYON AYIRMA METODU
  Map<String, List<ReservationModel>> _separateReservations(List<ReservationModel> reservations) {
    final now = DateTime.now();
    final upcoming = <ReservationModel>[];
    final past = <ReservationModel>[];

    print("=== REZERVASYON AYIRMA DEBUG ===");
    print("Şu anki zaman: $now");
    print("Toplam rezervasyon sayısı: ${reservations.length}");

    for (final reservation in reservations) {
      print("\n--- Rezervasyon Detayı ---");
      print("ID: ${reservation.id}");
      print("Tarih: ${reservation.date}");
      print("Saat: ${reservation.hourSlot}");
      print("Durum: ${reservation.status}");

      // Rezervasyon bitiş zamanını oluştur (hourSlot + 1 saat)
      final reservationEndTime = DateTime(
        reservation.date.year,
        reservation.date.month,
        reservation.date.day,
        reservation.hourSlot + 1,
      );

      print("Rezervasyon Bitiş: $reservationEndTime");
      print("Şimdi ile kıyasla: ${reservationEndTime.isAfter(now) ? 'Aktif' : 'Süresi Dolmuş'}");

      final status = reservation.status.toLowerCase();

      // Aktif durumlar
      final isActiveStatus = status == 'pending' ||
          status == 'confirmed' ||
          status == 'approved';

      // Rezervasyon süresi dolmuş mu kontrolü
      final isStillActive = reservationEndTime.isAfter(now);

      print("Hala aktif mi: $isStillActive");
      print("Aktif durum mu: $isActiveStatus (status: $status)");

      // GÜNCELLENEN LOJİK:
      // Aktif rezervasyonlar: Süresi dolmamış + aktif durumlu rezervasyonlar
      if (isStillActive && isActiveStatus) {
        print("→ AKTİF LİSTESİNE EKLENİYOR");
        upcoming.add(reservation);
      }
      // Geçmiş rezervasyonlar: Süresi dolmuş VEYA iptal edilmiş/tamamlanmış rezervasyonlar
      else {
        print("→ GEÇMİŞ LİSTESİNE EKLENİYOR");
        past.add(reservation);
      }
    }

    print("\nSONUÇ:");
    print("Aktif rezervasyon sayısı: ${upcoming.length}");
    print("Geçmiş rezervasyon sayısı: ${past.length}");
    print("=== DEBUG BİTTİ ===\n");

    // Aktif rezervasyonları tarihe göre artan sırada sırala
    upcoming.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      return a.hourSlot.compareTo(b.hourSlot);
    });

    // Geçmiş rezervasyonları tarihe göre azalan sırada sırala
    past.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.hourSlot.compareTo(a.hourSlot);
    });

    return {
      'upcoming': upcoming,
      'past': past,
    };
  }

  Future<void> _onLoadUserReservations(
      LoadUserReservations event,
      Emitter<ReservationState> emit,
      ) async {
    emit(ReservationLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        emit(const ReservationError('User not authenticated'));
        return;
      }

      // Kullanıcıya özel cleanup yap
      await _cleanupService.cleanupUserExpiredReservations(user.uid);

      // Cancel any existing subscription
      await _reservationsSubscription?.cancel();

      // Get all facilities for reference
      final facilities = await _facilityRepository.getAllFacilities();
      final facilitiesMap = <String, FacilityModel>{};

      for (var facility in facilities) {
        facilitiesMap[facility.id] = facility;
      }

      // Set up a stream subscription for real-time updates
      _reservationsSubscription = _reservationRepository
          .getUserReservations(user.uid)
          .listen(
            (reservations) {
          add(_ReservationsUpdated(
            reservations: reservations,
            facilities: facilitiesMap,
          ));
        },
      );

      emit(const UserReservationsLoaded(
        upcomingReservations: [],
        pastReservations: [],
        facilities: {},
      ));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onReservationsUpdated(
      _ReservationsUpdated event,
      Emitter<ReservationState> emit,
      ) async {
    // Rezervasyonları ayır
    final separatedReservations = _separateReservations(event.reservations);

    emit(UserReservationsLoaded(
      upcomingReservations: separatedReservations['upcoming']!,
      pastReservations: separatedReservations['past']!,
      facilities: event.facilities,
    ));
  }

  Future<void> _onCreateReservation(
      CreateReservation event,
      Emitter<ReservationState> emit,
      ) async {
    emit(ReservationLoading());
    try {
      // Check if slot is available
      final isAvailable = await _reservationRepository.isSlotAvailable(
        event.facilityId,
        event.date,
        event.hourSlot,
      );

      if (!isAvailable) {
        emit(const ReservationError('This time slot is already at full capacity'));
        return;
      }

      // Create the reservation
      final reservationId = await _reservationRepository.createReservation(
        facilityId: event.facilityId,
        date: event.date,
        hourSlot: event.hourSlot,
      );

      emit(ReservationCreated(reservationId: reservationId));

      // Reload user reservations
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        add(LoadUserReservations(userId: user.uid));
      }
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onCancelReservation(
      CancelReservation event,
      Emitter<ReservationState> emit,
      ) async {
    try {
      await _reservationRepository.cancelReservation(event.reservationId);

      // Reload user reservations
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        add(LoadUserReservations(userId: user.uid));
      }
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onCheckSlotAvailability(
      CheckSlotAvailability event,
      Emitter<ReservationState> emit,
      ) async {
    try {
      final count = await _reservationRepository.getSlotReservationCount(
        event.facilityId,
        event.date,
        event.hourSlot,
      );

      final isAvailable = count < HourlyCapacity.maxCapacity;
      emit(SlotAvailabilityChecked(
        isAvailable: isAvailable,
        currentCount: count,
        maxCapacity: HourlyCapacity.maxCapacity,
      ));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onLoadDailyReservationCounts(
      LoadDailyReservationCounts event,
      Emitter<ReservationState> emit,
      ) async {
    emit(ReservationLoading());
    try {
      // Belirtilen tarih için cleanup yap
      await _cleanupService.cleanupDateExpiredReservations(event.date);

      final counts = await _reservationRepository.getDailyReservationCounts(
        event.facilityId,
        event.date,
      );

      emit(DailyReservationCountsLoaded(
        date: event.date,
        hourlyCounts: counts,
        maxCapacity: HourlyCapacity.maxCapacity,
      ));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _reservationsSubscription?.cancel();
    _cleanupService.stopCleanupService(); // Servis kapatırken cleanup'ı durdur
    return super.close();
  }
}