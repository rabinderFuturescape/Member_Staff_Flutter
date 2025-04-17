import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';
import '../../../utils/error_handler.dart';
import '../../../utils/api_exception.dart';
import '../../../widgets/animated_form_fields.dart';
import '../../../widgets/micro_interactions.dart';
import '../../../widgets/logged_in_member_info.dart';
import 'otp_verification_screen.dart';

/// Screen for verifying a staff member's mobile number.
class MobileVerificationScreen extends StatefulWidget {
  const MobileVerificationScreen({Key? key}) : super(key: key);

  @override
  State<MobileVerificationScreen> createState() => _MobileVerificationScreenState();
}

class _MobileVerificationScreenState extends State<MobileVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _mobileController = TextEditingController();
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  bool _isLoading = false;
  bool _isValidMobile = false;

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

    // Add listener to validate mobile number
    _mobileController.addListener(_validateMobile);
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateMobile() {
    // Simple validation for 10-digit mobile number
    final mobile = _mobileController.text.trim();
    setState(() {
      _isValidMobile = mobile.length == 10 && int.tryParse(mobile) != null;
    });
  }

  Future<void> _checkMobileNumber() async {
    if (!_isValidMobile) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mobile = '91${_mobileController.text.trim()}';
      final response = await _apiService.checkStaffMobile(mobile);

      if (mounted) {
        if (response['exists'] == true) {
          if (response['verified'] == false) {
            // Staff exists but not verified, proceed to OTP verification
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  mobile: mobile,
                  staffId: response['staff_id'],
                ),
              ),
            );
          } else {
            // Staff already verified
            _showAlreadyVerifiedDialog();
          }
        } else {
          // Staff doesn't exist
          _showStaffNotFoundDialog();
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: _checkMobileNumber,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAlreadyVerifiedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Verified'),
        content: const Text(
          'This staff member is already verified and assigned. Please contact support if you believe this is an error.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStaffNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Staff Not Found'),
        content: const Text(
          'No staff member found with this mobile number. Would you like to register a new staff member?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to staff registration screen
              // This would be implemented separately
            },
            child: const Text('Register New Staff'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Verification'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildMobileInput(),
              const SizedBox(height: 32),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display logged-in member info
        const LoggedInMemberInfo(),
        const SizedBox(height: 16),
        Text(
          'Verify Staff Member',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the mobile number of the staff member you want to verify.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedTextField(
          label: 'Mobile Number',
          hint: 'Enter 10-digit mobile number',
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_android),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a mobile number';
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
        const SizedBox(height: 8),
        Text(
          'We will send an OTP to this number for verification',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Center(
      child: BounceWidget(
        onTap: _isValidMobile && !_isLoading ? _checkMobileNumber : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _isValidMobile
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Verify Mobile Number',
                    style: TextStyle(
                      color: _isValidMobile ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
