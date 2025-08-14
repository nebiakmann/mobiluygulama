enum UserRole {
  student,
  staff,
  admin
}

enum Gender {
  male,
  female,
  other,
  preferNotToSay
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String studentOrStaffId;
  final UserRole role;
  final Gender? gender;
  final String? department;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentOrStaffId,
    required this.role,
    this.gender,
    this.department,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      studentOrStaffId: map['studentOrStaffId'] as String,
      role: UserRole.values.firstWhere((e) => e.toString() == 'UserRole.${map['role']}'),
      gender: map['gender'] != null ? 
        Gender.values.firstWhere((e) => e.toString() == 'Gender.${map['gender']}') : null,
      department: map['department'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'studentOrStaffId': studentOrStaffId,
      'role': role.toString().split('.').last,
      'gender': gender?.toString().split('.').last,
      'department': department,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
} 