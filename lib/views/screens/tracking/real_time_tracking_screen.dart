import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../../../controllers/tracking_controller.dart';
import '../../../models/parcel_model.dart';
import '../../../utils/theme.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/tracking_timeline.dart';
import '../../widgets/map_widget.dart';

class RealTimeTrackingScreen extends StatefulWidget {
  final String parcelId;

  const RealTimeTrackingScreen({
    super.key,
    required this.parcelId,
  });

  @override
  State<RealTimeTrackingScreen> createState() => _RealTimeTrackingScreenState();
}

class _RealTimeTrackingScreenState extends State<RealTimeTrackingScreen>
    with TickerProviderStateMixin {
  final TrackingController _trackingController = Get.put(TrackingController());
  late TabController _tabController;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trackingController.startTracking(widget.parcelId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trackingController.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildParcelHeader(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HeroText(
                    tag: 'tracking_title',
                    text: 'Real-Time Tracking',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final parcel = _trackingController.currentParcel.value;
                    return Text(
                      parcel?.trackingNumber ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareTracking,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _trackingController.refreshTracking(),
        ),
      ],
    );
  }

  Widget _buildParcelHeader() {
    return Obx(() {
      final parcel = _trackingController.currentParcel.value;
      if (parcel == null) {
        return _buildLoadingHeader();
      }

      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                HeroContainer(
                  tag: 'parcel_status_${parcel.id}',
                  decoration: BoxDecoration(
                    color: _getStatusColor(parcel.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _getStatusIcon(parcel.status),
                    color: _getStatusColor(parcel.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(parcel.status),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(parcel.status),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: ${_formatTime(parcel.updatedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (parcel.estimatedDeliveryDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ETA',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        _formatDate(parcel.estimatedDeliveryDate!),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar(parcel),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
    });
  }

  Widget _buildProgressBar(ParcelModel parcel) {
    final progress = _getProgressValue(parcel.status);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(parcel.status),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Map View'),
              Tab(text: 'Timeline'),
              Tab(text: 'Details'),
            ],
          ),
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(),
                _buildTimelineView(),
                _buildDetailsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Obx(() {
      final parcel = _trackingController.currentParcel.value;
      final currentLocation = _trackingController.currentLocation.value;
      
      if (parcel == null || currentLocation == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: AppTheme.cardDecoration(),
        child: ClipRRect(
          borderRadius: AppTheme.mediumRadius,
          child: EnhancedMapWidget(
            parcel: parcel,
            currentLocation: currentLocation,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
        ),
      );
    });
  }

  Widget _buildTimelineView() {
    return Obx(() {
      final parcel = _trackingController.currentParcel.value;
      
      if (parcel == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Container(
        margin: const EdgeInsets.only(top: 20),
        child: TrackingTimeline(
          trackingUpdates: parcel.trackingUpdates,
          currentStatus: parcel.status,
        ),
      );
    });
  }

  Widget _buildDetailsView() {
    return Obx(() {
      final parcel = _trackingController.currentParcel.value;
      
      if (parcel == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Container(
        margin: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInfoCard(
                'Sender Information',
                [
                  InfoRow('Address', parcel.senderAddress.fullAddress),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Receiver Information',
                [
                  InfoRow('Name', parcel.receiverName),
                  InfoRow('Phone', parcel.receiverPhone),
                  InfoRow('Email', parcel.receiverEmail),
                  InfoRow('Address', parcel.receiverAddress.fullAddress),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Parcel Information',
                [
                  InfoRow('Type', parcel.type.name),
                  InfoRow('Priority', parcel.priority.name),
                  InfoRow('Weight', '${parcel.weight} kg'),
                  InfoRow('Shipping Cost', '\$${parcel.shippingCost.toStringAsFixed(2)}'),
                  if (parcel.description.isNotEmpty)
                    InfoRow('Description', parcel.description),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoCard(String title, List<InfoRow> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    row.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Color _getStatusColor(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return AppTheme.warningColor;
      case ParcelStatus.confirmed:
        return AppTheme.infoColor;
      case ParcelStatus.collected:
        return AppTheme.primaryColor;
      case ParcelStatus.inTransit:
        return AppTheme.secondaryColor;
      case ParcelStatus.outForDelivery:
        return AppTheme.accentColor;
      case ParcelStatus.delivered:
        return AppTheme.successColor;
      case ParcelStatus.cancelled:
      case ParcelStatus.returned:
        return AppTheme.errorColor;
    }
  }

  IconData _getStatusIcon(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return Icons.pending_outlined;
      case ParcelStatus.confirmed:
        return Icons.check_circle_outline;
      case ParcelStatus.collected:
        return Icons.inventory_2_outlined;
      case ParcelStatus.inTransit:
        return Icons.local_shipping_outlined;
      case ParcelStatus.outForDelivery:
        return Icons.delivery_dining_outlined;
      case ParcelStatus.delivered:
        return Icons.task_alt;
      case ParcelStatus.cancelled:
        return Icons.cancel_outlined;
      case ParcelStatus.returned:
        return Icons.keyboard_return;
    }
  }

  String _getStatusText(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return 'Pending Pickup';
      case ParcelStatus.confirmed:
        return 'Confirmed';
      case ParcelStatus.collected:
        return 'Collected';
      case ParcelStatus.inTransit:
        return 'In Transit';
      case ParcelStatus.outForDelivery:
        return 'Out for Delivery';
      case ParcelStatus.delivered:
        return 'Delivered';
      case ParcelStatus.cancelled:
        return 'Cancelled';
      case ParcelStatus.returned:
        return 'Returned';
    }
  }

  double _getProgressValue(ParcelStatus status) {
    switch (status) {
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  void _shareTracking() {
    final parcel = _trackingController.currentParcel.value;
    if (parcel != null) {
      // TODO: Implement sharing functionality
      Get.snackbar(
        'Share',
        'Tracking link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class InfoRow {
  final String label;
  final String value;

  InfoRow(this.label, this.value);
}