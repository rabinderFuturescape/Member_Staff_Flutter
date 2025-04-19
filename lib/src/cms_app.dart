import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import '../cms/cms.dart';
import '../screens/cms_home_screen.dart';
import '../screens/cms_about_screen.dart';
import '../screens/cms_faq_screen.dart';
import '../screens/cms_notification_screen.dart';
import '../screens/all_dues_report_screen.dart';

/// The CMS-based application widget.
class CMSBasedApp extends StatelessWidget {
  const CMSBasedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member Staff App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
      ],
      home: const CMSHomeScreen(),
      routes: {
        '/home': (context) => const CMSHomeScreen(),
        '/about': (context) => const CMSAboutScreen(),
        '/faqs': (context) => const CMSFAQScreen(),
        '/notifications': (context) => const CMSNotificationScreen(),
        '/all_dues_report': (context) => const AllDuesReportScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/page/') ?? false) {
          final slug = settings.name!.substring(6);
          return MaterialPageRoute(
            builder: (context) => CMSPageScreen(slug: slug),
          );
        }
        return null;
      },
    );
  }
}
