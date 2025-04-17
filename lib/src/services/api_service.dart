import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/member.dart';
import '../models/staff.dart';

/// Service class for handling API communication.
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Fetches all members from the API.
  Future<List<Member>> getMembers() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/members'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Member.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load members: $e');
    }
  }

  /// Fetches all staff from the API.
  Future<List<Staff>> getStaff() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/staff'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Staff.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load staff: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load staff: $e');
    }
  }

  /// Creates a new member.
  Future<Member> createMember(Member member) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/members'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(member.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Member.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create member: $e');
    }
  }

  /// Creates a new staff member.
  Future<Staff> createStaff(Staff staff) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/staff'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(staff.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Staff.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create staff: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create staff: $e');
    }
  }
}
