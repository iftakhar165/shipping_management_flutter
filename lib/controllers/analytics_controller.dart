import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';
import '../utils/logger.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final Rx<AnalyticsModel?> analytics = Rx<AnalyticsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString selectedTimeRange = '30days'.obs;
  final RxString selectedMetric = 'revenue'.obs;

  // Time range options
  final Map<String, String> timeRanges = {
    '7days': 'Last 7 Days',
    '30days': 'Last 30 Days',
    '3months': 'Last 3 Months',
    '6months': 'Last 6 Months',
    '1year': 'Last Year',
  };

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
    
    // Listen to time range changes
    ever(selectedTimeRange, (String timeRange) {
      loadAnalytics();
    });
  }

  /// Load analytics data
  Future<void> loadAnalytics() async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('User not authenticated');
        return;
      }

      // Get user's business ID
      final businessId = await _getUserBusinessId(user.uid);
      if (businessId == null) {
        AppLogger.warning('Business ID not found for user');
        return;
      }

      // Load analytics data
      final analyticsData = await _analyticsService.getAnalytics(
        businessId: businessId,
        timeRange: selectedTimeRange.value,
      );

      if (analyticsData != null) {
        analytics.value = analyticsData;
        AppLogger.info('Analytics data loaded successfully');
      } else {
        // Generate sample analytics data if none exists
        analytics.value = await _generateSampleAnalytics(businessId);
        AppLogger.info('Generated sample analytics data');
      }
    } catch (e) {
      AppLogger.error('Error loading analytics: $e');
      Get.snackbar(
        'Error',
        'Failed to load analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh analytics data
  Future<void> refreshAnalytics() async {
    try {
      isRefreshing.value = true;
      await loadAnalytics();
      
      Get.snackbar(
        'Success',
        'Analytics data refreshed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Error refreshing analytics: $e');
      Get.snackbar(
        'Error',
        'Failed to refresh analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Update time range
  void updateTimeRange(String timeRange) {
    selectedTimeRange.value = timeRange;
  }

  /// Update selected metric
  void updateSelectedMetric(String metric) {
    selectedMetric.value = metric;
  }

  /// Export analytics data
  Future<void> exportAnalytics() async {
    try {
      if (analytics.value == null) {
        Get.snackbar(
          'Warning',
          'No analytics data to export',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // TODO: Implement PDF/Excel export
      await _analyticsService.exportAnalytics(analytics.value!);
      
      Get.snackbar(
        'Success',
        'Analytics data exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('Error exporting analytics: $e');
      Get.snackbar(
        'Error',
        'Failed to export analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get real-time analytics stream
  Stream<AnalyticsModel?> getAnalyticsStream(String businessId) {
    return _analyticsService.getAnalyticsStream(businessId);
  }

  /// Get user's business ID
  Future<String?> _getUserBusinessId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['businessId'];
    } catch (e) {
      AppLogger.error('Error getting user business ID: $e');
      return null;
    }
  }

  /// Generate sample analytics data for demonstration
  Future<AnalyticsModel> _generateSampleAnalytics(String businessId) async {
    final now = DateTime.now();
    
    // Generate sample revenue data
    final revenueHistory = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final baseRevenue = 1000.0;
      final variation = (index % 7) * 200.0;
      final weekendBonus = date.weekday >= 6 ? 300.0 : 0.0;
      
      return RevenueDataPoint(
        date: date,
        value: baseRevenue + variation + weekendBonus + (index * 50),
      );
    });

    // Generate sample parcel data
    final parcelHistory = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final baseCount = 10;
      final variation = (index % 5) * 3;
      
      return ParcelDataPoint(
        date: date,
        count: baseCount + variation + (index ~/ 3),
      );
    });

    // Generate sample customer data
    final customerHistory = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final baseCount = 5;
      final variation = (index % 4) * 2;
      
      return CustomerDataPoint(
        date: date,
        count: baseCount + variation + (index ~/ 5),
      );
    });

    // Generate sample delivery data
    final deliveryHistory = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final baseTime = 24.0; // hours
      final variation = (index % 3) * 2.0;
      
      return DeliveryDataPoint(
        date: date,
        averageTime: baseTime + variation,
        count: 8 + (index % 5),
      );
    });

    // Generate sample performance data
    final performanceHistory = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      
      return PerformanceDataPoint(
        date: date,
        uptime: 0.995 + (index % 3) * 0.002,
        responseTime: 150.0 + (index % 5) * 10.0,
        apiCalls: 1000 + (index * 50),
      );
    });

    return AnalyticsModel(
      id: 'sample_analytics',
      businessId: businessId,
      date: now,
      revenue: RevenueMetrics(
        totalRevenue: 45000.0,
        dailyRevenue: 1500.0,
        weeklyRevenue: 10500.0,
        monthlyRevenue: 45000.0,
        quarterlyRevenue: 135000.0,
        yearlyRevenue: 540000.0,
        averageOrderValue: 85.50,
        revenueByService: {
          'standard_delivery': 25000.0,
          'express_delivery': 15000.0,
          'same_day_delivery': 5000.0,
        },
        revenueByRegion: {
          'north': 15000.0,
          'south': 12000.0,
          'east': 10000.0,
          'west': 8000.0,
        },
        profitMargin: 0.25,
        expenses: 33750.0,
        revenueHistory: revenueHistory,
      ),
      parcels: ParcelMetrics(
        totalParcels: 1250,
        dailyParcels: 42,
        weeklyParcels: 294,
        monthlyParcels: 1250,
        activeParcels: 180,
        deliveredParcels: 950,
        pendingParcels: 120,
        cancelledParcels: 50,
        parcelsByStatus: {
          'delivered': 950,
          'in_transit': 80,
          'pending': 120,
          'cancelled': 50,
          'out_for_delivery': 50,
        },
        parcelsByType: {
          'document': 400,
          'package': 600,
          'fragile': 150,
          'electronic': 100,
        },
        parcelsByPriority: {
          'standard': 800,
          'express': 300,
          'urgent': 150,
        },
        parcelsByRegion: {
          'north': 400,
          'south': 350,
          'east': 300,
          'west': 200,
        },
        averageWeight: 2.5,
        averageShippingCost: 12.50,
        parcelHistory: parcelHistory,
      ),
      customers: CustomerMetrics(
        totalCustomers: 450,
        newCustomers: 35,
        activeCustomers: 280,
        returningCustomers: 200,
        customerRetentionRate: 0.78,
        customerSatisfactionScore: 0.92,
        customerLifetimeValue: 850.0,
        customersByRegion: {
          'north': 150,
          'south': 120,
          'east': 100,
          'west': 80,
        },
        customersByType: {
          'individual': 350,
          'business': 100,
        },
        customerHistory: customerHistory,
      ),
      delivery: DeliveryMetrics(
        averageDeliveryTime: 28.5,
        onTimeDeliveryRate: 0.94,
        totalDeliveries: 950,
        successfulDeliveries: 900,
        failedDeliveries: 50,
        deliveryTimesByRegion: {
          'north': 24.0,
          'south': 28.0,
          'east': 32.0,
          'west': 30.0,
        },
        deliveriesByAgent: {
          'agent_001': 150,
          'agent_002': 140,
          'agent_003': 130,
          'agent_004': 120,
          'agent_005': 110,
        },
        deliveryHistory: deliveryHistory,
      ),
      performance: PerformanceMetrics(
        systemUptime: 0.998,
        averageResponseTime: 185.5,
        totalApiCalls: 45000,
        errorCount: 45,
        errorRate: 0.001,
        featureUsage: {
          'parcel_creation': 1250,
          'tracking': 3500,
          'delivery_updates': 950,
          'payment_processing': 800,
        },
        performanceHistory: performanceHistory,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}