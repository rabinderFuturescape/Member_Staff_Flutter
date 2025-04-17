import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/member_staff_provider.dart';
import '../../widgets/logged_in_member_info.dart';
import 'identity_form_screen.dart';

/// Screen for OTP verification of a staff member.
class OtpVerificationScreen extends StatefulWidget {
  final String mobile;
  
  const OtpVerificationScreen({
    Key? key,
    required this.mobile,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  
  int _resendCountdown = 30;
  Timer? _resendTimer;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    _startResendTimer();
  }
  
  @override
  void dispose() {
    _otpController.dispose();
    _animationController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 30;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }
  
  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });
    
    try {
      final provider = Provider.of<MemberStaffProvider>(context, listen: false);
      final otp = _otpController.text.trim();
      
      final success = await provider.verifyOtp(widget.mobile, otp);
      
      if (success && mounted) {
        // Get the staff ID from the check API
        final checkResult = await provider.checkStaffMobile(widget.mobile);
        final staffId = checkResult['staff_id'];
        
        if (staffId != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => IdentityFormScreen(
                staffId: staffId,
                mobile: widget.mobile,
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to get staff information. Please try again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
  
  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) {
      return;
    }
    
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    
    try {
      final provider = Provider.of<MemberStaffProvider>(context, listen: false);
      final success = await provider.sendOtp(widget.mobile);
      
      if (success) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to resend OTP. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
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
              const LoggedInMemberInfo(),
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: _buildOtpInput(),
              ),
              const SizedBox(height: 16),
              _buildResendButton(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              _buildVerifyButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final formattedMobile = '${widget.mobile.substring(0, 2)} ${widget.mobile.substring(2, 7)} ${widget.mobile.substring(7)}';
    
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
          'Enter the 6-digit OTP sent to $formattedMobile',
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
        Text(
          'One-Time Password (OTP)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          decoration: InputDecoration(
            hintText: '6-digit OTP',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'Please enter a valid 6-digit OTP';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildResendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the OTP?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: _resendCountdown > 0 || _isResending ? null : _resendOtp,
          child: _isResending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _resendCountdown > 0
                      ? 'Resend in $_resendCountdown s'
                      : 'Resend OTP',
                ),
        ),
      ],
    );
  }
  
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Verify OTP'),
      ),
    );
  }
}
