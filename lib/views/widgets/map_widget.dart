import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/parcel_model.dart';
import '../../../utils/theme.dart';

class EnhancedMapWidget extends StatefulWidget {
  final ParcelModel parcel;
  final Position currentLocation;
  final Function(GoogleMapController)? onMapCreated;

  const EnhancedMapWidget({
    super.key,
    required this.parcel,
    required this.currentLocation,
    this.onMapCreated,
  });

  @override
  State<EnhancedMapWidget> createState() => _EnhancedMapWidgetState();
}

class _EnhancedMapWidgetState extends State<EnhancedMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapData();
  }

  @override
  void didUpdateWidget(EnhancedMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parcel != widget.parcel || 
        oldWidget.currentLocation != widget.currentLocation) {
      _setupMapData();
    }
  }

  void _setupMapData() {
    _createMarkers();
    _createPolylines();
  }

  void _createMarkers() {
    final markers = <Marker>{};

    // Current location marker
    markers.add(Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(
        widget.currentLocation.latitude,
        widget.currentLocation.longitude,
      ),
      infoWindow: const InfoWindow(
        title: 'Current Location',
        snippet: 'You are here',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    // Sender location marker
    if (widget.parcel.senderAddress.latitude != null && 
        widget.parcel.senderAddress.longitude != null) {
      markers.add(Marker(
        markerId: const MarkerId('sender'),
        position: LatLng(
          widget.parcel.senderAddress.latitude!,
          widget.parcel.senderAddress.longitude!,
        ),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: widget.parcel.senderAddress.fullAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    // Receiver location marker
    if (widget.parcel.receiverAddress.latitude != null && 
        widget.parcel.receiverAddress.longitude != null) {
      markers.add(Marker(
        markerId: const MarkerId('receiver'),
        position: LatLng(
          widget.parcel.receiverAddress.latitude!,
          widget.parcel.receiverAddress.longitude!,
        ),
        infoWindow: InfoWindow(
          title: 'Delivery Location',
          snippet: widget.parcel.receiverAddress.fullAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  void _createPolylines() {
    final polylines = <Polyline>{};
    final points = <LatLng>[];

    // Add sender location
    if (widget.parcel.senderAddress.latitude != null && 
        widget.parcel.senderAddress.longitude != null) {
      points.add(LatLng(
        widget.parcel.senderAddress.latitude!,
        widget.parcel.senderAddress.longitude!,
      ));
    }

    // Add current location
    points.add(LatLng(
      widget.currentLocation.latitude,
      widget.currentLocation.longitude,
    ));

    // Add receiver location
    if (widget.parcel.receiverAddress.latitude != null && 
        widget.parcel.receiverAddress.longitude != null) {
      points.add(LatLng(
        widget.parcel.receiverAddress.latitude!,
        widget.parcel.receiverAddress.longitude!,
      ));
    }

    if (points.length >= 2) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppTheme.primaryColor,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    }

    setState(() {
      _polylines = polylines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = CameraPosition(
      target: LatLng(
        widget.currentLocation.latitude,
        widget.currentLocation.longitude,
      ),
      zoom: 12.0,
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCamera,
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            widget.onMapCreated?.call(controller);
            _fitMarkersInView();
          },
          mapType: MapType.normal,
          myLocationEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        _buildMapControls(),
        _buildLocationInfo(),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_in',
            onPressed: _zoomIn,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            heroTag: 'zoom_out',
            onPressed: _zoomOut,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            heroTag: 'center_map',
            onPressed: _centerMap,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    final distance = _calculateDistance();
    final eta = _calculateETA();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Distance to Destination',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    distance,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppTheme.dividerColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Estimated Arrival',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    eta,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDistance() {
    if (widget.parcel.receiverAddress.latitude != null && 
        widget.parcel.receiverAddress.longitude != null) {
      final distance = Geolocator.distanceBetween(
        widget.currentLocation.latitude,
        widget.currentLocation.longitude,
        widget.parcel.receiverAddress.latitude!,
        widget.parcel.receiverAddress.longitude!,
      );

      if (distance < 1000) {
        return '${distance.toStringAsFixed(0)} m';
      } else {
        return '${(distance / 1000).toStringAsFixed(1)} km';
      }
    }
    return 'Unknown';
  }

  String _calculateETA() {
    if (widget.parcel.estimatedDeliveryDate != null) {
      final now = DateTime.now();
      final eta = widget.parcel.estimatedDeliveryDate!;
      
      if (eta.isBefore(now)) {
        return 'Overdue';
      }
      
      final difference = eta.difference(now);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ${difference.inHours % 24}h';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return '${difference.inMinutes}m';
      }
    }
    return 'Unknown';
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _centerMap() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(
        widget.currentLocation.latitude,
        widget.currentLocation.longitude,
      )),
    );
  }

  void _fitMarkersInView() {
    if (_markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    final southwest = LatLng(minLat, minLng);
    final northeast = LatLng(maxLat, maxLng);
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }
}