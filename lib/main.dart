import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'src/app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/notification_provider.dart';
import 'screens/all_dues_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final authProvider = AuthProvider();
  await authProvider.initialize();

  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  runApp(const MemberStaffApp());
}
