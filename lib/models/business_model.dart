import 'package:cloud_firestore/cloud_firestore.dart';

enum BusinessType {
  logistics,
  ecommerce,
  courier,
  freight,
  warehouse,
  marketplace
}

enum BusinessPlan {
  starter,
  professional,
  enterprise,
  custom
}

class BusinessModel {
  final String id;
  final String name;
  final String description;
  final BusinessType type;
  final BusinessPlan plan;
  final String ownerId;
  final String email;
  final String phone;
  final AddressModel address;
  final String? website;
  final String? logo;
  final BusinessSettings settings;
  final BusinessMetrics metrics;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic> customFields;

  BusinessModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.plan,
    required this.ownerId,
    required this.email,
    required this.phone,
    required this.address,
    this.website,
    this.logo,
    required this.settings,
    required this.metrics,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.customFields = const {},
  });

  factory BusinessModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: BusinessType.values.firstWhere(
        (e) => e.toString() == 'BusinessType.${data['type']}',
        orElse: () => BusinessType.logistics,
      ),
      plan: BusinessPlan.values.firstWhere(
        (e) => e.toString() == 'BusinessPlan.${data['plan']}',
        orElse: () => BusinessPlan.starter,
      ),
      ownerId: data['ownerId'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: AddressModel.fromMap(data['address'] ?? {}),
      website: data['website'],
      logo: data['logo'],
      settings: BusinessSettings.fromMap(data['settings'] ?? {}),
      metrics: BusinessMetrics.fromMap(data['metrics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      customFields: Map<String, dynamic>.from(data['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'plan': plan.toString().split('.').last,
      'ownerId': ownerId,
      'email': email,
      'phone': phone,
      'address': address.toMap(),
      'website': website,
      'logo': logo,
      'settings': settings.toMap(),
      'metrics': metrics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'customFields': customFields,
    };
  }
}

class BusinessSettings {
  final CurrencySettings currency;
  final NotificationSettings notifications;
  final IntegrationSettings integrations;
  final SecuritySettings security;
  final OperationalSettings operational;

  BusinessSettings({
    required this.currency,
    required this.notifications,
    required this.integrations,
    required this.security,
    required this.operational,
  });

