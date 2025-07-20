import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel {
  final String id;
  final String businessId;
  final DateTime date;
  final RevenueMetrics revenue;
  final ParcelMetrics parcels;
  final CustomerMetrics customers;
  final DeliveryMetrics delivery;
  final PerformanceMetrics performance;
  final Map<String, dynamic> customMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnalyticsModel({
    required this.id,
    required this.businessId,
    required this.date,
    required this.revenue,
    required this.parcels,
    required this.customers,
    required this.delivery,
    required this.performance,
    this.customMetrics = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnalyticsModel(
      id: doc.id,
      businessId: data['businessId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      revenue: RevenueMetrics.fromMap(data['revenue'] ?? {}),
      parcels: ParcelMetrics.fromMap(data['parcels'] ?? {}),
      customers: CustomerMetrics.fromMap(data['customers'] ?? {}),
      delivery: DeliveryMetrics.fromMap(data['delivery'] ?? {}),
      performance: PerformanceMetrics.fromMap(data['performance'] ?? {}),
      customMetrics: Map<String, dynamic>.from(data['customMetrics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'businessId': businessId,
      'date': Timestamp.fromDate(date),
      'revenue': revenue.toMap(),
      'parcels': parcels.toMap(),
      'customers': customers.toMap(),
      'delivery': delivery.toMap(),
      'performance': performance.toMap(),
      'customMetrics': customMetrics,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class RevenueMetrics {
  final double totalRevenue;
  final double dailyRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final double quarterlyRevenue;
  final double yearlyRevenue;
  final double averageOrderValue;
  final Map<String, double> revenueByService;
  final Map<String, double> revenueByRegion;
  final double profitMargin;
  final double expenses;
  final List<RevenueDataPoint> revenueHistory;

  RevenueMetrics({
    required this.totalRevenue,
    required this.dailyRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.quarterlyRevenue,
    required this.yearlyRevenue,
    required this.averageOrderValue,
    this.revenueByService = const {},
    this.revenueByRegion = const {},
    required this.profitMargin,
    required this.expenses,
    this.revenueHistory = const [],
  });

  factory RevenueMetrics.fromMap(Map<String, dynamic> map) {
    return RevenueMetrics(
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      dailyRevenue: (map['dailyRevenue'] ?? 0.0).toDouble(),
      weeklyRevenue: (map['weeklyRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (map['monthlyRevenue'] ?? 0.0).toDouble(),
      quarterlyRevenue: (map['quarterlyRevenue'] ?? 0.0).toDouble(),
      yearlyRevenue: (map['yearlyRevenue'] ?? 0.0).toDouble(),
      averageOrderValue: (map['averageOrderValue'] ?? 0.0).toDouble(),
      revenueByService: Map<String, double>.from(map['revenueByService'] ?? {}),
      revenueByRegion: Map<String, double>.from(map['revenueByRegion'] ?? {}),
      profitMargin: (map['profitMargin'] ?? 0.0).toDouble(),
      expenses: (map['expenses'] ?? 0.0).toDouble(),
      revenueHistory: (map['revenueHistory'] as List<dynamic>? ?? [])
          .map((item) => RevenueDataPoint.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalRevenue': totalRevenue,
      'dailyRevenue': dailyRevenue,
      'weeklyRevenue': weeklyRevenue,
      'monthlyRevenue': monthlyRevenue,
      'quarterlyRevenue': quarterlyRevenue,
      'yearlyRevenue': yearlyRevenue,
      'averageOrderValue': averageOrderValue,
      'revenueByService': revenueByService,
      'revenueByRegion': revenueByRegion,
      'profitMargin': profitMargin,
      'expenses': expenses,
      'revenueHistory': revenueHistory.map((item) => item.toMap()).toList(),
    };
  }
}

class ParcelMetrics {
  final int totalParcels;
  final int dailyParcels;
  final int weeklyParcels;
  final int monthlyParcels;
  final int activeParcels;
  final int deliveredParcels;
  final int pendingParcels;
  final int cancelledParcels;
  final Map<String, int> parcelsByStatus;
  final Map<String, int> parcelsByType;
  final Map<String, int> parcelsByPriority;
  final Map<String, int> parcelsByRegion;
  final double averageWeight;
  final double averageShippingCost;
  final List<ParcelDataPoint> parcelHistory;

  ParcelMetrics({
    required this.totalParcels,
    required this.dailyParcels,
    required this.weeklyParcels,
    required this.monthlyParcels,
    required this.activeParcels,
    required this.deliveredParcels,
    required this.pendingParcels,
    required this.cancelledParcels,
    this.parcelsByStatus = const {},
    this.parcelsByType = const {},
    this.parcelsByPriority = const {},
    this.parcelsByRegion = const {},
    required this.averageWeight,
    required this.averageShippingCost,
    this.parcelHistory = const [],
  });

  factory ParcelMetrics.fromMap(Map<String, dynamic> map) {
    return ParcelMetrics(
      totalParcels: map['totalParcels'] ?? 0,
      dailyParcels: map['dailyParcels'] ?? 0,
      weeklyParcels: map['weeklyParcels'] ?? 0,
      monthlyParcels: map['monthlyParcels'] ?? 0,
      activeParcels: map['activeParcels'] ?? 0,
      deliveredParcels: map['deliveredParcels'] ?? 0,
      pendingParcels: map['pendingParcels'] ?? 0,
      cancelledParcels: map['cancelledParcels'] ?? 0,
      parcelsByStatus: Map<String, int>.from(map['parcelsByStatus'] ?? {}),
      parcelsByType: Map<String, int>.from(map['parcelsByType'] ?? {}),
      parcelsByPriority: Map<String, int>.from(map['parcelsByPriority'] ?? {}),
      parcelsByRegion: Map<String, int>.from(map['parcelsByRegion'] ?? {}),
      averageWeight: (map['averageWeight'] ?? 0.0).toDouble(),
      averageShippingCost: (map['averageShippingCost'] ?? 0.0).toDouble(),
      parcelHistory: (map['parcelHistory'] as List<dynamic>? ?? [])
          .map((item) => ParcelDataPoint.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalParcels': totalParcels,
      'dailyParcels': dailyParcels,
      'weeklyParcels': weeklyParcels,
      'monthlyParcels': monthlyParcels,
      'activeParcels': activeParcels,
      'deliveredParcels': deliveredParcels,
      'pendingParcels': pendingParcels,
      'cancelledParcels': cancelledParcels,
      'parcelsByStatus': parcelsByStatus,
      'parcelsByType': parcelsByType,
      'parcelsByPriority': parcelsByPriority,
      'parcelsByRegion': parcelsByRegion,
      'averageWeight': averageWeight,
      'averageShippingCost': averageShippingCost,
      'parcelHistory': parcelHistory.map((item) => item.toMap()).toList(),
    };
  }
}

class CustomerMetrics {
  final int totalCustomers;
  final int newCustomers;
  final int activeCustomers;
  final int returningCustomers;
  final double customerRetentionRate;
  final double customerSatisfactionScore;
  final double customerLifetimeValue;
  final Map<String, int> customersByRegion;
  final Map<String, int> customersByType;
  final List<CustomerDataPoint> customerHistory;

  CustomerMetrics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.activeCustomers,
    required this.returningCustomers,
    required this.customerRetentionRate,
    required this.customerSatisfactionScore,
    required this.customerLifetimeValue,
    this.customersByRegion = const {},
    this.customersByType = const {},
    this.customerHistory = const [],
  });

  factory CustomerMetrics.fromMap(Map<String, dynamic> map) {
    return CustomerMetrics(
      totalCustomers: map['totalCustomers'] ?? 0,
      newCustomers: map['newCustomers'] ?? 0,
      activeCustomers: map['activeCustomers'] ?? 0,
      returningCustomers: map['returningCustomers'] ?? 0,
      customerRetentionRate: (map['customerRetentionRate'] ?? 0.0).toDouble(),
      customerSatisfactionScore: (map['customerSatisfactionScore'] ?? 0.0).toDouble(),
      customerLifetimeValue: (map['customerLifetimeValue'] ?? 0.0).toDouble(),
      customersByRegion: Map<String, int>.from(map['customersByRegion'] ?? {}),
      customersByType: Map<String, int>.from(map['customersByType'] ?? {}),
      customerHistory: (map['customerHistory'] as List<dynamic>? ?? [])
          .map((item) => CustomerDataPoint.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalCustomers': totalCustomers,
      'newCustomers': newCustomers,
      'activeCustomers': activeCustomers,
      'returningCustomers': returningCustomers,
      'customerRetentionRate': customerRetentionRate,
      'customerSatisfactionScore': customerSatisfactionScore,
      'customerLifetimeValue': customerLifetimeValue,
      'customersByRegion': customersByRegion,
      'customersByType': customersByType,
      'customerHistory': customerHistory.map((item) => item.toMap()).toList(),
    };
  }
}

class DeliveryMetrics {
  final double averageDeliveryTime;
  final double onTimeDeliveryRate;
  final int totalDeliveries;
  final int successfulDeliveries;
  final int failedDeliveries;
  final Map<String, double> deliveryTimesByRegion;
  final Map<String, int> deliveriesByAgent;
  final List<DeliveryDataPoint> deliveryHistory;

  DeliveryMetrics({
    required this.averageDeliveryTime,
    required this.onTimeDeliveryRate,
    required this.totalDeliveries,
    required this.successfulDeliveries,
    required this.failedDeliveries,
    this.deliveryTimesByRegion = const {},
    this.deliveriesByAgent = const {},
    this.deliveryHistory = const [],
  });

  factory DeliveryMetrics.fromMap(Map<String, dynamic> map) {
    return DeliveryMetrics(
      averageDeliveryTime: (map['averageDeliveryTime'] ?? 0.0).toDouble(),
      onTimeDeliveryRate: (map['onTimeDeliveryRate'] ?? 0.0).toDouble(),
      totalDeliveries: map['totalDeliveries'] ?? 0,
      successfulDeliveries: map['successfulDeliveries'] ?? 0,
      failedDeliveries: map['failedDeliveries'] ?? 0,
      deliveryTimesByRegion: Map<String, double>.from(map['deliveryTimesByRegion'] ?? {}),
      deliveriesByAgent: Map<String, int>.from(map['deliveriesByAgent'] ?? {}),
      deliveryHistory: (map['deliveryHistory'] as List<dynamic>? ?? [])
          .map((item) => DeliveryDataPoint.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageDeliveryTime': averageDeliveryTime,
      'onTimeDeliveryRate': onTimeDeliveryRate,
      'totalDeliveries': totalDeliveries,
      'successfulDeliveries': successfulDeliveries,
      'failedDeliveries': failedDeliveries,
      'deliveryTimesByRegion': deliveryTimesByRegion,
      'deliveriesByAgent': deliveriesByAgent,
      'deliveryHistory': deliveryHistory.map((item) => item.toMap()).toList(),
    };
  }
}

class PerformanceMetrics {
  final double systemUptime;
  final double averageResponseTime;
  final int totalApiCalls;
  final int errorCount;
  final double errorRate;
  final Map<String, int> featureUsage;
  final List<PerformanceDataPoint> performanceHistory;

  PerformanceMetrics({
    required this.systemUptime,
    required this.averageResponseTime,
    required this.totalApiCalls,
    required this.errorCount,
    required this.errorRate,
    this.featureUsage = const {},
    this.performanceHistory = const [],
  });

  factory PerformanceMetrics.fromMap(Map<String, dynamic> map) {
    return PerformanceMetrics(
      systemUptime: (map['systemUptime'] ?? 0.0).toDouble(),
      averageResponseTime: (map['averageResponseTime'] ?? 0.0).toDouble(),
      totalApiCalls: map['totalApiCalls'] ?? 0,
      errorCount: map['errorCount'] ?? 0,
      errorRate: (map['errorRate'] ?? 0.0).toDouble(),
      featureUsage: Map<String, int>.from(map['featureUsage'] ?? {}),
      performanceHistory: (map['performanceHistory'] as List<dynamic>? ?? [])
          .map((item) => PerformanceDataPoint.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'systemUptime': systemUptime,
      'averageResponseTime': averageResponseTime,
      'totalApiCalls': totalApiCalls,
      'errorCount': errorCount,
      'errorRate': errorRate,
      'featureUsage': featureUsage,
      'performanceHistory': performanceHistory.map((item) => item.toMap()).toList(),
    };
  }
}

// Data point classes for time series data
class RevenueDataPoint {
  final DateTime date;
  final double value;
  final String? category;

  RevenueDataPoint({
    required this.date,
    required this.value,
    this.category,
  });

  factory RevenueDataPoint.fromMap(Map<String, dynamic> map) {
    return RevenueDataPoint(
      date: (map['date'] as Timestamp).toDate(),
      value: (map['value'] ?? 0.0).toDouble(),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'value': value,
      'category': category,
    };
  }
}

class ParcelDataPoint {
  final DateTime date;
  final int count;
  final String? status;

  ParcelDataPoint({
    required this.date,
    required this.count,
    this.status,
  });

  factory ParcelDataPoint.fromMap(Map<String, dynamic> map) {
    return ParcelDataPoint(
      date: (map['date'] as Timestamp).toDate(),
      count: map['count'] ?? 0,
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'count': count,
      'status': status,
    };
  }
}

class CustomerDataPoint {
  final DateTime date;
  final int count;
  final String? type;

  CustomerDataPoint({
    required this.date,
    required this.count,
    this.type,
  });

  factory CustomerDataPoint.fromMap(Map<String, dynamic> map) {
    return CustomerDataPoint(
      date: (map['date'] as Timestamp).toDate(),
      count: map['count'] ?? 0,
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'count': count,
      'type': type,
    };
  }
}

class DeliveryDataPoint {
  final DateTime date;
  final double averageTime;
  final int count;

  DeliveryDataPoint({
    required this.date,
    required this.averageTime,
    required this.count,
  });

  factory DeliveryDataPoint.fromMap(Map<String, dynamic> map) {
    return DeliveryDataPoint(
      date: (map['date'] as Timestamp).toDate(),
      averageTime: (map['averageTime'] ?? 0.0).toDouble(),
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'averageTime': averageTime,
      'count': count,
    };
  }
}

class PerformanceDataPoint {
  final DateTime date;
  final double uptime;
  final double responseTime;
  final int apiCalls;

  PerformanceDataPoint({
    required this.date,
    required this.uptime,
    required this.responseTime,
    required this.apiCalls,
  });

  factory PerformanceDataPoint.fromMap(Map<String, dynamic> map) {
    return PerformanceDataPoint(
      date: (map['date'] as Timestamp).toDate(),
      uptime: (map['uptime'] ?? 0.0).toDouble(),
      responseTime: (map['responseTime'] ?? 0.0).toDouble(),
      apiCalls: map['apiCalls'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'uptime': uptime,
      'responseTime': responseTime,
      'apiCalls': apiCalls,
    };
  }
}