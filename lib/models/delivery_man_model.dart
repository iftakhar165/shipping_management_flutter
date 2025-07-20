import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shipping_management_app/models/user_model.dart';

enum DeliveryManStatus { available, busy, offline }

class DeliveryManModel extends UserModel {
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final DeliveryManStatus deliveryStatus;
  final double rating;
  final int totalDeliveries;
  final int completedDeliveries;
  final List<String> assignedParcels;
  final DateTime? lastActiveAt;
  final double? currentLatitude;
  final double? currentLongitude;

  DeliveryManModel({
    required super.id,
    required super.email,
    required super.name,
    super.phoneNumber,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    this.deliveryStatus = DeliveryManStatus.available,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.completedDeliveries = 0,
    this.assignedParcels = const [],
    this.lastActiveAt,
    this.currentLatitude,
    this.currentLongitude,
  }) : super(role: UserRole.deliveryMan);

  factory DeliveryManModel.fromMap(Map<String, dynamic> map) {
    return DeliveryManModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      vehicleType: map['vehicleType'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      deliveryStatus: DeliveryManStatus.values.firstWhere(
        (status) => status.toString() == 'DeliveryManStatus.${map['deliveryStatus']}',
        orElse: () => DeliveryManStatus.available,
      ),
      rating: map['rating']?.toDouble() ?? 0.0,
      totalDeliveries: map['totalDeliveries'] ?? 0,
      completedDeliveries: map['completedDeliveries'] ?? 0,
      assignedParcels: List<String>.from(map['assignedParcels'] ?? []),
      lastActiveAt: map['lastActiveAt'] != null
          ? (map['lastActiveAt'] as Timestamp).toDate()
          : null,
      currentLatitude: map['currentLatitude']?.toDouble(),
      currentLongitude: map['currentLongitude']?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    baseMap.addAll({
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'deliveryStatus': deliveryStatus.toString().split('.').last,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'completedDeliveries': completedDeliveries,
      'assignedParcels': assignedParcels,
      'lastActiveAt': lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!)
          : null,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    });
    return baseMap;
  }

  DeliveryManModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? vehicleType,
    String? vehicleNumber,
    String? licenseNumber,
    DeliveryManStatus? deliveryStatus,
    double? rating,
    int? totalDeliveries,
    int? completedDeliveries,
    List<String>? assignedParcels,
    DateTime? lastActiveAt,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return DeliveryManModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      assignedParcels: assignedParcels ?? this.assignedParcels,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }

  double get successRate {
    if (totalDeliveries == 0) return 0.0;
    return (completedDeliveries / totalDeliveries) * 100;
  }

  bool get isOnline => 
      deliveryStatus != DeliveryManStatus.offline &&
      lastActiveAt != null &&
      DateTime.now().difference(lastActiveAt!).inMinutes < 15;
}