import 'package:flutter/foundation.dart';
import 'package:spor_salonu/data/models/facility_model.dart';

/// A mock repository that simulates Firestore facility functionality for testing
class MockFacilityRepository {
  // Singleton pattern
  static final MockFacilityRepository _instance = MockFacilityRepository._internal();
  factory MockFacilityRepository() => _instance;
  MockFacilityRepository._internal() {
    _initializeData();
  }

  // In-memory facility data storage
  final List<FacilityModel> _facilities = [];

  // Initialize with some test data
  void _initializeData() {
    final now = DateTime.now();

    // Add single fitness center
    _facilities.add(
        FacilityModel(
          id: 'fitness-center',
          name: 'Fitness Center',
          description: 'Modern fitness center with cardio and strength training equipment',
          imageUrl: 'assets/images/fitness.jpg',
          isAvailable: true,
          createdAt: now,
          updatedAt: now,
        )
    );

    debugPrint('Mock facility data initialized with ${_facilities.length} facilities');
  }

  // Get all facilities
  Future<List<FacilityModel>> getAllFacilities() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    debugPrint('Getting all mock facilities: ${_facilities.length}');
    return _facilities;
  }

  // Get facility by id
  Future<FacilityModel?> getFacilityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final facility = _facilities.firstWhere((f) => f.id == id);
      debugPrint('Found mock facility: ${facility.name}');
      return facility;
    } catch (e) {
      debugPrint('Mock facility not found with id: $id');
      return null;
    }
  }

  // Get facilities as stream
  Stream<List<FacilityModel>> getFacilitiesStream() {
    return Stream.value(_facilities);
  }

  // Create mock facilities in "database"
  Future<void> createMockFacilities() async {
    // Data is already created in the constructor
    debugPrint('Mock facilities already created');
  }
}