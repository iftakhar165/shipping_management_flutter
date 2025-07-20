import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';
import '../models/parcel_model.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Permission.location.status;
      return permission == PermissionStatus.granted;
    } catch (e) {
      AppLogger.error('Error checking location permission: $e');
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      return permission == PermissionStatus.granted;
    } catch (e) {
      AppLogger.error('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position> getCurrentLocation() async {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      AppLogger.info('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      AppLogger.error('Error getting current location: $e');
      rethrow;
    }
  }

  /// Get location stream for real-time updates
  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      AppLogger.error('Error checking location service: $e');
      return false;
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      AppLogger.error('Error opening location settings: $e');
      return false;
    }
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      AppLogger.error('Error getting last known position: $e');
      return null;
    }
  }

  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Format duration for display
  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

class ParcelService {
  static final ParcelService _instance = ParcelService._internal();
  factory ParcelService() => _instance;
  ParcelService._internal();

  // Mock implementation for demonstration
  // In a real app, this would integrate with your backend API

  /// Get parcel by ID
  Future<ParcelModel?> getParcel(String parcelId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return mock parcel data
      return _createMockParcel(parcelId);
    } catch (e) {
      AppLogger.error('Error getting parcel: $e');
      return null;
    }
  }

  /// Get parcel stream for real-time updates
  Stream<ParcelModel?> getParcelStream(String parcelId) async* {
    // Simulate real-time updates
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      yield await getParcel(parcelId);
    }
  }

  /// Update parcel status
  Future<void> updateParcelStatus(String parcelId, ParcelStatus status, {String? notes}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      AppLogger.info('Updated parcel $parcelId status to $status');
    } catch (e) {
      AppLogger.error('Error updating parcel status: $e');
      rethrow;
    }
  }

  /// Add tracking update
  Future<void> addTrackingUpdate(String parcelId, TrackingUpdate update) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      AppLogger.info('Added tracking update for parcel $parcelId');
    } catch (e) {
      AppLogger.error('Error adding tracking update: $e');
      rethrow;
    }
  }

  /// Create mock parcel for demonstration
  ParcelModel _createMockParcel(String parcelId) {
    return ParcelModel(
      id: parcelId,
      trackingNumber: 'TRK${parcelId.toUpperCase()}',
      senderId: 'sender_123',
      receiverName: 'John Doe',
      receiverPhone: '+1234567890',
      receiverEmail: 'john.doe@example.com',
      senderAddress: Address(
        street: '123 Sender Street',
        city: 'Sender City',
        state: 'CA',
        postalCode: '12345',
        country: 'USA',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      receiverAddress: Address(
        street: '456 Receiver Avenue',
        city: 'Receiver City',
        state: 'NY',
        postalCode: '67890',
        country: 'USA',
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      description: 'Important documents',
      type: ParcelType.document,
      priority: ParcelPriority.high,
      weight: 1.5,
      shippingCost: 25.99,
      status: ParcelStatus.inTransit,
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
      trackingUpdates: [
        TrackingUpdate(
          id: '1',
          status: ParcelStatus.confirmed,
          description: 'Parcel confirmed and ready for pickup',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          location: 'Sender Facility',
        ),
        TrackingUpdate(
          id: '2',
          status: ParcelStatus.collected,
          description: 'Parcel collected from sender',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          location: 'Pickup Location',
        ),
        TrackingUpdate(
          id: '3',
          status: ParcelStatus.inTransit,
          description: 'Parcel is in transit',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          location: 'Transit Hub',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      businessId: 'business_123',
    );
  }
}