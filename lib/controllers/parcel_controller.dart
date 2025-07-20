import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import '../controllers/auth_controller.dart';
import '../utils/logger.dart';

class ParcelController extends GetxController {
  final ParcelService _parcelService = ParcelService();

  // Observable variables
  final RxList<ParcelModel> parcels = <ParcelModel>[].obs;
  final Rx<ParcelModel?> selectedParcel = Rx<ParcelModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ParcelStatus?> statusFilter = Rx<ParcelStatus?>(null);
  final RxMap<String, int> statistics = <String, int>{}.obs;

  // Form controllers for creating parcels
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiverEmailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Address controllers
  final TextEditingController senderStreetController = TextEditingController();
  final TextEditingController senderCityController = TextEditingController();
  final TextEditingController senderStateController = TextEditingController();
  final TextEditingController senderPostalCodeController = TextEditingController();
  final TextEditingController senderCountryController = TextEditingController();

  final TextEditingController receiverStreetController = TextEditingController();
  final TextEditingController receiverCityController = TextEditingController();
  final TextEditingController receiverStateController = TextEditingController();
  final TextEditingController receiverPostalCodeController = TextEditingController();
  final TextEditingController receiverCountryController = TextEditingController();

  // Selected options
  final Rx<ParcelType> selectedType = ParcelType.package.obs;
  final Rx<ParcelPriority> selectedPriority = ParcelPriority.medium.obs;

  @override
  void onInit() {
    super.onInit();
    loadParcels();
    loadStatistics();
  }

  @override
  void onClose() {
    // Dispose controllers
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    receiverEmailController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    notesController.dispose();
    senderStreetController.dispose();
    senderCityController.dispose();
    senderStateController.dispose();
    senderPostalCodeController.dispose();
    senderCountryController.dispose();
    receiverStreetController.dispose();
    receiverCityController.dispose();
    receiverStateController.dispose();
    receiverPostalCodeController.dispose();
    receiverCountryController.dispose();
    super.onClose();
  }

