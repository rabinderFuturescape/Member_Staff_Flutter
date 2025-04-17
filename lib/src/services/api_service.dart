import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member.dart';
import '../models/staff.dart';
import '../models/staff_scope.dart';
import '../models/society_staff.dart';
import '../models/member_staff.dart';
import '../models/member_staff_assignment.dart';
import '../models/schedule.dart';
import 'auth_service.dart';
import '../utils/api_exception.dart';
import '../utils/http_helper.dart';

/// Service class for handling API communication.
class ApiService {
  final String baseUrl;
  final HttpHelper _httpHelper;
  final AuthService _authService;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    AuthService? authService,
    HttpHelper? httpHelper,
  }) :
    _authService = authService ?? AuthService(),
    _httpHelper = httpHelper ?? HttpHelper(
      client: client,
      authService: authService ?? AuthService(),
    );

  /// Fetches all members from the API.
  Future<List<Member>> getMembers() async {
    try {
      final data = await _httpHelper.get('$baseUrl/members');
      final List<dynamic> membersList = data as List<dynamic>;
      return membersList.map((json) => Member.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to load members: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to load members: $e');
    }
  }

  /// Fetches all staff from the API.
  Future<List<Staff>> getStaff() async {
    try {
      final data = await _httpHelper.get('$baseUrl/staff');
      final List<dynamic> staffList = data as List<dynamic>;
      return staffList.map((json) => Staff.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to load staff: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to load staff: $e');
    }
  }

  /// Fetches staff by scope (society or member).
  Future<List<Staff>> getStaffByScope(StaffScope scope) async {
    try {
      final data = await _httpHelper.get('$baseUrl/staff?staff_scope=${scope.name}');
      final List<dynamic> staffList = data as List<dynamic>;

      if (scope == StaffScope.society) {
        return staffList.map((json) => SocietyStaff.fromJson(json)).toList();
      } else {
        return staffList.map((json) => MemberStaff.fromJson(json)).toList();
      }
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to load staff by scope: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to load staff by scope: $e');
    }
  }

  /// Fetches a staff member by ID.
  Future<Staff> getStaffById(String staffId) async {
    try {
      final data = await _httpHelper.get('$baseUrl/staff/$staffId');
      final staffScope = StaffScopeExtension.fromString(data['staff_scope'] ?? 'member');

      if (staffScope == StaffScope.society) {
        return SocietyStaff.fromJson(data);
      } else {
        return MemberStaff.fromJson(data);
      }
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to load staff: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to load staff: $e');
    }
  }

  /// Creates a new member.
  Future<Member> createMember(Member member) async {
    try {
      final data = await _httpHelper.post(
        '$baseUrl/members',
        body: member.toJson(),
      );
      return Member.fromJson(data);
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to create member: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to create member: $e');
    }
  }

  /// Creates a new society staff member.
  Future<SocietyStaff> createSocietyStaff(SocietyStaff staff) async {
    try {
      final data = await _httpHelper.post(
        '$baseUrl/staff',
        body: staff.toJson(),
      );
      return SocietyStaff.fromJson(data);
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to create society staff: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to create society staff: $e');
    }
  }

  /// Creates a new member staff or assigns an existing one.
  /// Returns a tuple of (MemberStaff, bool) where the bool indicates if a new staff was created.
  Future<(MemberStaff, bool)> createOrAssignMemberStaff(MemberStaff staff, String memberId) async {
    try {
      // First, check if staff with this phone number already exists
      final checkResponse = await _client.get(
        Uri.parse('$baseUrl/staff/check?phone=${staff.phone}'),
      );

      if (checkResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(checkResponse.body);
        final bool exists = data['exists'] ?? false;

        if (exists) {
          // Staff exists, get the staff and assign to member
          final String staffId = data['staff_id'];
          final getResponse = await _client.get(
            Uri.parse('$baseUrl/staff/$staffId'),
          );

          if (getResponse.statusCode == 200) {
            final existingStaff = MemberStaff.fromJson(json.decode(getResponse.body));

            // Assign the staff to the member
            await assignMemberStaff(memberId, existingStaff.id);

            return (existingStaff, false);
          } else {
            throw Exception('Failed to get existing staff: ${getResponse.statusCode}');
          }
        } else {
          // Staff doesn't exist, create a new one
          final createResponse = await _client.post(
            Uri.parse('$baseUrl/staff'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(staff.toJson()),
          );

          if (createResponse.statusCode == 201) {
            final newStaff = MemberStaff.fromJson(json.decode(createResponse.body));

            // Assign the staff to the member
            await assignMemberStaff(memberId, newStaff.id);

            return (newStaff, true);
          } else {
            throw Exception('Failed to create member staff: ${createResponse.statusCode}');
          }
        }
      } else {
        throw Exception('Failed to check staff existence: ${checkResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create or assign member staff: $e');
    }
  }

  /// Assigns a staff to a member.
  Future<MemberStaffAssignment> assignMemberStaff(String memberId, String staffId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/member-staff/assign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'member_id': memberId,
          'staff_id': staffId,
        }),
      );

      if (response.statusCode == 201) {
        return MemberStaffAssignment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to assign staff to member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to assign staff to member: $e');
    }
  }

  /// Gets all staff assigned to a member.
  Future<List<MemberStaff>> getMemberStaff(String memberId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/members/$memberId/staff'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MemberStaff.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get member staff: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get member staff: $e');
    }
  }

  /// Gets the schedule for a staff member.
  Future<Schedule> getStaffSchedule(String staffId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/staff/$staffId/schedule'),
      );

      if (response.statusCode == 200) {
        return Schedule.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get staff schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get staff schedule: $e');
    }
  }

  /// Updates the schedule for a staff member.
  Future<Schedule> updateStaffSchedule(String staffId, Schedule schedule) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/staff/$staffId/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(schedule.toJson()),
      );

      if (response.statusCode == 200) {
        return Schedule.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update staff schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update staff schedule: $e');
    }
  }

  /// Adds a time slot to a staff member's schedule.
  Future<bool> addTimeSlotToSchedule(String staffId, TimeSlot timeSlot) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/staff/$staffId/schedule/slots'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(timeSlot.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to add time slot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add time slot: $e');
    }
  }

  /// Removes a time slot from a staff member's schedule.
  Future<bool> removeTimeSlotFromSchedule(String staffId, TimeSlot timeSlot) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/staff/$staffId/schedule/slots'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(timeSlot.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to remove time slot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove time slot: $e');
    }
  }

  /// Updates a time slot in a staff member's schedule.
  Future<bool> updateTimeSlotInSchedule(String staffId, TimeSlot oldSlot, TimeSlot newSlot) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/staff/$staffId/schedule/slots'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'old_slot': oldSlot.toJson(),
          'new_slot': newSlot.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update time slot: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update time slot: $e');
    }
  }

  /// Checks if a staff member exists with the given mobile number.
  Future<Map<String, dynamic>> checkStaffMobile(String mobile) async {
    try {
      final data = await _httpHelper.get('$baseUrl/staff/check?mobile=$mobile');
      return data;
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to check staff mobile: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to check staff mobile: $e');
    }
  }

  /// Sends an OTP to the given mobile number.
  Future<bool> sendOtp(String mobile) async {
    try {
      final data = await _httpHelper.post(
        '$baseUrl/staff/send-otp',
        body: {'mobile': mobile},
      );
      return data['success'] ?? false;
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to send OTP: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to send OTP: $e');
    }
  }

  /// Verifies an OTP for the given mobile number.
  Future<bool> verifyOtp(String mobile, String otp) async {
    try {
      final data = await _httpHelper.post(
        '$baseUrl/staff/verify-otp',
        body: {
          'mobile': mobile,
          'otp': otp,
        },
      );
      return data['success'] ?? false;
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to verify OTP: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to verify OTP: $e');
    }
  }

  /// Verifies a staff member's identity.
  Future<bool> verifyStaffIdentity(int staffId, Map<String, dynamic> data) async {
    try {
      // Get the current member ID from the auth service
      final memberId = await _authService.getMemberId();

      // Add the verified_by_member_id to the data if not already present
      if (memberId != null && !data.containsKey('verified_by_member_id')) {
        data['verified_by_member_id'] = memberId;
      }

      final response = await _httpHelper.put(
        '$baseUrl/staff/$staffId/verify',
        body: data,
      );
      return response['success'] ?? false;
    } on ApiException catch (e) {
      throw ApiException(
        message: 'Failed to verify staff identity: ${e.message}',
        statusCode: e.statusCode,
        endpoint: e.endpoint,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to verify staff identity: $e');
    }
  }
}
