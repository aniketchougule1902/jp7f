import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jeevanpatra/models/notification_model.dart';
import 'package:jeevanpatra/providers/auth_provider.dart';
import 'package:jeevanpatra/services/notification_service.dart';

// Re-export service provider if not already available
final _notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService());

// ── Notifications list ─────────────────────────────────────────────────
final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(_notificationServiceProvider)
      .getNotifications(user.id);
  return result.notifications;
});

// ── Unread notification count ──────────────────────────────────────────
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return 0;
  final result = await ref
      .read(_notificationServiceProvider)
      .getUnreadCount(user.id);
  return result.count;
});
