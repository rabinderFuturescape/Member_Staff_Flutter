import 'package:flutter/material.dart';
import 'screens/member_staff_search_screen.dart';
import 'screens/booking_list_screen.dart';
import 'screens/member_staff_booking_screen.dart';
import 'screens/calendar_booking_screen.dart';

/// Module for Member Staff Booking feature
class MemberStaffBookingModule {
  /// Register routes for this module
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/member-staff/search': (context) => const MemberStaffSearchScreen(),
      '/member-staff/bookings': (context) => const BookingListScreen(),
      '/member-staff/bookings/calendar': (context) => const CalendarBookingScreen(),
      '/member-staff/book': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return MemberStaffBookingScreen(
          staffId: args['staffId'],
          staffName: args['staffName'],
        );
      },
    };
  }
}
