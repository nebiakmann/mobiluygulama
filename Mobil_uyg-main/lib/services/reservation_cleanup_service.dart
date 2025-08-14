import 'dart:async';
import 'package:spor_salonu/data/repositories/reservation_repository.dart';

class ReservationCleanupService {
  final ReservationRepository _reservationRepository;
  Timer? _cleanupTimer;
  bool _isRunning = false;

  ReservationCleanupService({required ReservationRepository reservationRepository})
      : _reservationRepository = reservationRepository;

  // Cleanup servisini başlat (periyodik temizlik için)
  void startCleanupService() {
    if (_isRunning) return;

    _isRunning = true;
    // Her 5 dakikada bir temizlik yap (test için kısa interval)
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      performManualCleanup();
    });

    // İlk cleanup'ı hemen yap
    performManualCleanup();
  }

  // Cleanup servisini durdur
  void stopCleanupService() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _isRunning = false;
  }

  // Manuel temizlik işlemi - Artık gerçek implement edilmiş
  Future<void> performManualCleanup() async {
    try {
      print("🔄 Cleanup başlatılıyor...");
      final now = DateTime.now();

      // Tüm pending/confirmed rezervasyonları al
      final expiredReservations = await _reservationRepository.getExpiredReservations(now);

      print("⏰ ${expiredReservations.length} adet süresi geçen rezervasyon bulundu");

      // Her birini 'completed' olarak işaretle
      for (final reservation in expiredReservations) {
        await _reservationRepository.updateReservationStatus(
            reservation.id,
            'completed'
        );
        print("✅ Rezervasyon ${reservation.id} tamamlandı olarak işaretlendi");
      }

      print("🎉 Cleanup tamamlandı!");
    } catch (e) {
      print("❌ Cleanup hatası: $e");
    }
  }

  // Kullanıcının süresi geçen rezervasyonlarını temizle
  Future<void> cleanupUserExpiredReservations(String userId) async {
    try {
      print("🔄 Kullanıcı $userId için cleanup başlatılıyor...");
      final now = DateTime.now();

      final expiredReservations = await _reservationRepository.getUserExpiredReservations(userId, now);

      for (final reservation in expiredReservations) {
        await _reservationRepository.updateReservationStatus(
            reservation.id,
            'completed'
        );
      }

      print("✅ Kullanıcı cleanup tamamlandı: ${expiredReservations.length} rezervasyon");
    } catch (e) {
      print("❌ Kullanıcı cleanup hatası: $e");
    }
  }

  // Belirli tarihin süresi geçen rezervasyonlarını temizle
  Future<void> cleanupDateExpiredReservations(DateTime date) async {
    try {
      final now = DateTime.now();
      final expiredReservations = await _reservationRepository.getDateExpiredReservations(date, now);

      for (final reservation in expiredReservations) {
        await _reservationRepository.updateReservationStatus(
            reservation.id,
            'completed'
        );
      }
    } catch (e) {
      print("❌ Tarih cleanup hatası: $e");
    }
  }

  // Rezervasyonun saatinin geçip geçmediğini kontrol eden method
  static bool isReservationExpired(dynamic reservation) {
    try {
      final now = DateTime.now();
      final reservationDate = reservation.date;
      final hourSlot = reservation.hourSlot;

      // Rezervasyon bitiş zamanını hesapla (saat + 1)
      final reservationEndTime = DateTime(
        reservationDate.year,
        reservationDate.month,
        reservationDate.day,
        hourSlot + 1, // 1 saat sonra bitiyor
      );

      // Şu anki zaman, rezervasyon bitiş zamanından sonra mı?
      return now.isAfter(reservationEndTime);
    } catch (e) {
      print("❌ Rezervasyon süre kontrolü hatası: $e");
      return false;
    }
  }

  // Aktif rezervasyonları filtrele (saati geçmemiş + aktif status olanlar)
  static List<dynamic> filterActiveReservations(List<dynamic> reservations) {
    return reservations.where((reservation) {
      final isNotExpired = !isReservationExpired(reservation);
      final isActiveStatus = _isActiveStatus(reservation.status);
      return isNotExpired && isActiveStatus;
    }).toList();
  }

  // Geçmiş rezervasyonları getir (saati geçen + tamamlanmış/iptal edilmiş olanlar)
  static List<dynamic> getAllPastReservations(
      List<dynamic> pastReservations,
      List<dynamic> upcomingReservations
      ) {
    // Saati geçen rezervasyonları bul
    final expiredReservations = upcomingReservations
        .where((reservation) => isReservationExpired(reservation))
        .toList();

    // Durumu geçmiş olan rezervasyonları bul
    final statusPastReservations = upcomingReservations
        .where((reservation) => !_isActiveStatus(reservation.status))
        .toList();

    final allPastReservations = [
      ...pastReservations,
      ...expiredReservations,
      ...statusPastReservations
    ];

    // Duplikasyonları temizle
    final uniquePastReservations = <dynamic>[];
    final seenIds = <String>{};

    for (final reservation in allPastReservations) {
      if (!seenIds.contains(reservation.id)) {
        seenIds.add(reservation.id);
        uniquePastReservations.add(reservation);
      }
    }

    // Tarihe göre sırala (en yeni önce)
    uniquePastReservations.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.hourSlot.compareTo(a.hourSlot);
    });

    return uniquePastReservations;
  }

  // Aktif durum kontrolü
  static bool _isActiveStatus(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'pending' ||
        lowerStatus == 'confirmed' ||
        lowerStatus == 'approved';
  }

  // Rezervasyon durumunu kontrol et
  static String getReservationTimeStatus(dynamic reservation) {
    final now = DateTime.now();
    final reservationDate = reservation.date;
    final today = DateTime(now.year, now.month, now.day);
    final reservationDay = DateTime(reservationDate.year, reservationDate.month, reservationDate.day);

    if (reservationDay.isBefore(today)) {
      return 'past';
    } else if (reservationDay.isAfter(today)) {
      return 'future';
    } else {
      // Bugün - saat kontrolü yap
      if (isReservationExpired(reservation)) {
        return 'past';
      } else {
        return 'today';
      }
    }
  }
}