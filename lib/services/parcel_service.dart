import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/parcel_model.dart';
import '../utils/logger.dart';

class ParcelService extends GetxService {
  static final ParcelService _instance = ParcelService._internal();
  factory ParcelService() => _instance;
  ParcelService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new parcel
  Future<String> createParcel(ParcelModel parcel) async {
    try {
      final docRef = await _firestore.collection('parcels').add(parcel.toMap());
      AppLogger.info('Parcel created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('Error creating parcel: $e');
      rethrow;
    }
  }

  /// Get parcel by ID
  Future<ParcelModel?> getParcel(String parcelId) async {
    try {
      final doc = await _firestore.collection('parcels').doc(parcelId).get();
      if (doc.exists) {
        return ParcelModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting parcel: $e');
      return null;
    }
  }

  /// Get parcel stream for real-time updates
  Stream<ParcelModel?> getParcelStream(String parcelId) {
    return _firestore
        .collection('parcels')
        .doc(parcelId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ParcelModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Get parcels for a user
  Future<List<ParcelModel>> getUserParcels({
    String? userId,
    int limit = 20,
    ParcelStatus? status,
  }) async {
    try {
      final currentUserId = userId ?? _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      Query query = _firestore
          .collection('parcels')
          .where('senderId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ParcelModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting user parcels: $e');
      return [];
    }
  }

  /// Get parcels stream for a user
  Stream<List<ParcelModel>> getUserParcelsStream({
    String? userId,
    int limit = 20,
    ParcelStatus? status,
  }) {
    final currentUserId = userId ?? _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    Query query = _firestore
        .collection('parcels')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ParcelModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Update parcel status
  Future<void> updateParcelStatus(String parcelId, ParcelStatus status, {String? notes}) async {
    try {
      final updateData = {
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (status == ParcelStatus.delivered) {
        updateData['actualDeliveryDate'] = Timestamp.fromDate(DateTime.now());
      }

      await _firestore.collection('parcels').doc(parcelId).update(updateData);
      
      // Add tracking update
      final trackingUpdate = TrackingUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: status,
        description: notes ?? _getStatusDescription(status),
        timestamp: DateTime.now(),
        updatedBy: _auth.currentUser?.uid,
      );

      await addTrackingUpdate(parcelId, trackingUpdate);
      
      AppLogger.info('Updated parcel $parcelId status to $status');
    } catch (e) {
      AppLogger.error('Error updating parcel status: $e');
      rethrow;
    }
  }

  /// Add tracking update
  Future<void> addTrackingUpdate(String parcelId, TrackingUpdate update) async {
    try {
      await _firestore.collection('parcels').doc(parcelId).update({
        'trackingUpdates': FieldValue.arrayUnion([update.toMap()]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      AppLogger.info('Added tracking update for parcel $parcelId');
    } catch (e) {
      AppLogger.error('Error adding tracking update: $e');
      rethrow;
    }
  }

  /// Search parcels by tracking number
  Future<ParcelModel?> searchByTrackingNumber(String trackingNumber) async {
    try {
      final query = await _firestore
          .collection('parcels')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ParcelModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      AppLogger.error('Error searching parcel by tracking number: $e');
      return null;
    }
  }

  /// Update parcel
  Future<void> updateParcel(String parcelId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection('parcels').doc(parcelId).update(updates);
      AppLogger.info('Updated parcel: $parcelId');
    } catch (e) {
      AppLogger.error('Error updating parcel: $e');
      rethrow;
    }
  }

  /// Delete parcel
  Future<void> deleteParcel(String parcelId) async {
    try {
      await _firestore.collection('parcels').doc(parcelId).delete();
      AppLogger.info('Deleted parcel: $parcelId');
    } catch (e) {
      AppLogger.error('Error deleting parcel: $e');
      rethrow;
    }
  }

  /// Get parcels for delivery man
  Future<List<ParcelModel>> getDeliveryManParcels(String deliveryManId) async {
    try {
      final query = await _firestore
          .collection('parcels')
          .where('deliveryManId', isEqualTo: deliveryManId)
          .where('status', whereIn: [
            ParcelStatus.collected.toString().split('.').last,
            ParcelStatus.inTransit.toString().split('.').last,
            ParcelStatus.outForDelivery.toString().split('.').last,
          ])
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => ParcelModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting delivery man parcels: $e');
      return [];
    }
  }

  /// Assign parcel to delivery man
  Future<void> assignParcelToDeliveryMan(String parcelId, String deliveryManId) async {
    try {
      await _firestore.collection('parcels').doc(parcelId).update({
        'deliveryManId': deliveryManId,
        'status': ParcelStatus.collected.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Add tracking update
      final trackingUpdate = TrackingUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: ParcelStatus.collected,
        description: 'Parcel assigned to delivery agent',
        timestamp: DateTime.now(),
        updatedBy: _auth.currentUser?.uid,
      );

      await addTrackingUpdate(parcelId, trackingUpdate);

      AppLogger.info('Assigned parcel $parcelId to delivery man $deliveryManId');
    } catch (e) {
      AppLogger.error('Error assigning parcel to delivery man: $e');
      rethrow;
    }
  }

  /// Generate tracking number
  String generateTrackingNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'TRK${timestamp.toString().substring(8)}${random.toString().padLeft(3, '0')}';
  }

  /// Get status description
  String _getStatusDescription(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return 'Parcel order created and pending confirmation';
      case ParcelStatus.confirmed:
        return 'Parcel confirmed and ready for pickup';
      case ParcelStatus.collected:
        return 'Parcel collected from sender';
      case ParcelStatus.inTransit:
        return 'Parcel is in transit to destination';
      case ParcelStatus.outForDelivery:
        return 'Parcel is out for delivery';
      case ParcelStatus.delivered:
        return 'Parcel delivered successfully';
      case ParcelStatus.cancelled:
        return 'Parcel cancelled';
      case ParcelStatus.returned:
        return 'Parcel returned to sender';
    }
  }

  /// Calculate shipping cost (mock implementation)
  double calculateShippingCost({
    required double weight,
    required double distance,
    required ParcelType type,
    required ParcelPriority priority,
  }) {
    double baseCost = 5.0;
    double weightCost = weight * 2.0;
    double distanceCost = distance * 0.01;
    
    // Type multiplier
    double typeMultiplier = 1.0;
    switch (type) {
      case ParcelType.fragile:
      case ParcelType.electronic:
        typeMultiplier = 1.5;
        break;
      case ParcelType.document:
        typeMultiplier = 0.8;
        break;
      default:
        typeMultiplier = 1.0;
    }

    // Priority multiplier
    double priorityMultiplier = 1.0;
    switch (priority) {
      case ParcelPriority.urgent:
        priorityMultiplier = 2.0;
        break;
      case ParcelPriority.high:
        priorityMultiplier = 1.5;
        break;
      case ParcelPriority.medium:
        priorityMultiplier = 1.0;
        break;
      case ParcelPriority.low:
        priorityMultiplier = 0.8;
        break;
    }

    return (baseCost + weightCost + distanceCost) * typeMultiplier * priorityMultiplier;
  }

  /// Get parcel statistics
  Future<Map<String, int>> getParcelStatistics({String? businessId}) async {
    try {
      Query query = _firestore.collection('parcels');
      
      if (businessId != null) {
        query = query.where('businessId', isEqualTo: businessId);
      } else {
        final currentUserId = _auth.currentUser?.uid;
        if (currentUserId != null) {
          query = query.where('senderId', isEqualTo: currentUserId);
        }
      }

      final snapshot = await query.get();
      final parcels = snapshot.docs
          .map((doc) => ParcelModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final stats = <String, int>{
        'total': parcels.length,
        'pending': 0,
        'inTransit': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (final parcel in parcels) {
        switch (parcel.status) {
          case ParcelStatus.pending:
          case ParcelStatus.confirmed:
            stats['pending'] = (stats['pending'] ?? 0) + 1;
            break;
          case ParcelStatus.collected:
          case ParcelStatus.inTransit:
          case ParcelStatus.outForDelivery:
            stats['inTransit'] = (stats['inTransit'] ?? 0) + 1;
            break;
          case ParcelStatus.delivered:
            stats['delivered'] = (stats['delivered'] ?? 0) + 1;
            break;
          case ParcelStatus.cancelled:
          case ParcelStatus.returned:
            stats['cancelled'] = (stats['cancelled'] ?? 0) + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      AppLogger.error('Error getting parcel statistics: $e');
      return {};
    }
  }
}