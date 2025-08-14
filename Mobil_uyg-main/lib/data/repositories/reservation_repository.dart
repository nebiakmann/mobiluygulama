import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spor_salonu/data/models/reservation_model.dart';
import 'package:uuid/uuid.dart';

class ReservationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new reservation
  Future<String> createReservation({
    required String facilityId,
    required DateTime date,
    required int hourSlot,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if the slot is available (has less than max capacity)
      final available = await isSlotAvailable(facilityId, date, hourSlot);
      if (!available) {
        throw Exception('This time slot is already at full capacity');
      }

      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        hourSlot,
        0,
      );

      final endTime = startTime.add(const Duration(hours: 1));

      // Generate a unique ID for the reservation
      final String reservationId = const Uuid().v4();

      // Create the reservation
      await _firestore.collection('reservations').doc(reservationId).set({
        'id': reservationId,
        'userId': user.uid,
        'facilityId': facilityId,
        'date': Timestamp.fromDate(date),
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'hourSlot': hourSlot,
        'status': ReservationStatus.confirmed,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return reservationId;
    } catch (e) {
      debugPrint('Error creating reservation: $e');
      rethrow;
    }
  }

  // Check if a time slot is available (less than max capacity)
  Future<bool> isSlotAvailable(String facilityId, DateTime date, int hourSlot) async {
    try {
      // Create a date with only year, month, day
      final dateOnly = DateTime(date.year, date.month, date.day);

      // Query for existing reservations in this time slot
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('facilityId', isEqualTo: facilityId)
          .where('hourSlot', isEqualTo: hourSlot)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .where('status', isEqualTo: ReservationStatus.confirmed)
          .get();

      // Check if the number of reservations is less than max capacity
      return querySnapshot.docs.length < HourlyCapacity.maxCapacity;
    } catch (e) {
      debugPrint('Error checking slot availability: $e');
      rethrow;
    }
  }

  // Get the number of reservations for a specific slot
  Future<int> getSlotReservationCount(String facilityId, DateTime date, int hourSlot) async {
    try {
      // Create a date with only year, month, day
      final dateOnly = DateTime(date.year, date.month, date.day);

      // Query for existing reservations in this time slot
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('facilityId', isEqualTo: facilityId)
          .where('hourSlot', isEqualTo: hourSlot)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .where('status', isEqualTo: ReservationStatus.confirmed)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting reservation count: $e');
      return 0;
    }
  }

  // Get reservations for a specific day
  Future<Map<int, int>> getDailyReservationCounts(String facilityId, DateTime date) async {
    try {
      final Map<int, int> hourlyCounts = {};

      // Initialize all hours with 0 count
      for (int hour = 0; hour < 24; hour++) {
        hourlyCounts[hour] = 0;
      }

      // Create a date with only year, month, day
      final dateOnly = DateTime(date.year, date.month, date.day);

      // Query for all reservations on this day
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('facilityId', isEqualTo: facilityId)
          .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
          .where('status', isEqualTo: ReservationStatus.confirmed)
          .get();

      // Count reservations for each hour
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final hourSlot = data['hourSlot'] as int;
        hourlyCounts[hourSlot] = (hourlyCounts[hourSlot] ?? 0) + 1;
      }

      return hourlyCounts;
    } catch (e) {
      debugPrint('Error getting daily reservation counts: $e');
      return {};
    }
  }

  // Get user reservations
  Stream<List<ReservationModel>> getUserReservations(String userId) {
    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReservationModel.fromMap(data);
      }).toList();
    });
  }

  // Cancel a reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': ReservationStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error cancelling reservation: $e');
      rethrow;
    }
  }

  // Get all expired reservations
  Future<List<ReservationModel>> getExpiredReservations(DateTime currentTime) async {
    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('status', whereIn: ['pending', 'confirmed', 'approved'])
          .get();

      final expiredReservations = <ReservationModel>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final reservation = ReservationModel.fromMap(data);

        // Calculate reservation end time
        final reservationEndTime = DateTime(
          reservation.date.year,
          reservation.date.month,
          reservation.date.day,
          reservation.hourSlot + 1,
        );

        // Add to list if expired
        if (currentTime.isAfter(reservationEndTime)) {
          expiredReservations.add(reservation);
        }
      }

      return expiredReservations;
    } catch (e) {
      throw Exception('Failed to get expired reservations: $e');
    }
  }

  // Get user's expired reservations
  Future<List<ReservationModel>> getUserExpiredReservations(String userId, DateTime currentTime) async {
    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'confirmed', 'approved'])
          .get();

      final expiredReservations = <ReservationModel>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final reservation = ReservationModel.fromMap(data);

        final reservationEndTime = DateTime(
          reservation.date.year,
          reservation.date.month,
          reservation.date.day,
          reservation.hourSlot + 1,
        );

        if (currentTime.isAfter(reservationEndTime)) {
          expiredReservations.add(reservation);
        }
      }

      return expiredReservations;
    } catch (e) {
      throw Exception('Failed to get user expired reservations: $e');
    }
  }

  // Get expired reservations for a specific date
  Future<List<ReservationModel>> getDateExpiredReservations(DateTime date, DateTime currentTime) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('reservations')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['pending', 'confirmed', 'approved'])
          .get();

      final expiredReservations = <ReservationModel>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final reservation = ReservationModel.fromMap(data);

        final reservationEndTime = DateTime(
          reservation.date.year,
          reservation.date.month,
          reservation.date.day,
          reservation.hourSlot + 1,
        );

        if (currentTime.isAfter(reservationEndTime)) {
          expiredReservations.add(reservation);
        }
      }

      return expiredReservations;
    } catch (e) {
      throw Exception('Failed to get date expired reservations: $e');
    }
  }

  // Update reservation status
  Future<void> updateReservationStatus(String reservationId, String newStatus) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update reservation status: $e');
    }
  }

  // Auto-cleanup expired reservations
  Future<void> cleanupExpiredReservations() async {
    try {
      final currentTime = DateTime.now();
      final expiredReservations = await getExpiredReservations(currentTime);

      for (final reservation in expiredReservations) {
        await updateReservationStatus(reservation.id, ReservationStatus.completed);
      }

      debugPrint('Cleaned up ${expiredReservations.length} expired reservations');
    } catch (e) {
      debugPrint('Error cleaning up expired reservations: $e');
    }
  }

  // Cleanup expired reservations for a specific user
  Future<void> cleanupUserExpiredReservations(String userId) async {
    try {
      final currentTime = DateTime.now();
      final expiredReservations = await getUserExpiredReservations(userId, currentTime);

      for (final reservation in expiredReservations) {
        await updateReservationStatus(reservation.id, ReservationStatus.completed);
      }

      debugPrint('Cleaned up ${expiredReservations.length} expired reservations for user $userId');
    } catch (e) {
      debugPrint('Error cleaning up user expired reservations: $e');
    }
  }
}