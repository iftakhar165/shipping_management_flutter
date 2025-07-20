import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import '../services/location_service.dart';
import '../utils/logger.dart';

class TrackingController extends GetxController {
  final ParcelService _parcelService = ParcelService();
  final LocationService _locationService = LocationService();
  
  // Observable variables
  final Rx<ParcelModel?> currentParcel = Rx<ParcelModel?>(null);
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxBool isTracking = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxMap<String, Marker> markers = <String, Marker>{}.obs;
  final RxMap<String, Polyline> polylines = <String, Polyline>{}.obs;
  
  // Timers and streams
  Timer? _trackingTimer;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<ParcelModel?>? _parcelSubscription;
  
  String? _currentParcelId;

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  /// Start tracking a parcel
  Future<void> startTracking(String parcelId) async {
    try {
      _currentParcelId = parcelId;
      isLoading.value = true;
      
      // Load initial parcel data
      await _loadParcelData(parcelId);
      
      // Start location tracking
      await _startLocationTracking();
      
      // Start real-time parcel updates
      _startParcelUpdates(parcelId);
      
      // Start periodic tracking updates
      _startPeriodicUpdates();
      
      isTracking.value = true;
      AppLogger.info('Started tracking parcel: $parcelId');
    } catch (e) {
      AppLogger.error('Error starting tracking: $e');
      Get.snackbar(
        'Error',
        'Failed to start tracking: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Stop tracking
  void stopTracking() {
    _trackingTimer?.cancel();
    _locationSubscription?.cancel();
    _parcelSubscription?.cancel();
    
    isTracking.value = false;
    _currentParcelId = null;
    
    AppLogger.info('Stopped tracking');
  }

  /// Refresh tracking data
  Future<void> refreshTracking() async {
    if (_currentParcelId != null) {
      await _loadParcelData(_currentParcelId!);
      await _updateCurrentLocation();
    }
  }

  /// Load parcel data
  Future<void> _loadParcelData(String parcelId) async {
    try {
      final parcel = await _parcelService.getParcel(parcelId);
      if (parcel != null) {
        currentParcel.value = parcel;
        _updateMapMarkers(parcel);
        _updateRoute(parcel);
      }
    } catch (e) {
      AppLogger.error('Error loading parcel data: $e');
    }
  }

  /// Start location tracking
  Future<void> _startLocationTracking() async {
    try {
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        final granted = await _locationService.requestLocationPermission();
        if (!granted) {
          throw Exception('Location permission denied');
        }
      }

      // Get current location
      await _updateCurrentLocation();

      // Start listening to location changes
      _locationSubscription = _locationService.getLocationStream().listen(
        (position) {
          currentLocation.value = position;
          _updateCurrentLocationMarker(position);
          _updateRoute(currentParcel.value);
        },
        onError: (error) {
          AppLogger.error('Location stream error: $error');
        },
      );
    } catch (e) {
      AppLogger.error('Error starting location tracking: $e');
      rethrow;
    }
  }

  /// Start real-time parcel updates
  void _startParcelUpdates(String parcelId) {
    _parcelSubscription = _parcelService.getParcelStream(parcelId).listen(
      (parcel) {
        if (parcel != null) {
          currentParcel.value = parcel;
          _updateMapMarkers(parcel);
          _updateRoute(parcel);
        }
      },
      onError: (error) {
        AppLogger.error('Parcel stream error: $error');
      },
    );
  }

  /// Start periodic updates
  void _startPeriodicUpdates() {
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_currentParcelId != null) {
        _updateTrackingData();
      }
    });
  }

  /// Update tracking data
  Future<void> _updateTrackingData() async {
    try {
      if (_currentParcelId != null) {
        await _loadParcelData(_currentParcelId!);
      }
      await _updateCurrentLocation();
    } catch (e) {
      AppLogger.error('Error updating tracking data: $e');
    }
  }

  /// Update current location
  Future<void> _updateCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      currentLocation.value = position;
      _updateCurrentLocationMarker(position);
    } catch (e) {
      AppLogger.error('Error updating current location: $e');
    }
  }

  /// Update map markers
  void _updateMapMarkers(ParcelModel parcel) {
    final newMarkers = <String, Marker>{};

    // Sender marker
    if (parcel.senderAddress.latitude != null && parcel.senderAddress.longitude != null) {
      newMarkers['sender'] = Marker(
        markerId: const MarkerId('sender'),
        position: LatLng(
          parcel.senderAddress.latitude!,
          parcel.senderAddress.longitude!,
        ),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: parcel.senderAddress.fullAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }

    // Receiver marker
    if (parcel.receiverAddress.latitude != null && parcel.receiverAddress.longitude != null) {
      newMarkers['receiver'] = Marker(
        markerId: const MarkerId('receiver'),
        position: LatLng(
          parcel.receiverAddress.latitude!,
          parcel.receiverAddress.longitude!,
        ),
        infoWindow: InfoWindow(
          title: 'Delivery Location',
          snippet: parcel.receiverAddress.fullAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }

    markers.value = newMarkers;
  }

  /// Update current location marker
  void _updateCurrentLocationMarker(Position position) {
    final currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(
        title: 'Current Location',
        snippet: 'You are here',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    final updatedMarkers = Map<String, Marker>.from(markers.value);
    updatedMarkers['current_location'] = currentLocationMarker;
    markers.value = updatedMarkers;
  }

  /// Update route polyline
  void _updateRoute(ParcelModel? parcel) {
    if (parcel == null) return;

    final points = <LatLng>[];
    
    // Add sender location
    if (parcel.senderAddress.latitude != null && parcel.senderAddress.longitude != null) {
      points.add(LatLng(
        parcel.senderAddress.latitude!,
        parcel.senderAddress.longitude!,
      ));
    }

    // Add current location if available
    if (currentLocation.value != null) {
      points.add(LatLng(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      ));
    }

    // Add receiver location
    if (parcel.receiverAddress.latitude != null && parcel.receiverAddress.longitude != null) {
      points.add(LatLng(
        parcel.receiverAddress.latitude!,
        parcel.receiverAddress.longitude!,
      ));
    }

    if (points.length >= 2) {
      final routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF007AFF),
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );

      polylines.value = {'route': routePolyline};
      routePoints.value = points;
    }
  }

  /// Get estimated delivery time
  Duration? getEstimatedDeliveryTime() {
    final parcel = currentParcel.value;
    if (parcel?.estimatedDeliveryDate != null) {
      return parcel!.estimatedDeliveryDate!.difference(DateTime.now());
    }
    return null;
  }

  /// Get distance to destination
  double? getDistanceToDestination() {
    final parcel = currentParcel.value;
    final location = currentLocation.value;
    
    if (parcel?.receiverAddress.latitude != null && 
        parcel?.receiverAddress.longitude != null && 
        location != null) {
      return Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        parcel!.receiverAddress.latitude!,
        parcel.receiverAddress.longitude!,
      );
    }
    return null;
  }

  /// Get tracking progress percentage
  double getTrackingProgress() {
    final parcel = currentParcel.value;
    if (parcel == null) return 0.0;

    switch (parcel.status) {
      case ParcelStatus.pending:
        return 0.1;
      case ParcelStatus.confirmed:
        return 0.2;
      case ParcelStatus.collected:
        return 0.4;
      case ParcelStatus.inTransit:
        return 0.6;
      case ParcelStatus.outForDelivery:
        return 0.8;
      case ParcelStatus.delivered:
        return 1.0;
      case ParcelStatus.cancelled:
      case ParcelStatus.returned:
        return 0.0;
    }
  }

  /// Request location permission
  Future<void> _requestLocationPermission() async {
    try {
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        await _locationService.requestLocationPermission();
      }
    } catch (e) {
      AppLogger.error('Error requesting location permission: $e');
    }
  }

  /// Update parcel status (for delivery personnel)
  Future<void> updateParcelStatus(String parcelId, ParcelStatus status, {String? notes}) async {
    try {
      await _parcelService.updateParcelStatus(parcelId, status, notes: notes);
      await _loadParcelData(parcelId);
      
      Get.snackbar(
        'Success',
        'Parcel status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Error updating parcel status: $e');
      Get.snackbar(
        'Error',
        'Failed to update parcel status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Add tracking update
  Future<void> addTrackingUpdate(String parcelId, String description, {String? location}) async {
    try {
      final update = TrackingUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: currentParcel.value?.status ?? ParcelStatus.inTransit,
        description: description,
        timestamp: DateTime.now(),
        location: location,
      );

      await _parcelService.addTrackingUpdate(parcelId, update);
      await _loadParcelData(parcelId);
      
      Get.snackbar(
        'Success',
        'Tracking update added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Error adding tracking update: $e');
      Get.snackbar(
        'Error',
        'Failed to add tracking update',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}