  /// Load user's parcels
  Future<void> loadParcels() async {
    try {
      isLoading.value = true;
      final userParcels = await _parcelService.getUserParcels(
        status: statusFilter.value,
        limit: 50,
      );
      parcels.value = userParcels;
      AppLogger.info('Loaded ${userParcels.length} parcels');
    } catch (e) {
      AppLogger.error('Error loading parcels: $e');
      Get.snackbar(
        'Error',
        'Failed to load parcels: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load parcel statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await _parcelService.getParcelStatistics();
      statistics.value = stats;
    } catch (e) {
      AppLogger.error('Error loading statistics: $e');
    }
  }

  /// Refresh parcels
  Future<void> refreshParcels() async {
    await loadParcels();
    await loadStatistics();
  }

  /// Search parcels by tracking number
  Future<void> searchParcel(String trackingNumber) async {
    try {
      isLoading.value = true;
      final parcel = await _parcelService.searchByTrackingNumber(trackingNumber);
      if (parcel != null) {
        selectedParcel.value = parcel;
        Get.snackbar(
          'Found',
          'Parcel found: ${parcel.trackingNumber}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Not Found',
          'No parcel found with tracking number: $trackingNumber',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      AppLogger.error('Error searching parcel: $e');
      Get.snackbar(
        'Error',
        'Failed to search parcel: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new parcel
  Future<void> createParcel() async {
    try {
      if (!_validateForm()) return;

      isCreating.value = true;

      final senderAddress = Address(
        street: senderStreetController.text,
        city: senderCityController.text,
        state: senderStateController.text,
        postalCode: senderPostalCodeController.text,
        country: senderCountryController.text,
      );

      final receiverAddress = Address(
        street: receiverStreetController.text,
        city: receiverCityController.text,
        state: receiverStateController.text,
        postalCode: receiverPostalCodeController.text,
        country: receiverCountryController.text,
      );

      final weight = double.tryParse(weightController.text) ?? 1.0;
      final shippingCost = _parcelService.calculateShippingCost(
        weight: weight,
        distance: 100.0, // Mock distance
        type: selectedType.value,
        priority: selectedPriority.value,
      );

      final parcel = ParcelModel(
        id: '',
        trackingNumber: _parcelService.generateTrackingNumber(),
        senderId: Get.find<AuthController>().currentUser?.id ?? '',
        receiverName: receiverNameController.text,
        receiverPhone: receiverPhoneController.text,
        receiverEmail: receiverEmailController.text,
        senderAddress: senderAddress,
        receiverAddress: receiverAddress,
        description: descriptionController.text,
        type: selectedType.value,
        priority: selectedPriority.value,
        weight: weight,
        shippingCost: shippingCost,
        status: ParcelStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        businessId: 'default_business', // TODO: Get from user's business
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );

      final parcelId = await _parcelService.createParcel(parcel);
      
      Get.snackbar(
        'Success',
        'Parcel created successfully! Tracking: ${parcel.trackingNumber}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Clear form
      _clearForm();
      
      // Refresh parcels list
      await loadParcels();
      await loadStatistics();

      // Navigate back
      Get.back();
    } catch (e) {
      AppLogger.error('Error creating parcel: $e');
      Get.snackbar(
        'Error',
        'Failed to create parcel: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreating.value = false;
    }
  }

  /// Update parcel status
  Future<void> updateParcelStatus(String parcelId, ParcelStatus status, {String? notes}) async {
    try {
      await _parcelService.updateParcelStatus(parcelId, status, notes: notes);
      
      Get.snackbar(
        'Success',
        'Parcel status updated to ${status.toString().split('.').last}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh parcels
      await loadParcels();
    } catch (e) {
      AppLogger.error('Error updating parcel status: $e');
      Get.snackbar(
        'Error',
        'Failed to update parcel status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Set status filter
  void setStatusFilter(ParcelStatus? status) {
    statusFilter.value = status;
    loadParcels();
  }

  /// Set selected parcel
  void setSelectedParcel(ParcelModel parcel) {
    selectedParcel.value = parcel;
  }

  /// Get filtered parcels based on search query
  List<ParcelModel> get filteredParcels {
    if (searchQuery.value.isEmpty) {
      return parcels.toList();
    }
    
    return parcels.where((parcel) {
      final query = searchQuery.value.toLowerCase();
      return parcel.trackingNumber.toLowerCase().contains(query) ||
             parcel.receiverName.toLowerCase().contains(query) ||
             parcel.description.toLowerCase().contains(query);
    }).toList();
  }

  /// Get parcels by status
  List<ParcelModel> getParcelsByStatus(ParcelStatus status) {
    return parcels.where((parcel) => parcel.status == status).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Validate form
  bool _validateForm() {
    if (receiverNameController.text.isEmpty) {
      Get.snackbar('Error', 'Receiver name is required');
      return false;
    }
    if (receiverPhoneController.text.isEmpty) {
      Get.snackbar('Error', 'Receiver phone is required');
      return false;
    }
    if (descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Description is required');
      return false;
    }
    if (weightController.text.isEmpty) {
      Get.snackbar('Error', 'Weight is required');
      return false;
    }
    if (senderStreetController.text.isEmpty || senderCityController.text.isEmpty) {
      Get.snackbar('Error', 'Sender address is required');
      return false;
    }
    if (receiverStreetController.text.isEmpty || receiverCityController.text.isEmpty) {
      Get.snackbar('Error', 'Receiver address is required');
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    receiverNameController.clear();
    receiverPhoneController.clear();
    receiverEmailController.clear();
    descriptionController.clear();
    weightController.clear();
    notesController.clear();
    senderStreetController.clear();
    senderCityController.clear();
    senderStateController.clear();
    senderPostalCodeController.clear();
    senderCountryController.clear();
    receiverStreetController.clear();
    receiverCityController.clear();
    receiverStateController.clear();
    receiverPostalCodeController.clear();
    receiverCountryController.clear();
    selectedType.value = ParcelType.package;
    selectedPriority.value = ParcelPriority.medium;
  }

  /// Cancel parcel
  Future<void> cancelParcel(String parcelId) async {
    try {
      await updateParcelStatus(parcelId, ParcelStatus.cancelled, notes: 'Cancelled by user');
    } catch (e) {
      AppLogger.error('Error cancelling parcel: $e');
    }
  }

  /// Get parcel status color
  Color getStatusColor(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return Colors.orange;
      case ParcelStatus.confirmed:
        return Colors.blue;
      case ParcelStatus.collected:
        return Colors.purple;
      case ParcelStatus.inTransit:
        return Colors.indigo;
      case ParcelStatus.outForDelivery:
        return Colors.amber;
      case ParcelStatus.delivered:
        return Colors.green;
      case ParcelStatus.cancelled:
      case ParcelStatus.returned:
        return Colors.red;
    }
  }

  /// Get parcel status icon
  IconData getStatusIcon(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return Icons.pending;
      case ParcelStatus.confirmed:
        return Icons.check_circle_outline;
      case ParcelStatus.collected:
        return Icons.inventory;
      case ParcelStatus.inTransit:
        return Icons.local_shipping;
      case ParcelStatus.outForDelivery:
        return Icons.delivery_dining;
      case ParcelStatus.delivered:
        return Icons.check_circle;
      case ParcelStatus.cancelled:
        return Icons.cancel;
      case ParcelStatus.returned:
        return Icons.keyboard_return;
    }
  }
}