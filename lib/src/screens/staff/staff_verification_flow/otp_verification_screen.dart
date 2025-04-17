import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/api_service.dart';
import '../../../utils/error_handler.dart';
import '../../../utils/api_exception.dart';
import '../../../widgets/animated_form_fields.dart';
import '../../../widgets/micro_interactions.dart';
import 'identity_form_screen.dart';

/// Screen for OTP verification of a staff member.
class OtpVerificationScreen extends StatefulWidget {
  final String mobile;
  final int staffId;

  const OtpVerificationScreen({
    Key? key,
    required this.mobile,
    required this.staffId,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpSent = false;
  int _resendTimer = 0;
  Timer? _timer;
  
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
    
    // Add listeners to OTP text fields
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        _handleOtpInput(i);
      });
    }
  }
  
  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleOtpInput(int index) {
    if (_otpControllers[index].text.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }
  
  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }
  
  bool _isOtpComplete() {
    return _getOtp().length == 6;
  }
  
  Future<void> _sendOtp() async {
    if (_isSendingOtp) return;
    
    setState(() {
      _isSendingOtp = true;
    });
    
    try {
      await _apiService.sendOtp(widget.mobile);
      
      if (mounted) {
        setState(() {
          _otpSent = true;
          _resendTimer = 30; // 30 seconds cooldown
          _startResendTimer();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: _sendOtp,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }
  
  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  Future<void> _verifyOtp() async {
    if (_isVerifyingOtp || !_isOtpComplete()) return;
    
    setState(() {
      _isVerifyingOtp = true;
    });
    
    try {
      final otp = _getOtp();
      final success = await _apiService.verifyOtp(widget.mobile, otp);
      
      if (mounted) {
        if (success) {
          // OTP verification successful, navigate to identity form
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => IdentityFormScreen(
                staffId: widget.staffId,
                mobile: widget.mobile,
              ),
            ),
          );
        } else {
          // OTP verification failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: _verifyOtp,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingOtp = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
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
              _buildOtpInput(),
              const SizedBox(height: 32),
              _buildActionButtons(),
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
        Text(
          'OTP Verification',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A 6-digit OTP will be sent to ${widget.mobile.substring(0, 2)} ${widget.mobile.substring(2, 7)} ${widget.mobile.substring(7)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 45,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_otpSent || _resendTimer == 0)
          AnimatedButton(
            text: _otpSent ? 'Resend OTP' : 'Send OTP',
            onPressed: _isSendingOtp ? null : _sendOtp,
            isLoading: _isSendingOtp,
            icon: const Icon(Icons.send, size: 16),
          )
        else
          Text(
            'Resend OTP in $_resendTimer seconds',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 16),
        AnimatedButton(
          text: 'Verify OTP',
          onPressed: _otpSent && _isOtpComplete() && !_isVerifyingOtp
              ? _verifyOtp
              : null,
          isLoading: _isVerifyingOtp,
          color: Colors.green,
          icon: const Icon(Icons.check_circle, size: 16),
        ),
      ],
    );
  }
}
