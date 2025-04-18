import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/member_staff_attendance_api.dart';
import '../models/attendance.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';

/// Service for handling staff attendance operations
class AttendanceService {
  final MemberStaffAttendanceApi _attendanceApi;
  final AuthService _authService;
  final ImagePicker _imagePicker;
  
  AttendanceService({
    MemberStaffAttendanceApi? attendanceApi,
    AuthService? authService,
    ImagePicker? imagePicker,
  }) : _attendanceApi = attendanceApi ?? MemberStaffAttendanceApi(apiClient: ApiClient()),
       _authService = authService ?? AuthService(),
       _imagePicker = imagePicker ?? ImagePicker();
  
  /// Get attendance data for a specific month
  Future<Map<DateTime, DayAttendanceStatus>> getAttendanceData(DateTime month) async {
    try {
      final member = await _authService.getCurrentMember();
      final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      
      final attendanceData = await _attendanceApi.getAttendance(
        member.id,
        monthStr,
      );
      
      // Convert the API response to our model
      final Map<DateTime, DayAttendanceStatus> attendanceMap = {};
      
      attendanceData.forEach((dateStr, staffList) {
        final date = DateTime.parse(dateStr);
        final Map<String, StaffAttendance> staffAttendances = {};
        
        for (final staff in staffList) {
          final attendance = StaffAttendance.fromJson(staff);
          staffAttendances[attendance.staffId] = attendance;
        }
        
        attendanceMap[date] = DayAttendanceStatus(
          date: date,
          staffAttendances: staffAttendances,
        );
      });
      
      return attendanceMap;
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      rethrow;
    }
  }
  
  /// Save attendance entries for a specific date
  Future<void> saveAttendance({
    required DateTime date,
    required List<StaffAttendance> attendances,
  }) async {
    try {
      final member = await _authService.getCurrentMember();
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Prepare entries for API
      final entries = attendances
          .where((attendance) => attendance.status != 'not_marked')
          .map((attendance) => attendance.toJson())
          .toList();
      
      if (entries.isEmpty) {
        throw Exception('Please mark at least one attendance');
      }
      
      await _attendanceApi.saveAttendance(
        memberId: member.id,
        unitId: member.unitId,
        date: dateStr,
        entries: entries,
      );
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      rethrow;
    }
  }
  
  /// Take a photo for attendance proof
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        // In a real app, you would upload the image to a server and get a URL
        // For now, we'll just use a placeholder URL
        return 'https://example.com/photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      }
      
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }
  
  /// Get mock staff data for a specific date
  Future<List<StaffAttendance>> getMockStaffData() async {
    // In a real app, you would fetch the staff assigned to this member
    // For now, we'll use mock data
    return [
      StaffAttendance(
        staffId: '1001',
        staffName: 'Rajesh Kumar',
        staffPhoto: 'https://randomuser.me/api/portraits/men/1.jpg',
        staffCategory: 'Domestic Help',
        status: 'not_marked',
      ),
      StaffAttendance(
        staffId: '1002',
        staffName: 'Priya Singh',
        staffPhoto: 'https://randomuser.me/api/portraits/women/2.jpg',
        staffCategory: 'Cook',
        status: 'not_marked',
      ),
      StaffAttendance(
        staffId: '1003',
        staffName: 'Amit Sharma',
        staffPhoto: 'https://randomuser.me/api/portraits/men/3.jpg',
        staffCategory: 'Driver',
        status: 'not_marked',
      ),
    ];
  }
}
