import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/member_staff_api.dart';
import '../models/staff.dart';
import '../models/time_slot.dart';
import '../models/schedule.dart';
import '../../../core/exceptions/api_exception.dart';

/// Provider for managing Member Staff data and operations.
class MemberStaffProvider with ChangeNotifier {
  final MemberStaffApi _api;
  
  List<Staff> _staffList = [];
  Staff? _selectedStaff;
  Schedule? _selectedStaffSchedule;
  bool _isLoading = false;
  String? _error;
  
  MemberStaffProvider({required MemberStaffApi api}) : _api = api;
  
  // Getters
  List<Staff> get staffList => _staffList;
  Staff? get selectedStaff => _selectedStaff;
  Schedule? get selectedStaffSchedule => _selectedStaffSchedule;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Sets the loading state and notifies listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Sets an error message and notifies listeners.
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  /// Clears any error message and notifies listeners.
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Loads all staff assigned to the current member.
  Future<void> loadMemberStaff() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _staffList = await _api.getMemberStaff();
      notifyListeners();
    } on ApiException catch (e) {
      _setError('Failed to load staff: ${e.message}');
    } catch (e) {
      _setError('Failed to load staff: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Selects a staff member and loads their schedule.
  Future<void> selectStaff(Staff staff) async {
    _selectedStaff = staff;
    notifyListeners();
    
    await loadStaffSchedule(staff.id);
  }
  
  /// Loads a staff member's schedule.
  Future<void> loadStaffSchedule(String staffId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      _selectedStaffSchedule = await _api.getStaffSchedule(staffId);
      notifyListeners();
    } on ApiException catch (e) {
      _setError('Failed to load schedule: ${e.message}');
    } catch (e) {
      _setError('Failed to load schedule: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Checks if a staff exists with the given mobile number.
  Future<Map<String, dynamic>> checkStaffMobile(String mobile) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.checkStaffMobile(mobile);
      return result;
    } on ApiException catch (e) {
      _setError('Failed to check staff mobile: ${e.message}');
      rethrow;
    } catch (e) {
      _setError('Failed to check staff mobile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sends an OTP to the given mobile number.
  Future<bool> sendOtp(String mobile) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.sendOtp(mobile);
      return result;
    } on ApiException catch (e) {
      _setError('Failed to send OTP: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to send OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Verifies an OTP for the given mobile number.
  Future<bool> verifyOtp(String mobile, String otp) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.verifyOtp(mobile, otp);
      return result;
    } on ApiException catch (e) {
      _setError('Failed to verify OTP: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to verify OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Creates a new staff member.
  Future<Staff?> createStaff(Map<String, dynamic> staffData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final staff = await _api.createStaff(staffData);
      _staffList = [..._staffList, staff];
      notifyListeners();
      return staff;
    } on ApiException catch (e) {
      _setError('Failed to create staff: ${e.message}');
      return null;
    } catch (e) {
      _setError('Failed to create staff: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Verifies a staff member's identity.
  Future<bool> verifyStaffIdentity(String staffId, Map<String, dynamic> identityData, File photoFile) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // First upload the photo
      final photoUrl = await _api.uploadStaffPhoto(staffId, photoFile);
      
      // Then verify the identity with the photo URL
      final verifyData = {
        ...identityData,
        'photo_url': photoUrl,
      };
      
      final result = await _api.verifyStaffIdentity(staffId, verifyData);
      
      if (result) {
        // Update the staff in the list
        final index = _staffList.indexWhere((staff) => staff.id == staffId);
        if (index >= 0) {
          _staffList[index] = _staffList[index].copyWith(
            isVerified: true,
            aadhaarNumber: identityData['aadhaar_number'],
            residentialAddress: identityData['residential_address'],
            nextOfKinName: identityData['next_of_kin_name'],
            nextOfKinMobile: identityData['next_of_kin_mobile'],
            photoUrl: photoUrl,
          );
          notifyListeners();
        }
      }
      
      return result;
    } on ApiException catch (e) {
      _setError('Failed to verify staff identity: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to verify staff identity: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Adds a time slot to a staff member's schedule.
  Future<bool> addTimeSlot(String staffId, TimeSlot timeSlot) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.addTimeSlot(staffId, timeSlot);
      
      // Update the local schedule
      if (_selectedStaffSchedule != null && _selectedStaffSchedule!.staffId == staffId) {
        _selectedStaffSchedule = _selectedStaffSchedule!.addTimeSlot(result);
        notifyListeners();
      }
      
      return true;
    } on ApiException catch (e) {
      _setError('Failed to add time slot: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to add time slot: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates a time slot in a staff member's schedule.
  Future<bool> updateTimeSlot(String staffId, TimeSlot oldSlot, TimeSlot newSlot) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.updateTimeSlot(staffId, oldSlot, newSlot);
      
      // Update the local schedule
      if (_selectedStaffSchedule != null && _selectedStaffSchedule!.staffId == staffId) {
        _selectedStaffSchedule = _selectedStaffSchedule!.updateTimeSlot(oldSlot, result);
        notifyListeners();
      }
      
      return true;
    } on ApiException catch (e) {
      _setError('Failed to update time slot: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to update time slot: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Removes a time slot from a staff member's schedule.
  Future<bool> removeTimeSlot(String staffId, TimeSlot timeSlot) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.removeTimeSlot(staffId, timeSlot);
      
      if (result) {
        // Update the local schedule
        if (_selectedStaffSchedule != null && _selectedStaffSchedule!.staffId == staffId) {
          _selectedStaffSchedule = _selectedStaffSchedule!.removeTimeSlot(timeSlot);
          notifyListeners();
        }
      }
      
      return result;
    } on ApiException catch (e) {
      _setError('Failed to remove time slot: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to remove time slot: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Assigns a staff to the current member.
  Future<bool> assignStaff(String staffId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.assignStaff(staffId);
      
      if (result) {
        // Reload the staff list
        await loadMemberStaff();
      }
      
      return result;
    } on ApiException catch (e) {
      _setError('Failed to assign staff: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to assign staff: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Unassigns a staff from the current member.
  Future<bool> unassignStaff(String staffId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _api.unassignStaff(staffId);
      
      if (result) {
        // Remove the staff from the list
        _staffList = _staffList.where((staff) => staff.id != staffId).toList();
        
        // Clear selected staff if it was the one unassigned
        if (_selectedStaff?.id == staffId) {
          _selectedStaff = null;
          _selectedStaffSchedule = null;
        }
        
        notifyListeners();
      }
      
      return result;
    } on ApiException catch (e) {
      _setError('Failed to unassign staff: ${e.message}');
      return false;
    } catch (e) {
      _setError('Failed to unassign staff: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
