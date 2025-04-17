import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final authProvider = AuthProvider();
  await authProvider.initialize();

  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  runApp(const MemberStaffApp());
}
