import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../../../core/services/api_client.dart';

/// API service for Member Staff Booking module.
class MemberStaffBookingApi {
  final ApiClient _apiClient;
  final String _baseUrl;
  
  MemberStaffBookingApi({
    required ApiClient apiClient,
    String baseUrl = 'https://api.oneapp.in/api',
  }) : _apiClient = apiClient, _baseUrl = baseUrl;
  
  /// Get all bookings for a member
  Future<List<BookingSlotView>> getMemberBookings(String memberId) async {
    final response = await _apiClient.get(
      'member-staff/bookings',
      queryParams: {'member_id': memberId},
    );
    
    return (response as List)
        .map((json) => BookingSlotView.fromJson(json))
        .toList();
  }
  
  /// Create a new booking
  Future<BookingResponse> createBooking(BookingRequest request) async {
    final response = await _apiClient.post(
      'member-staff/booking',
      body: request.toJson(),
    );
    
    return BookingResponse.fromJson(response);
  }
  
  /// Reschedule a booking
  Future<Map<String, dynamic>> rescheduleBooking(
    String bookingId, 
    String newDate, 
    List<int> newHours
  ) async {
    final response = await _apiClient.put(
      'member-staff/booking/$bookingId',
      body: {
        'new_date': newDate,
        'new_hours': newHours,
      },
    );
    
    return response;
  }
  
  /// Cancel a booking
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final response = await _apiClient.delete(
      'member-staff/booking/$bookingId',
    );
    
    return response;
  }
  
  /// Get staff availability for a specific date
  Future<List<HourlyAvailability>> getStaffAvailability(
    String staffId, 
    String date
  ) async {
    final response = await _apiClient.get(
      'member-staff/$staffId/availability',
      queryParams: {'date': date},
    );
    
    return (response as List)
        .map((json) => HourlyAvailability.fromJson(json))
        .toList();
  }
}
