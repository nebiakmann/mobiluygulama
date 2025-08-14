// User Model
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? photoUrl;
  final UserRole role;
  final String studentOrStaffId;
  final String? department;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.role,
    required this.studentOrStaffId,
    this.department,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'studentOrStaffId': studentOrStaffId,
      'department': department,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      photoUrl: map['photoUrl'],
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => UserRole.student,
      ),
      studentOrStaffId: map['studentOrStaffId'] ?? '',
      department: map['department'],
      phoneNumber: map['phoneNumber'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}

// Facility Model
class FacilityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int capacity;
  final List<String> equipment;
  final List<String> rules;
  final List<TimeSlot> availableTimeSlots;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FacilityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.capacity,
    required this.equipment,
    required this.rules,
    required this.availableTimeSlots,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'equipment': equipment,
      'rules': rules,
      'availableTimeSlots': availableTimeSlots.map((slot) => slot.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    return FacilityModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      capacity: map['capacity'] ?? 0,
      equipment: List<String>.from(map['equipment'] ?? []),
      rules: List<String>.from(map['rules'] ?? []),
      availableTimeSlots: List<TimeSlot>.from(
        (map['availableTimeSlots'] ?? []).map(
          (slot) => TimeSlot.fromMap(slot),
        ),
      ),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}

// TimeSlot Model
class TimeSlot {
  final String id;
  final String startTime; // Format: "HH:MM"
  final String endTime; // Format: "HH:MM"
  final List<int> daysOfWeek; // 1-7 (Monday-Sunday)

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'daysOfWeek': daysOfWeek,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
    );
  }
}

// Reservation Model
class ReservationModel {
  final String id;
  final String userId;
  final String facilityId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final ReservationStatus status;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.facilityId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'facilityId': facilityId,
      'date': date.millisecondsSinceEpoch,
      'startTime': startTime,
      'endTime': endTime,
      'status': status.toString().split('.').last,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map) {
    return ReservationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      facilityId: map['facilityId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      status: ReservationStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['status'],
        orElse: () => ReservationStatus.pending,
      ),
      cancellationReason: map['cancellationReason'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}

// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == map['type'],
        orElse: () => NotificationType.info,
      ),
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}

// Enums
enum UserRole {
  student,
  staff,
  admin,
}

enum ReservationStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed,
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}