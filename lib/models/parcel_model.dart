import 'package:cloud_firestore/cloud_firestore.dart';

enum ParcelStatus {
  pending,
  confirmed,
  collected,
  inTransit,
  outForDelivery,
  delivered,
  cancelled,
  returned
}

enum ParcelType { document, package, fragile, electronic, clothing, food, other }

enum ParcelPriority { low, medium, high, urgent }

class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      landmark: map['landmark'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress {
    var address = '$street, $city, $state $postalCode, $country';
    if (landmark != null && landmark!.isNotEmpty) {
      address = '$address (Near $landmark)';
    }
    return address;
  }
}

class ParcelModel {
  final String id;
  final String trackingNumber;
  final String senderId;
  final String? receiverId;
  final String receiverName;
  final String receiverPhone;
  final String receiverEmail;
  final Address senderAddress;
  final Address receiverAddress;
  final String description;
  final ParcelType type;
  final ParcelPriority priority;
  final double weight;
  final double? length;
  final double? width;
  final double? height;
  final double shippingCost;
  final ParcelStatus status;
  final String? deliveryManId;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final List<String> imageUrls;
  final List<TrackingUpdate> trackingUpdates;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final PaymentInfo? paymentInfo;
  final InsuranceInfo? insuranceInfo;
  final CustomsInfo? customsInfo;
  final List<ServiceAddon> serviceAddons;
  final String businessId;
  final double? codAmount;
  final bool isFragile;
  final bool requiresSignature;
  final Map<String, dynamic> customFields;

  ParcelModel({
    required this.id,
    required this.trackingNumber,
    required this.senderId,
    this.receiverId,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverEmail,
    required this.senderAddress,
    required this.receiverAddress,
    required this.description,
    required this.type,
    required this.priority,
    required this.weight,
    this.length,
    this.width,
    this.height,
    required this.shippingCost,
    required this.status,
    this.deliveryManId,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.imageUrls = const [],
    this.trackingUpdates = const [],
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.paymentInfo,
    this.insuranceInfo,
    this.customsInfo,
    this.serviceAddons = const [],
    required this.businessId,
    this.codAmount,
    this.isFragile = false,
    this.requiresSignature = false,
    this.customFields = const {},
  });

