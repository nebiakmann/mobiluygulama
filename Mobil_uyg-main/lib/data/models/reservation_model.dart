import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final String facilityId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int hourSlot; // 0-23 representing the hour of the day
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReservationModel({
    required this.id,
    required this.userId,
    required this.facilityId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hourSlot,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      facilityId: map['facilityId'] as String,
      date: map['date'] is String
          ? DateTime.parse(map['date'])
          : (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] is String
          ? DateTime.parse(map['startTime'])
          : (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] is String
          ? DateTime.parse(map['endTime'])
          : (map['endTime'] as Timestamp).toDate(),
      hourSlot: map['hourSlot'] as int,
      status: map['status'] as String,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'])
          : (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'facilityId': facilityId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'hourSlot': hourSlot,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Reservation status constants
class ReservationStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';
}

// Hourly slot capacity constants
class HourlyCapacity {
  static const int maxCapacity = 25; // 25 people per hour for the fitness center
}