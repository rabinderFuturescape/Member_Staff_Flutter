import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'src/app.dart';
import 'src/cms_app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/notification_provider.dart';
import 'screens/all_dues_report_screen.dart';
import 'cms/cms.dart';
import 'cms/providers/cms_localization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final authProvider = AuthProvider();
  await authProvider.initialize();

  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  // Initialize CMS provider
  final cmsProvider = CMSProvider();
  await cmsProvider.initialize();

  // Run the regular app
  runApp(const MemberStaffApp());
}

/// Launch the CMS-based app
Future<void> launchCMSBasedApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final authProvider = AuthProvider();
  authProvider.initialize();

  final notificationProvider = NotificationProvider();
  notificationProvider.initialize();

  // Initialize CMS provider
  final cmsProvider = CMSProvider();
  await cmsProvider.initialize();

  // Initialize localization provider
  final localizationProvider = CMSLocalizationProvider();
  await localizationProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: cmsProvider),
        ChangeNotifierProvider.value(value: localizationProvider),
      ],
      child: const CMSBasedApp(),
    ),
  );
}
