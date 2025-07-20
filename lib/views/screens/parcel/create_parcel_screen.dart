import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/parcel_controller.dart';
import '../../../models/parcel_model.dart';
import '../../../utils/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CreateParcelScreen extends StatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final ParcelController _parcelController = Get.find<ParcelController>();
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Create Parcel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildReceiverInfoStep(),
                _buildAddressStep(),
                _buildParcelDetailsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentStep ? AppTheme.primaryColor : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildReceiverInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receiver Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideX(begin: -0.3, end: 0),
            
            const SizedBox(height: 24),
            
            CustomTextField(
              controller: _parcelController.receiverNameController,
              label: 'Receiver Name',
              hintText: 'Enter receiver\'s full name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter receiver name';
                }
                return null;
              },
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _parcelController.receiverPhoneController,
              label: 'Phone Number',
              hintText: 'Enter receiver\'s phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _parcelController.receiverEmailController,
              label: 'Email (Optional)',
              hintText: 'Enter receiver\'s email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value?.isNotEmpty == true && !GetUtils.isEmail(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Addresses',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(begin: -0.3, end: 0),
          
          const SizedBox(height: 24),
          
          // Sender Address
          _buildAddressSection(
            'Sender Address',
            Icons.home_outlined,
            [
              _parcelController.senderStreetController,
              _parcelController.senderCityController,
              _parcelController.senderStateController,
              _parcelController.senderPostalCodeController,
              _parcelController.senderCountryController,
            ],
            ['Street', 'City', 'State', 'Postal Code', 'Country'],
          ),
          
          const SizedBox(height: 32),
          
          // Receiver Address
          _buildAddressSection(
            'Receiver Address',
            Icons.location_on_outlined,
            [
              _parcelController.receiverStreetController,
              _parcelController.receiverCityController,
              _parcelController.receiverStateController,
              _parcelController.receiverPostalCodeController,
              _parcelController.receiverCountryController,
            ],
            ['Street', 'City', 'State', 'Postal Code', 'Country'],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(
    String title,
    IconData icon,
    List<TextEditingController> controllers,
    List<String> labels,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < controllers.length; i++) ...[
            CustomTextField(
              controller: controllers[i],
              label: labels[i],
              hintText: 'Enter ${labels[i].toLowerCase()}',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter ${labels[i].toLowerCase()}';
                }
                return null;
              },
            ),
            if (i < controllers.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildParcelDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parcel Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(begin: -0.3, end: 0),
          
          const SizedBox(height: 24),
          
          CustomTextField(
            controller: _parcelController.descriptionController,
            label: 'Description',
            hintText: 'What are you shipping?',
            maxLines: 3,
            prefixIcon: Icons.description_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter description';
              }
              return null;
            },
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _parcelController.weightController,
                  label: 'Weight (kg)',
                  hintText: '0.0',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.scale_outlined,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter weight';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Please enter valid weight';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<ParcelType>(
                        value: _parcelController.selectedType.value,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ParcelType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toString().split('.').last.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _parcelController.selectedType.value = value;
                          }
                        },
                      ),
                    ],
                  ),
                )),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 20),
          
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<ParcelPriority>(
                  value: _parcelController.selectedPriority.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ParcelPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _parcelController.selectedPriority.value = value;
                    }
                  },
                ),
              ],
            ),
          )).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _parcelController.notesController,
            label: 'Special Instructions (Optional)',
            hintText: 'Any special handling instructions...',
            maxLines: 2,
            prefixIcon: Icons.note_outlined,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Confirm',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(begin: -0.3, end: 0),
          
          const SizedBox(height: 24),
          
          _buildReviewSection('Receiver Information', [
            'Name: ${_parcelController.receiverNameController.text}',
            'Phone: ${_parcelController.receiverPhoneController.text}',
            if (_parcelController.receiverEmailController.text.isNotEmpty)
              'Email: ${_parcelController.receiverEmailController.text}',
          ]),
          
          const SizedBox(height: 20),
          
          _buildReviewSection('Sender Address', [
            _parcelController.senderStreetController.text,
            '${_parcelController.senderCityController.text}, ${_parcelController.senderStateController.text}',
            '${_parcelController.senderPostalCodeController.text}, ${_parcelController.senderCountryController.text}',
          ]),
          
          const SizedBox(height: 20),
          
          _buildReviewSection('Receiver Address', [
            _parcelController.receiverStreetController.text,
            '${_parcelController.receiverCityController.text}, ${_parcelController.receiverStateController.text}',
            '${_parcelController.receiverPostalCodeController.text}, ${_parcelController.receiverCountryController.text}',
          ]),
          
          const SizedBox(height: 20),
          
          _buildReviewSection('Parcel Details', [
            'Description: ${_parcelController.descriptionController.text}',
            'Weight: ${_parcelController.weightController.text} kg',
            'Type: ${_parcelController.selectedType.value.toString().split('.').last.toUpperCase()}',
            'Priority: ${_parcelController.selectedPriority.value.toString().split('.').last.toUpperCase()}',
            if (_parcelController.notesController.text.isNotEmpty)
              'Notes: ${_parcelController.notesController.text}',
          ]),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(
              gradient: LinearGradient(
                colors: AppTheme.primaryGradient.colors.map((color) => color.withOpacity(0.1)).toList(),
                begin: AppTheme.primaryGradient.begin,
                end: AppTheme.primaryGradient.end,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Cost',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$25.99', // Mock price calculation
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items.where((item) => item.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Previous',
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                isOutlined: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: Obx(() => CustomButton(
              text: _currentStep == 3 ? 'Create Parcel' : 'Next',
              onPressed: _currentStep == 3 ? _createParcel : _nextStep,
              isLoading: _parcelController.isCreating.value,
            )),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _createParcel() {
    _parcelController.createParcel();
  }
}