  factory BusinessSettings.fromMap(Map<String, dynamic> map) {
    return BusinessSettings(
      currency: CurrencySettings.fromMap(map['currency'] ?? {}),
      notifications: NotificationSettings.fromMap(map['notifications'] ?? {}),
      integrations: IntegrationSettings.fromMap(map['integrations'] ?? {}),
      security: SecuritySettings.fromMap(map['security'] ?? {}),
      operational: OperationalSettings.fromMap(map['operational'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency.toMap(),
      'notifications': notifications.toMap(),
      'integrations': integrations.toMap(),
      'security': security.toMap(),
      'operational': operational.toMap(),
    };
  }
}

class CurrencySettings {
  final String primaryCurrency;
  final String currencySymbol;
  final List<String> supportedCurrencies;
  final Map<String, double> exchangeRates;

  CurrencySettings({
    this.primaryCurrency = 'USD',
    this.currencySymbol = '\$',
    this.supportedCurrencies = const ['USD', 'EUR', 'GBP', 'INR'],
    this.exchangeRates = const {},
  });

  factory CurrencySettings.fromMap(Map<String, dynamic> map) {
    return CurrencySettings(
      primaryCurrency: map['primaryCurrency'] ?? 'USD',
      currencySymbol: map['currencySymbol'] ?? '\$',
      supportedCurrencies: List<String>.from(map['supportedCurrencies'] ?? ['USD']),
      exchangeRates: Map<String, double>.from(map['exchangeRates'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryCurrency': primaryCurrency,
      'currencySymbol': currencySymbol,
      'supportedCurrencies': supportedCurrencies,
      'exchangeRates': exchangeRates,
    };
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final List<String> notificationTypes;

  NotificationSettings({
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.notificationTypes = const ['orders', 'deliveries', 'payments'],
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      pushNotifications: map['pushNotifications'] ?? true,
      notificationTypes: List<String>.from(map['notificationTypes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'notificationTypes': notificationTypes,
    };
  }
}

class IntegrationSettings {
  final Map<String, bool> enabledIntegrations;
  final Map<String, String> apiKeys;
  final Map<String, Map<String, dynamic>> integrationConfigs;

  IntegrationSettings({
    this.enabledIntegrations = const {},
    this.apiKeys = const {},
    this.integrationConfigs = const {},
  });

  factory IntegrationSettings.fromMap(Map<String, dynamic> map) {
    return IntegrationSettings(
      enabledIntegrations: Map<String, bool>.from(map['enabledIntegrations'] ?? {}),
      apiKeys: Map<String, String>.from(map['apiKeys'] ?? {}),
      integrationConfigs: Map<String, Map<String, dynamic>>.from(
        map['integrationConfigs'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabledIntegrations': enabledIntegrations,
      'apiKeys': apiKeys,
      'integrationConfigs': integrationConfigs,
    };
  }
}

class SecuritySettings {
  final bool twoFactorAuth;
  final bool sslEnabled;
  final int passwordMinLength;
  final bool requirePasswordChange;
  final int sessionTimeout;

  SecuritySettings({
    this.twoFactorAuth = false,
    this.sslEnabled = true,
    this.passwordMinLength = 8,
    this.requirePasswordChange = false,
    this.sessionTimeout = 3600,
  });

  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      twoFactorAuth: map['twoFactorAuth'] ?? false,
      sslEnabled: map['sslEnabled'] ?? true,
      passwordMinLength: map['passwordMinLength'] ?? 8,
      requirePasswordChange: map['requirePasswordChange'] ?? false,
      sessionTimeout: map['sessionTimeout'] ?? 3600,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'twoFactorAuth': twoFactorAuth,
      'sslEnabled': sslEnabled,
      'passwordMinLength': passwordMinLength,
      'requirePasswordChange': requirePasswordChange,
      'sessionTimeout': sessionTimeout,
    };
  }
}

class OperationalSettings {
  final String businessHoursStart;
  final String businessHoursEnd;
  final List<String> operatingDays;
  final String timezone;
  final bool autoAssignDeliveries;
  final int maxDeliveriesPerAgent;

  OperationalSettings({
    this.businessHoursStart = '09:00',
    this.businessHoursEnd = '18:00',
    this.operatingDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    this.timezone = 'UTC',
    this.autoAssignDeliveries = true,
    this.maxDeliveriesPerAgent = 10,
  });

  factory OperationalSettings.fromMap(Map<String, dynamic> map) {
    return OperationalSettings(
      businessHoursStart: map['businessHoursStart'] ?? '09:00',
      businessHoursEnd: map['businessHoursEnd'] ?? '18:00',
      operatingDays: List<String>.from(map['operatingDays'] ?? []),
      timezone: map['timezone'] ?? 'UTC',
      autoAssignDeliveries: map['autoAssignDeliveries'] ?? true,
      maxDeliveriesPerAgent: map['maxDeliveriesPerAgent'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessHoursStart': businessHoursStart,
      'businessHoursEnd': businessHoursEnd,
      'operatingDays': operatingDays,
      'timezone': timezone,
      'autoAssignDeliveries': autoAssignDeliveries,
      'maxDeliveriesPerAgent': maxDeliveriesPerAgent,
    };
  }
}

class BusinessMetrics {
  final int totalParcels;
  final int activeParcels;
  final int deliveredParcels;
  final int pendingParcels;
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalCustomers;
  final int activeCustomers;
  final double averageDeliveryTime;
  final double customerSatisfaction;
  final Map<String, int> monthlyStats;

  BusinessMetrics({
    this.totalParcels = 0,
    this.activeParcels = 0,
    this.deliveredParcels = 0,
    this.pendingParcels = 0,
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.totalCustomers = 0,
    this.activeCustomers = 0,
    this.averageDeliveryTime = 0.0,
    this.customerSatisfaction = 0.0,
    this.monthlyStats = const {},
  });

  factory BusinessMetrics.fromMap(Map<String, dynamic> map) {
    return BusinessMetrics(
      totalParcels: map['totalParcels'] ?? 0,
      activeParcels: map['activeParcels'] ?? 0,
      deliveredParcels: map['deliveredParcels'] ?? 0,
      pendingParcels: map['pendingParcels'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (map['monthlyRevenue'] ?? 0.0).toDouble(),
      totalCustomers: map['totalCustomers'] ?? 0,
      activeCustomers: map['activeCustomers'] ?? 0,
      averageDeliveryTime: (map['averageDeliveryTime'] ?? 0.0).toDouble(),
      customerSatisfaction: (map['customerSatisfaction'] ?? 0.0).toDouble(),
      monthlyStats: Map<String, int>.from(map['monthlyStats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalParcels': totalParcels,
      'activeParcels': activeParcels,
      'deliveredParcels': deliveredParcels,
      'pendingParcels': pendingParcels,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'totalCustomers': totalCustomers,
      'activeCustomers': activeCustomers,
      'averageDeliveryTime': averageDeliveryTime,
      'customerSatisfaction': customerSatisfaction,
      'monthlyStats': monthlyStats,
    };
  }
}

class AddressModel {
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postalCode'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress => '$street, $city, $state, $country $postalCode';
}