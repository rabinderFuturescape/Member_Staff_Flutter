import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../utils/animation_constants.dart';
import '../../../widgets/animated_form_fields.dart';
import '../../../widgets/micro_interactions.dart';
import '../staff_detail_screen.dart';
import '../staff_schedule_screen.dart';

/// Screen shown after successful staff verification.
class VerificationSuccessScreen extends StatefulWidget {
  final int staffId;
  final String mobile;

  const VerificationSuccessScreen({
    Key? key,
    required this.staffId,
    required this.mobile,
  }) : super(key: key);

  @override
  State<VerificationSuccessScreen> createState() => _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  bool _isLoading = true;
  String? _staffName;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    // Load staff details
    _loadStaffDetails();
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadStaffDetails() async {
    try {
      final staff = await _apiService.getStaffById(widget.staffId.toString());
      
      if (mounted) {
        setState(() {
          _staffName = staff.name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _staffName = 'Staff Member';
          _isLoading = false;
        });
      }
    }
  }
  
  void _viewStaffProfile() {
    // Navigate to staff detail screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StaffDetailScreen(
          staff: _apiService.getStaffById(widget.staffId.toString()),
        ),
      ),
    );
  }
  
  void _setWorkTimings() {
    // Navigate to staff schedule screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StaffScheduleScreen(
          staffId: widget.staffId.toString(),
          staffName: _staffName,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSuccessAnimation(),
                      const SizedBox(height: 32),
                      Text(
                        'Verification Successful!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_staffName has been successfully verified and linked to your unit.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      AnimatedButton(
                        text: 'View Staff Profile',
                        onPressed: _viewStaffProfile,
                        icon: const Icon(Icons.person, size: 16),
                      ),
                      const SizedBox(height: 16),
                      AnimatedButton(
                        text: 'Set Work Timings',
                        onPressed: _setWorkTimings,
                        icon: const Icon(Icons.schedule, size: 16),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Return to Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildSuccessAnimation() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }
}
