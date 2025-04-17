import 'dart:convert';
import 'dart:io';
import '../../../core/network/api_client.dart';
import '../models/staff.dart';
import '../models/time_slot.dart';
import '../models/schedule.dart';

/// API service for Member Staff module.
/// 
/// This class provides methods for interacting with the Member Staff API endpoints.
/// All methods automatically include authentication and member context.
class MemberStaffApi {
  final ApiClient _apiClient;
  
  MemberStaffApi({required ApiClient apiClient}) : _apiClient = apiClient;
  
  /// Checks if a staff exists with the given mobile number.
  Future<Map<String, dynamic>> checkStaffMobile(String mobile) async {
    return await _apiClient.get('staff/check', queryParams: {'mobile': mobile});
  }
  
  /// Sends an OTP to the given mobile number.
  Future<bool> sendOtp(String mobile) async {
    final response = await _apiClient.post(
      'staff/send-otp',
      body: {'mobile': mobile},
    );
    
    return response['success'] ?? false;
  }
  
  /// Verifies an OTP for the given mobile number.
  Future<bool> verifyOtp(String mobile, String otp) async {
    final response = await _apiClient.post(
      'staff/verify-otp',
      body: {
        'mobile': mobile,
        'otp': otp,
      },
    );
    
    return response['success'] ?? false;
  }
  
  /// Creates a new staff member.
  Future<Staff> createStaff(Map<String, dynamic> staffData) async {
    final response = await _apiClient.post(
      'staff',
      body: staffData,
    );
    
    return Staff.fromJson(response);
  }
  
  /// Verifies a staff member's identity.
  Future<bool> verifyStaffIdentity(String staffId, Map<String, dynamic> identityData) async {
    final response = await _apiClient.put(
      'staff/$staffId/verify',
      body: identityData,
    );
    
    return response['success'] ?? false;
  }
  
  /// Uploads a staff photo and returns the URL.
  Future<String> uploadStaffPhoto(String staffId, File photoFile) async {
    // Convert image to base64
    final bytes = await photoFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    final response = await _apiClient.post(
      'staff/$staffId/photo',
      body: {'photo_base64': base64Image},
    );
    
    return response['photo_url'] ?? '';
  }
  
  /// Gets a staff member's schedule.
  Future<Schedule> getStaffSchedule(String staffId, {DateTime? startDate, DateTime? endDate}) async {
    Map<String, dynamic>? queryParams;
    
    if (startDate != null || endDate != null) {
      queryParams = {};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T').first;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T').first;
      }
    }
    
    final response = await _apiClient.get(
      'staff/$staffId/schedule',
      queryParams: queryParams,
    );
    
    return Schedule.fromJson(response);
  }
  
  /// Updates a staff member's schedule.
  Future<Schedule> updateStaffSchedule(String staffId, Schedule schedule) async {
    final response = await _apiClient.put(
      'staff/$staffId/schedule',
      body: schedule.toJson(),
    );
    
    return Schedule.fromJson(response);
  }
  
  /// Adds a time slot to a staff member's schedule.
  Future<TimeSlot> addTimeSlot(String staffId, TimeSlot timeSlot) async {
    final response = await _apiClient.post(
      'staff/$staffId/schedule/slots',
      body: timeSlot.toJson(),
    );
    
    return TimeSlot.fromJson(response);
  }
  
  /// Updates a time slot in a staff member's schedule.
  Future<TimeSlot> updateTimeSlot(String staffId, TimeSlot oldSlot, TimeSlot newSlot) async {
    final response = await _apiClient.put(
      'staff/$staffId/schedule/slots',
      body: {
        'old_slot': oldSlot.toJson(),
        'new_slot': newSlot.toJson(),
      },
    );
    
    return TimeSlot.fromJson(response);
  }
  
  /// Removes a time slot from a staff member's schedule.
  Future<bool> removeTimeSlot(String staffId, TimeSlot timeSlot) async {
    final response = await _apiClient.delete(
      'staff/$staffId/schedule/slots',
      body: timeSlot.toJson(),
    );
    
    return response['success'] ?? false;
  }
  
  /// Gets all staff assigned to a member.
  Future<List<Staff>> getMemberStaff() async {
    final response = await _apiClient.get('member-staff');
    
    final List<dynamic> staffList = response['data'] ?? [];
    return staffList.map((json) => Staff.fromJson(json)).toList();
  }
  
  /// Assigns a staff to the current member.
  Future<bool> assignStaff(String staffId) async {
    final response = await _apiClient.post(
      'member-staff/assign',
      body: {'staff_id': staffId},
    );
    
    return response['success'] ?? false;
  }
  
  /// Unassigns a staff from the current member.
  Future<bool> unassignStaff(String staffId) async {
    final response = await _apiClient.post(
      'member-staff/unassign',
      body: {'staff_id': staffId},
    );
    
    return response['success'] ?? false;
  }
}
