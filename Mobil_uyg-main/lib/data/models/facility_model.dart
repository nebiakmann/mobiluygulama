class FacilityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    return FacilityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      isAvailable: map['isAvailable'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}