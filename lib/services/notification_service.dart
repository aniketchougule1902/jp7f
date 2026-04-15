import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/notification_model.dart';

class NotificationService {
  final _client = SupabaseConfig.client;

  /// Returns all notifications for a user, newest first.
  Future<({List<NotificationModel> notifications, String? error})>
      getNotifications(String userId) async {
    try {
      final data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final notifications = (data as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      return (notifications: notifications, error: null);
    } catch (e) {
      return (notifications: <NotificationModel>[], error: e.toString());
    }
  }

  /// Marks a single notification as read.
  Future<String?> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Marks all notifications as read for a user.
  Future<String?> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns the count of unread notifications.
  Future<({int count, String? error})> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      return (count: (data as List).length, error: null);
    } catch (e) {
      return (count: 0, error: e.toString());
    }
  }

  /// Creates a new notification.
  Future<({NotificationModel? notification, String? error})>
      createNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
      };
      final response = await _client
          .from('notifications')
          .insert(payload)
          .select()
          .single();
      return (
        notification: NotificationModel.fromJson(response),
        error: null,
      );
    } catch (e) {
      return (notification: null, error: e.toString());
    }
  }
}
