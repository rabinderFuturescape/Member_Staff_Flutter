import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../../../utils/error_handler.dart';
import '../../../utils/api_exception.dart';
import '../../../widgets/animated_form_fields.dart';
import '../../../widgets/micro_interactions.dart';
import 'verification_success_screen.dart';

/// Screen for capturing staff identity information.
class IdentityFormScreen extends StatefulWidget {
  final int staffId;
  final String mobile;

  const IdentityFormScreen({
    Key? key,
    required this.staffId,
    required this.mobile,
  }) : super(key: key);

  @override
  State<IdentityFormScreen> createState() => _IdentityFormScreenState();
}

class _IdentityFormScreenState extends State<IdentityFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _kinNameController = TextEditingController();
  final TextEditingController _kinMobileController = TextEditingController();
  
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  final ImagePicker _imagePicker = ImagePicker();
  
  int _currentStep = 0;
  bool _isSubmitting = false;
  File? _photoFile;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _aadhaarController.dispose();
    _addressController.dispose();
    _kinNameController.dispose();
    _kinMobileController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _takePicture() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
      maxWidth: 800,
    );
    
    if (photo != null) {
      setState(() {
        _photoFile = File(photo.path);
      });
    }
  }
  
  Future<void> _submitForm() async {
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a photo of the staff member'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Convert image to base64
      final bytes = await _photoFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final data = {
        'aadhaar_number': _aadhaarController.text.trim(),
        'residential_address': _addressController.text.trim(),
        'next_of_kin_name': _kinNameController.text.trim(),
        'next_of_kin_mobile': '91${_kinMobileController.text.trim()}',
        'photo_base64': base64Image,
      };
      
      final success = await _apiService.verifyStaffIdentity(widget.staffId, data);
      
      if (mounted && success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationSuccessScreen(
              staffId: widget.staffId,
              mobile: widget.mobile,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: _submitForm,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Identity Verification'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _nextStep,
            onStepCancel: _previousStep,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    if (_currentStep < 3)
                      Expanded(
                        child: AnimatedButton(
                          text: 'Continue',
                          onPressed: details.onStepContinue,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedButton(
                          text: 'Back',
                          onPressed: details.onStepCancel,
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Capture Photo'),
                content: _buildPhotoStep(),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
              ),
              Step(
                title: const Text('Aadhaar Details'),
                content: _buildAadhaarStep(),
                isActive: _currentStep >= 1,
                state: _currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
              ),
              Step(
                title: const Text('Address Information'),
                content: _buildAddressStep(),
                isActive: _currentStep >= 2,
                state: _currentStep > 2
                    ? StepState.complete
                    : StepState.indexed,
              ),
              Step(
                title: const Text('Next of Kin'),
                content: _buildKinStep(),
                isActive: _currentStep >= 3,
                state: _currentStep > 3
                    ? StepState.complete
                    : StepState.indexed,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _currentStep == 3
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedButton(
                text: 'Submit',
                onPressed: _isSubmitting ? null : _submitForm,
                isLoading: _isSubmitting,
                color: Colors.green,
                icon: const Icon(Icons.check_circle, size: 16),
              ),
            )
          : null,
    );
  }
  
  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Take a clear photo of the staff member\'s face',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Center(
          child: _photoFile == null
              ? Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _photoFile!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Center(
          child: AnimatedButton(
            text: _photoFile == null ? 'Take Photo' : 'Retake Photo',
            onPressed: _takePicture,
            icon: const Icon(Icons.camera_alt, size: 16),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAadhaarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter the staff member\'s Aadhaar details',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          label: 'Aadhaar Number',
          hint: 'Enter 12-digit Aadhaar number',
          controller: _aadhaarController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.credit_card),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Aadhaar number';
            }
            if (value.length != 12 || int.tryParse(value) == null) {
              return 'Please enter a valid 12-digit Aadhaar number';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter the staff member\'s residential address',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          label: 'Residential Address',
          hint: 'Enter complete address with city and pincode',
          controller: _addressController,
          keyboardType: TextInputType.multiline,
          prefixIcon: const Icon(Icons.home),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter residential address';
            }
            if (value.length < 10) {
              return 'Please enter a complete address';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildKinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter next of kin details for emergency contact',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          label: 'Next of Kin Name',
          hint: 'Enter full name',
          controller: _kinNameController,
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter next of kin name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AnimatedTextField(
          label: 'Next of Kin Mobile',
          hint: 'Enter 10-digit mobile number',
          controller: _kinMobileController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter next of kin mobile number';
            }
            if (value.length != 10 || int.tryParse(value) == null) {
              return 'Please enter a valid 10-digit mobile number';
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }
}