  factory ParcelModel.fromMap(Map<String, dynamic> map) {
    return ParcelModel(
      id: map['id'] ?? '',
      trackingNumber: map['trackingNumber'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      receiverName: map['receiverName'] ?? '',
      receiverPhone: map['receiverPhone'] ?? '',
      receiverEmail: map['receiverEmail'] ?? '',
      senderAddress: Address.fromMap(map['senderAddress'] ?? {}),
      receiverAddress: Address.fromMap(map['receiverAddress'] ?? {}),
      description: map['description'] ?? '',
      type: ParcelType.values.firstWhere(
        (type) => type.toString() == 'ParcelType.${map['type']}',
        orElse: () => ParcelType.other,
      ),
      priority: ParcelPriority.values.firstWhere(
        (priority) => priority.toString() == 'ParcelPriority.${map['priority']}',
        orElse: () => ParcelPriority.medium,
      ),
      weight: map['weight']?.toDouble() ?? 0.0,
      length: map['length']?.toDouble(),
      width: map['width']?.toDouble(),
      height: map['height']?.toDouble(),
      shippingCost: map['shippingCost']?.toDouble() ?? 0.0,
      status: ParcelStatus.values.firstWhere(
        (status) => status.toString() == 'ParcelStatus.${map['status']}',
        orElse: () => ParcelStatus.pending,
      ),
      deliveryManId: map['deliveryManId'],
      estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
          ? (map['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      actualDeliveryDate: map['actualDeliveryDate'] != null
          ? (map['actualDeliveryDate'] as Timestamp).toDate()
          : null,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      trackingUpdates: (map['trackingUpdates'] as List<dynamic>? ?? [])
          .map((update) => TrackingUpdate.fromMap(update))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      notes: map['notes'],
      paymentInfo: map['paymentInfo'] != null 
          ? PaymentInfo.fromMap(map['paymentInfo'])
          : null,
      insuranceInfo: map['insuranceInfo'] != null
          ? InsuranceInfo.fromMap(map['insuranceInfo'])
          : null,
      customsInfo: map['customsInfo'] != null
          ? CustomsInfo.fromMap(map['customsInfo'])
          : null,
      serviceAddons: (map['serviceAddons'] as List<dynamic>? ?? [])
          .map((addon) => ServiceAddon.fromMap(addon))
          .toList(),
      businessId: map['businessId'] ?? '',
      codAmount: map['codAmount']?.toDouble(),
      isFragile: map['isFragile'] ?? false,
      requiresSignature: map['requiresSignature'] ?? false,
      customFields: Map<String, dynamic>.from(map['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'senderId': senderId,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverEmail': receiverEmail,
      'senderAddress': senderAddress.toMap(),
      'receiverAddress': receiverAddress.toMap(),
      'description': description,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'weight': weight,
      'length': length,
      'width': width,
      'height': height,
      'shippingCost': shippingCost,
      'status': status.toString().split('.').last,
      'deliveryManId': deliveryManId,
      'estimatedDeliveryDate': estimatedDeliveryDate != null
          ? Timestamp.fromDate(estimatedDeliveryDate!)
          : null,
      'actualDeliveryDate': actualDeliveryDate != null
          ? Timestamp.fromDate(actualDeliveryDate!)
          : null,
      'imageUrls': imageUrls,
      'trackingUpdates': trackingUpdates.map((update) => update.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
      'paymentInfo': paymentInfo?.toMap(),
      'insuranceInfo': insuranceInfo?.toMap(),
      'customsInfo': customsInfo?.toMap(),
      'serviceAddons': serviceAddons.map((addon) => addon.toMap()).toList(),
      'businessId': businessId,
      'codAmount': codAmount,
      'isFragile': isFragile,
      'requiresSignature': requiresSignature,
      'customFields': customFields,
    };
  }

  ParcelModel copyWith({
    String? id,
    String? trackingNumber,
    String? senderId,
    String? receiverId,
    String? receiverName,
    String? receiverPhone,
    String? receiverEmail,
    Address? senderAddress,
    Address? receiverAddress,
    String? description,
    ParcelType? type,
    ParcelPriority? priority,
    double? weight,
    double? length,
    double? width,
    double? height,
    double? shippingCost,
    ParcelStatus? status,
    String? deliveryManId,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    List<String>? imageUrls,
    List<TrackingUpdate>? trackingUpdates,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return ParcelModel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      senderAddress: senderAddress ?? this.senderAddress,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      shippingCost: shippingCost ?? this.shippingCost,
      status: status ?? this.status,
      deliveryManId: deliveryManId ?? this.deliveryManId,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      imageUrls: imageUrls ?? this.imageUrls,
      trackingUpdates: trackingUpdates ?? this.trackingUpdates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}

class TrackingUpdate {
  final String id;
  final ParcelStatus status;
  final String description;
  final DateTime timestamp;
  final String? location;
  final String? updatedBy;

  TrackingUpdate({
    required this.id,
    required this.status,
    required this.description,
    required this.timestamp,
    this.location,
    this.updatedBy,
  });

  factory TrackingUpdate.fromMap(Map<String, dynamic> map) {
    return TrackingUpdate(
      id: map['id'] ?? '',
      status: ParcelStatus.values.firstWhere(
        (status) => status.toString() == 'ParcelStatus.${map['status']}',
        orElse: () => ParcelStatus.pending,
      ),
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      location: map['location'],
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.toString().split('.').last,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'updatedBy': updatedBy,
    };
  }
}

class PaymentInfo {
  final String method; // 'cash', 'card', 'digital_wallet', 'cod'
  final String status; // 'pending', 'paid', 'failed', 'refunded'
  final double amount;
  final String? transactionId;
  final DateTime? paymentDate;
  final Map<String, dynamic> details;

  PaymentInfo({
    required this.method,
    required this.status,
    required this.amount,
    this.transactionId,
    this.paymentDate,
    this.details = const {},
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      method: map['method'] ?? '',
      status: map['status'] ?? 'pending',
      amount: (map['amount'] ?? 0.0).toDouble(),
      transactionId: map['transactionId'],
      paymentDate: map['paymentDate'] != null
          ? (map['paymentDate'] as Timestamp).toDate()
          : null,
      details: Map<String, dynamic>.from(map['details'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'status': status,
      'amount': amount,
      'transactionId': transactionId,
      'paymentDate': paymentDate != null
          ? Timestamp.fromDate(paymentDate!)
          : null,
      'details': details,
    };
  }
}

class InsuranceInfo {
  final bool isInsured;
  final double coverage;
  final double premium;
  final String provider;
  final String policyNumber;
  final Map<String, dynamic> terms;

  InsuranceInfo({
    required this.isInsured,
    required this.coverage,
    required this.premium,
    required this.provider,
    required this.policyNumber,
    this.terms = const {},
  });

  factory InsuranceInfo.fromMap(Map<String, dynamic> map) {
    return InsuranceInfo(
      isInsured: map['isInsured'] ?? false,
      coverage: (map['coverage'] ?? 0.0).toDouble(),
      premium: (map['premium'] ?? 0.0).toDouble(),
      provider: map['provider'] ?? '',
      policyNumber: map['policyNumber'] ?? '',
      terms: Map<String, dynamic>.from(map['terms'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isInsured': isInsured,
      'coverage': coverage,
      'premium': premium,
      'provider': provider,
      'policyNumber': policyNumber,
      'terms': terms,
    };
  }
}

class CustomsInfo {
  final bool isInternational;
  final String contentsType;
  final double declaredValue;
  final String currency;
  final List<CustomsItem> items;
  final Map<String, String> documents;

  CustomsInfo({
    required this.isInternational,
    required this.contentsType,
    required this.declaredValue,
    required this.currency,
    required this.items,
    this.documents = const {},
  });

  factory CustomsInfo.fromMap(Map<String, dynamic> map) {
    return CustomsInfo(
      isInternational: map['isInternational'] ?? false,
      contentsType: map['contentsType'] ?? '',
      declaredValue: (map['declaredValue'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => CustomsItem.fromMap(item))
          .toList(),
      documents: Map<String, String>.from(map['documents'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isInternational': isInternational,
      'contentsType': contentsType,
      'declaredValue': declaredValue,
      'currency': currency,
      'items': items.map((item) => item.toMap()).toList(),
      'documents': documents,
    };
  }
}

class CustomsItem {
  final String description;
  final int quantity;
  final double value;
  final double weight;
  final String originCountry;

  CustomsItem({
    required this.description,
    required this.quantity,
    required this.value,
    required this.weight,
    required this.originCountry,
  });

  factory CustomsItem.fromMap(Map<String, dynamic> map) {
    return CustomsItem(
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 1,
      value: (map['value'] ?? 0.0).toDouble(),
      weight: (map['weight'] ?? 0.0).toDouble(),
      originCountry: map['originCountry'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'value': value,
      'weight': weight,
      'originCountry': originCountry,
    };
  }
}

class ServiceAddon {
  final String id;
  final String name;
  final String description;
  final double cost;
  final bool isActive;
  final Map<String, dynamic> configuration;

  ServiceAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    this.isActive = true,
    this.configuration = const {},
  });

  factory ServiceAddon.fromMap(Map<String, dynamic> map) {
    return ServiceAddon(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? true,
      configuration: Map<String, dynamic>.from(map['configuration'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'isActive': isActive,
      'configuration': configuration,
    };
  }
}