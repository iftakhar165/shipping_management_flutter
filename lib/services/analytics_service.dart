import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Get analytics data for a business
  Future<AnalyticsModel?> getAnalytics({
    required String businessId,
    required String timeRange,
  }) async {
    try {
      final query = _firestore
          .collection('analytics')
          .where('businessId', isEqualTo: businessId)
          .orderBy('date', descending: true)
          .limit(1);

      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        return AnalyticsModel.fromFirestore(snapshot.docs.first);
      }

      return null;
    } catch (e) {
      _logger.e('Error getting analytics: $e');
      return null;
    }
  }

  /// Get real-time analytics stream
  Stream<AnalyticsModel?> getAnalyticsStream(String businessId) {
    return _firestore
        .collection('analytics')
        .where('businessId', isEqualTo: businessId)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return AnalyticsModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  /// Save analytics data
  Future<void> saveAnalytics(AnalyticsModel analytics) async {
    try {
      await _firestore
          .collection('analytics')
          .doc(analytics.id)
          .set(analytics.toFirestore());
      
      _logger.i('Analytics saved successfully');
    } catch (e) {
      _logger.e('Error saving analytics: $e');
      throw Exception('Failed to save analytics data');
    }
  }

  /// Update analytics data
  Future<void> updateAnalytics(String analyticsId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('analytics')
          .doc(analyticsId)
          .update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
      
      _logger.i('Analytics updated successfully');
    } catch (e) {
      _logger.e('Error updating analytics: $e');
      throw Exception('Failed to update analytics data');
    }
  }

  /// Delete analytics data
  Future<void> deleteAnalytics(String analyticsId) async {
    try {
      await _firestore
          .collection('analytics')
          .doc(analyticsId)
          .delete();
      
      _logger.i('Analytics deleted successfully');
    } catch (e) {
      _logger.e('Error deleting analytics: $e');
      throw Exception('Failed to delete analytics data');
    }
  }

  /// Get analytics history
  Future<List<AnalyticsModel>> getAnalyticsHistory({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final query = _firestore
          .collection('analytics')
          .where('businessId', isEqualTo: businessId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => AnalyticsModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.e('Error getting analytics history: $e');
      return [];
    }
  }

  /// Export analytics data
  Future<void> exportAnalytics(AnalyticsModel analytics) async {
    try {
      // TODO: Implement PDF/Excel export functionality
      // This is a placeholder for the export functionality
      _logger.i('Exporting analytics data...');
      
      // For now, just log the export action
      _logger.i('Analytics export completed for business: ${analytics.businessId}');
    } catch (e) {
      _logger.e('Error exporting analytics: $e');
      throw Exception('Failed to export analytics data');
    }
  }

  /// Calculate growth percentage
  double calculateGrowth(double current, double previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  /// Get date range based on time range string
  Map<String, DateTime> getDateRange(String timeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case '7days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '30days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '3months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6months':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }

    return {
      'startDate': startDate,
      'endDate': now,
    };
  }

  /// Aggregate analytics data
  Future<AnalyticsModel?> aggregateAnalytics({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all analytics data within the date range
      final analyticsHistory = await getAnalyticsHistory(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );

      if (analyticsHistory.isEmpty) {
        return null;
      }

      // Aggregate the data
      double totalRevenue = 0;
      int totalParcels = 0;
      int totalCustomers = 0;
      int totalDeliveries = 0;
      double totalDeliveryTime = 0;
      double totalUptime = 0;
      int totalApiCalls = 0;

      for (final analytics in analyticsHistory) {
        totalRevenue += analytics.revenue.totalRevenue;
        totalParcels += analytics.parcels.totalParcels;
        totalCustomers += analytics.customers.totalCustomers;
        totalDeliveries += analytics.delivery.totalDeliveries;
        totalDeliveryTime += analytics.delivery.averageDeliveryTime;
        totalUptime += analytics.performance.systemUptime;
        totalApiCalls += analytics.performance.totalApiCalls;
      }

      final count = analyticsHistory.length;

      // Create aggregated analytics model
      // This is a simplified version - you might want to create more sophisticated aggregation
      final firstAnalytics = analyticsHistory.first;
      
      return AnalyticsModel(
        id: 'aggregated_${businessId}_${DateTime.now().millisecondsSinceEpoch}',
        businessId: businessId,
        date: endDate,
        revenue: RevenueMetrics(
          totalRevenue: totalRevenue,
          dailyRevenue: totalRevenue / (endDate.difference(startDate).inDays + 1),
          weeklyRevenue: totalRevenue / ((endDate.difference(startDate).inDays + 1) / 7),
          monthlyRevenue: totalRevenue / ((endDate.difference(startDate).inDays + 1) / 30),
          quarterlyRevenue: totalRevenue,
          yearlyRevenue: totalRevenue,
          averageOrderValue: firstAnalytics.revenue.averageOrderValue,
          profitMargin: firstAnalytics.revenue.profitMargin,
          expenses: firstAnalytics.revenue.expenses,
        ),
        parcels: ParcelMetrics(
          totalParcels: totalParcels,
          dailyParcels: totalParcels ~/ (endDate.difference(startDate).inDays + 1),
          weeklyParcels: totalParcels ~/ ((endDate.difference(startDate).inDays + 1) / 7).ceil(),
          monthlyParcels: totalParcels ~/ ((endDate.difference(startDate).inDays + 1) / 30).ceil(),
          activeParcels: firstAnalytics.parcels.activeParcels,
          deliveredParcels: firstAnalytics.parcels.deliveredParcels,
          pendingParcels: firstAnalytics.parcels.pendingParcels,
          cancelledParcels: firstAnalytics.parcels.cancelledParcels,
          averageWeight: firstAnalytics.parcels.averageWeight,
          averageShippingCost: firstAnalytics.parcels.averageShippingCost,
        ),
        customers: CustomerMetrics(
          totalCustomers: totalCustomers ~/ count,
          newCustomers: firstAnalytics.customers.newCustomers,
          activeCustomers: firstAnalytics.customers.activeCustomers,
          returningCustomers: firstAnalytics.customers.returningCustomers,
          customerRetentionRate: firstAnalytics.customers.customerRetentionRate,
          customerSatisfactionScore: firstAnalytics.customers.customerSatisfactionScore,
          customerLifetimeValue: firstAnalytics.customers.customerLifetimeValue,
        ),
        delivery: DeliveryMetrics(
          averageDeliveryTime: totalDeliveryTime / count,
          onTimeDeliveryRate: firstAnalytics.delivery.onTimeDeliveryRate,
          totalDeliveries: totalDeliveries,
          successfulDeliveries: firstAnalytics.delivery.successfulDeliveries,
          failedDeliveries: firstAnalytics.delivery.failedDeliveries,
        ),
        performance: PerformanceMetrics(
          systemUptime: totalUptime / count,
          averageResponseTime: firstAnalytics.performance.averageResponseTime,
          totalApiCalls: totalApiCalls,
          errorCount: firstAnalytics.performance.errorCount,
          errorRate: firstAnalytics.performance.errorRate,
        ),
        createdAt: startDate,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error aggregating analytics: $e');
      return null;
    }
  }
}