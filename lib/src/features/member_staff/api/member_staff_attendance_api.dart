import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';

/// API service for Member Staff Attendance module.
class MemberStaffAttendanceApi {
  final ApiClient _apiClient;
  final String _baseUrl;
  
  MemberStaffAttendanceApi({
    required ApiClient apiClient,
    String baseUrl = 'https://api.oneapp.in/api',
  }) : _apiClient = apiClient, _baseUrl = baseUrl;
  
  /// Get attendance for a member for a given month
  Future<Map<String, List<Map<String, dynamic>>>> getAttendance(String memberId, String month) async {
    final response = await _apiClient.get(
      'member-staff/attendance',
      queryParams: {
        'member_id': memberId,
        'month': month,
      },
    );
    
    return Map<String, List<Map<String, dynamic>>>.from(response);
  }
  
  /// Save attendance entries for a specific date
  Future<Map<String, dynamic>> saveAttendance({
    required String memberId,
    required String unitId,
    required String date,
    required List<Map<String, dynamic>> entries,
  }) async {
    final response = await _apiClient.post(
      'member-staff/attendance',
      body: {
        'member_id': memberId,
        'unit_id': unitId,
        'date': date,
        'entries': entries,
      },
    );
    
    return response;
  }
}
