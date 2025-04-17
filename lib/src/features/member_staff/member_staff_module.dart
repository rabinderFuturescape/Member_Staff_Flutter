import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import 'api/member_staff_api.dart';
import 'providers/member_staff_provider.dart';
import 'screens/verification_flow/mobile_verification_screen.dart';

/// Main entry point for the Member Staff module.
class MemberStaffModule extends StatelessWidget {
  final String baseUrl;
  
  const MemberStaffModule({
    Key? key,
    required this.baseUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(baseUrl: baseUrl),
        ),
        Provider<MemberStaffApi>(
          create: (context) => MemberStaffApi(
            apiClient: Provider.of<ApiClient>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<MemberStaffProvider>(
          create: (context) => MemberStaffProvider(
            api: Provider.of<MemberStaffApi>(context, listen: false),
          ),
        ),
      ],
      child: const MobileVerificationScreen(),
    );
  }
}
