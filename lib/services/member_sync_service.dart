import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

class MemberSyncService {
  final SupabaseClient _supabaseClient;
  final Dio _dio;
  final String _laravelApiUrl;

  MemberSyncService({
    required SupabaseClient supabaseClient,
    required String laravelApiUrl,
  }) : _supabaseClient = supabaseClient,
       _dio = Dio(),
       _laravelApiUrl = laravelApiUrl;

  Future<void> syncMembers() async {
    try {
      // Fetch members from Laravel MySQL
      final response = await _dio.get('$_laravelApiUrl/api/members');
      final List<dynamic> members = response.data['data'];

      // Prepare batch upsert data
      final List<Map<String, dynamic>> upsertData = members.map((member) => {
        'id': member['id'],
        'name': member['name'],
        'email': member['email'],
        'phone': member['phone'],
        'unit_number': member['unit_number'],
        'building_name': member['building_name'],
        'status': member['status'],
        'last_synced_at': DateTime.now().toIso8601String(),
      }).toList();

      // Upsert members to Supabase
      await _supabaseClient
          .from('members')
          .upsert(upsertData, onConflict: 'id');

    } catch (e) {
      throw Exception('Failed to sync members: $e');
    }
  }

  Future<void> syncMemberUpdates() async {
    try {
      final lastSyncTimestamp = await _getLastSyncTimestamp();
      
      // Fetch only updated members since last sync
      final response = await _dio.get(
        '$_laravelApiUrl/api/members/updates',
        queryParameters: {'since': lastSyncTimestamp},
      );

      final List<dynamic> updatedMembers = response.data['data'];
      
      if (updatedMembers.isEmpty) return;

      // Update members in Supabase
      await _supabaseClient
          .from('members')
          .upsert(
            updatedMembers.map((m) => {
              'id': m['id'],
              'name': m['name'],
              'email': m['email'],
              'phone': m['phone'],
              'unit_number': m['unit_number'],
              'building_name': m['building_name'],
              'status': m['status'],
              'last_synced_at': DateTime.now().toIso8601String(),
            }).toList(),
            onConflict: 'id'
          );

      await _updateLastSyncTimestamp();
    } catch (e) {
      throw Exception('Failed to sync member updates: $e');
    }
  }

  Future<String?> _getLastSyncTimestamp() async {
    final result = await _supabaseClient
        .from('sync_metadata')
        .select('last_sync_timestamp')
        .single();
    
    return result['last_sync_timestamp'];
  }

  Future<void> _updateLastSyncTimestamp() async {
    await _supabaseClient
        .from('sync_metadata')
        .upsert({
          'id': 'member_sync',
          'last_sync_timestamp': DateTime.now().toIso8601String(),
        });
  }
}