import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import 'api/feature_request_api.dart';
import 'providers/feature_request_provider.dart';
import 'screens/request_feature_screen.dart';

/// Main entry point for the Feature Request module.
class FeatureRequestModule extends StatelessWidget {
  final String baseUrl;
  
  const FeatureRequestModule({
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
        Provider<FeatureRequestApi>(
          create: (context) => FeatureRequestApi(
            apiClient: Provider.of<ApiClient>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<FeatureRequestProvider>(
          create: (context) => FeatureRequestProvider(
            api: Provider.of<FeatureRequestApi>(context, listen: false),
          ),
        ),
      ],
      child: const RequestFeatureScreen(),
    );
  }
}
