import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// The main application widget.
class MemberStaffApp extends StatelessWidget {
  const MemberStaffApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member Staff App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
