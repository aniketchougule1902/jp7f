import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/user_model.dart';

class UserService {
  final _client = SupabaseConfig.client;

  /// Fetches a user profile by auth [userId] (UUID).
  Future<({UserModel? user, String? error})> getUserProfile(
      String userId) async {
    try {
      final data =
          await _client.from('users').select().eq('id', userId).single();
      return (user: UserModel.fromJson(data), error: null);
    } catch (e) {
      return (user: null, error: e.toString());
    }
  }

  /// Updates the user row identified by auth [userId].
  Future<({UserModel? user, String? error})> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .from('users')
          .update(data)
          .eq('id', userId)
          .select()
          .single();
      return (user: UserModel.fromJson(response), error: null);
    } catch (e) {
      return (user: null, error: e.toString());
    }
  }

  /// Looks up a user by their JP-format user ID (e.g. JP12345678).
  Future<({UserModel? user, String? error})> getUserByUserId(
      String jpId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('user_id', jpId)
          .maybeSingle();
      if (data == null) {
        return (user: null, error: 'User not found.');
      }
      return (user: UserModel.fromJson(data), error: null);
    } catch (e) {
      return (user: null, error: e.toString());
    }
  }

  /// Searches users by name, email, mobile, or JP userId.
  Future<({List<UserModel> users, String? error})> searchUsers(
      String query) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%,mobile_number.ilike.%$query%,user_id.ilike.%$query%');
      final users =
          (data as List).map((e) => UserModel.fromJson(e)).toList();
      return (users: users, error: null);
    } catch (e) {
      return (users: <UserModel>[], error: e.toString());
    }
  }

  /// Returns all users, optionally filtered by [userType].
  Future<({List<UserModel> users, String? error})> getAllUsers({
    UserType? userType,
  }) async {
    try {
      var query = _client.from('users').select();
      if (userType != null) {
        query = query.eq('user_type', userType.name);
      }
      final data = await query;
      final users =
          (data as List).map((e) => UserModel.fromJson(e)).toList();
      return (users: users, error: null);
    } catch (e) {
      return (users: <UserModel>[], error: e.toString());
    }
  }

  /// Uploads an avatar image and updates the user's avatar_url.
  Future<({String? avatarUrl, String? error})> uploadAvatar(
    String userId,
    XFile file,
  ) async {
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last;
      final path = 'avatars/$userId.$ext';

      await _client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _client.storage.from('avatars').getPublicUrl(path);

      await _client
          .from('users')
          .update({'avatar_url': url}).eq('id', userId);

      return (avatarUrl: url, error: null);
    } catch (e) {
      return (avatarUrl: null, error: e.toString());
    }
  }
}
