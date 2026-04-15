import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jeevanpatra/providers/auth_provider.dart';
import 'package:jeevanpatra/services/message_service.dart';

// ── Service singleton ──────────────────────────────────────────────────
final messageServiceProvider =
    Provider<MessageService>((_) => MessageService());

// ── Conversations list ─────────────────────────────────────────────────
final conversationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return [];
  final result = await ref
      .read(messageServiceProvider)
      .getConversationsList(user.id);
  return result.conversations;
});

// ── Unread message count ───────────────────────────────────────────────
final unreadCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(authNotifierProvider);
  if (user == null) return 0;
  final result =
      await ref.read(messageServiceProvider).getUnreadCount(user.id);
  return result.count;
});
