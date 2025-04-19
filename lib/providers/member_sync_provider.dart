import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/member_sync_service.dart';

class MemberSyncProvider extends ChangeNotifier {
  final MemberSyncService _syncService;
  bool _isSyncing = false;
  String? _lastError;

  MemberSyncProvider({
    required SupabaseClient supabaseClient,
    required String laravelApiUrl,
  }) : _syncService = MemberSyncService(
         supabaseClient: supabaseClient,
         laravelApiUrl: laravelApiUrl,
       );

  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;

  Future<void> performInitialSync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      _lastError = null;
      notifyListeners();

      await _syncService.syncMembers();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncUpdates() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      _lastError = null;
      notifyListeners();

      await _syncService.syncMemberUpdates();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void startPeriodicSync() {
    // Sync updates every 5 minutes
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 5));
      if (_isSyncing) return true;
      
      await syncUpdates();
      return true; // Continue the periodic sync
    });
  }
}