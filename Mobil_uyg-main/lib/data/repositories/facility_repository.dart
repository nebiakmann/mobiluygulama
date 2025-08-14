import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:spor_salonu/data/models/facility_model.dart';
import 'package:spor_salonu/data/repositories/mock_facility_repository.dart';

class FacilityRepository {
  final FirebaseFirestore _firestore;
  final MockFacilityRepository _mockRepository = MockFacilityRepository();
  final String _collectionPath = 'facilities';
  bool _useMock = false;

  FacilityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    // Check if Firestore is available
    try {
      _firestore.collection(_collectionPath).limit(1).get();
    } catch (e) {
      debugPrint('Firestore not available, using mock: $e');
      _useMock = true;
    }
  }

  // Get all facilities as stream
  Stream<List<FacilityModel>> getFacilitiesStream() {
    if (_useMock) {
      return _mockRepository.getFacilitiesStream();
    }

    try {
      return _firestore
          .collection(_collectionPath)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return FacilityModel.fromMap(data);
          }).toList());
    } catch (e) {
      debugPrint('Error getting facilities stream: $e');
      _useMock = true;
      return _mockRepository.getFacilitiesStream();
    }
  }

  // Get all facilities
  Future<List<FacilityModel>> getAllFacilities() async {
    if (_useMock) {
      return await _mockRepository.getAllFacilities();
    }

    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FacilityModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting all facilities: $e');
      _useMock = true;
      return await _mockRepository.getAllFacilities();
    }
  }

  // Get a specific facility by ID
  Future<FacilityModel?> getFacilityById(String facilityId) async {
    if (_useMock) {
      return await _mockRepository.getFacilityById(facilityId);
    }

    try {
      final doc = await _firestore.collection(_collectionPath).doc(facilityId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return FacilityModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting facility by ID: $e');
      _useMock = true;
      return await _mockRepository.getFacilityById(facilityId);
    }
  }

  // Add a new facility
  Future<String?> addFacility(FacilityModel facility) async {
    if (_useMock) {
      // Mock doesn't support adding new facilities
      debugPrint('Adding facilities not supported in mock mode');
      return null;
    }

    try {
      final docRef = await _firestore.collection(_collectionPath).add(facility.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding facility: $e');
      return null;
    }
  }

  // Create mock facilities for testing
  Future<void> createMockFacilities() async {
    if (_useMock) {
      await _mockRepository.createMockFacilities();
      return;
    }

    try {
      // Check if facilities already exist
      final snapshot = await _firestore.collection(_collectionPath).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Mock facilities already exist');
        return;
      }

      // Create single fitness center
      final facility = FacilityModel(
        id: 'fitness-center',
        name: 'Fitness Center',
        description: 'Modern fitness center with cardio and strength training equipment',
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add facility to Firestore
      await addFacility(facility);

      debugPrint('Mock fitness center created successfully');
    } catch (e) {
      debugPrint('Error creating mock facilities: $e');
      _useMock = true;
      await _mockRepository.createMockFacilities();
    }
  }
}