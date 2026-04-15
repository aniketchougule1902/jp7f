import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/message_model.dart';

class MessageService {
  final _client = SupabaseConfig.client;

  /// Sends a message from [senderId] to [receiverId].
  Future<({MessageModel? message, String? error})> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final data = {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message_text': text,
      };
      final response =
          await _client.from('messages').insert(data).select().single();
      return (message: MessageModel.fromJson(response), error: null);
    } catch (e) {
      return (message: null, error: e.toString());
    }
  }

  /// Returns the full conversation between two users, oldest first.
  Future<({List<MessageModel> messages, String? error})> getConversation(
    String userId1,
    String userId2,
  ) async {
    try {
      final data = await _client
          .from('messages')
          .select()
          .or('and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)')
          .order('created_at');
      final messages =
          (data as List).map((e) => MessageModel.fromJson(e)).toList();
      return (messages: messages, error: null);
    } catch (e) {
      return (messages: <MessageModel>[], error: e.toString());
    }
  }

  /// Returns a list of conversation partners with their last message.
  Future<({List<Map<String, dynamic>> conversations, String? error})>
      getConversationsList(String userId) async {
    try {
      // Fetch all messages involving this user, newest first.
      final data = await _client
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final seen = <String>{};
      final conversations = <Map<String, dynamic>>[];

      for (final row in data as List) {
        final senderId = row['sender_id'] as String;
        final receiverId = row['receiver_id'] as String;
        final partnerId = senderId == userId ? receiverId : senderId;

        if (seen.contains(partnerId)) continue;
        seen.add(partnerId);

        conversations.add({
          'partner_id': partnerId,
          'last_message': MessageModel.fromJson(row),
        });
      }

      return (conversations: conversations, error: null);
    } catch (e) {
      return (conversations: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  /// Marks a single message as read.
  Future<String?> markAsRead(String messageId) async {
    try {
      await _client
          .from('messages')
          .update({'is_read': true}).eq('id', messageId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns the count of unread messages for a user.
  Future<({int count, String? error})> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from('messages')
          .select('id')
          .eq('receiver_id', userId)
          .eq('is_read', false);
      return (count: (data as List).length, error: null);
    } catch (e) {
      return (count: 0, error: e.toString());
    }
  }
}
