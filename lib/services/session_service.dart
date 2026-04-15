import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/session_model.dart';

class SessionService {
  final _client = SupabaseConfig.client;

  /// Creates a new session record.
  Future<({SessionModel? session, String? error})> createSession({
    required String userId,
    String? deviceName,
    String? deviceType,
    String? ipAddress,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'device_name': deviceName,
        'device_type': deviceType,
        'ip_address': ipAddress,
        'is_active': true,
        'last_active_at': DateTime.now().toIso8601String(),
      };
      final response = await _client
          .from('user_sessions')
          .insert(data)
          .select()
          .single();
      return (session: SessionModel.fromJson(response), error: null);
    } catch (e) {
      return (session: null, error: e.toString());
    }
  }

  /// Returns all active sessions for a user.
  Future<({List<SessionModel> sessions, String? error})> getActiveSessions(
      String userId) async {
    try {
      final data = await _client
          .from('user_sessions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('last_active_at', ascending: false);
      final sessions =
          (data as List).map((e) => SessionModel.fromJson(e)).toList();
      return (sessions: sessions, error: null);
    } catch (e) {
      return (sessions: <SessionModel>[], error: e.toString());
    }
  }

  /// Terminates a single session.
  Future<String?> terminateSession(String sessionId) async {
    try {
      await _client
          .from('user_sessions')
          .update({'is_active': false}).eq('id', sessionId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Terminates all sessions for a user except [exceptCurrentId].
  Future<String?> terminateAllSessions(
    String userId, {
    String? exceptCurrentId,
  }) async {
    try {
      var query = _client
          .from('user_sessions')
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('is_active', true);

      if (exceptCurrentId != null) {
        query = query.neq('id', exceptCurrentId);
      }

      await query;
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
