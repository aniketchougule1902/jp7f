class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? messageText;
  final bool isRead;
  final DateTime? createdAt;

  // Optional display fields (not stored in messages table)
  final String? senderName;
  final String? receiverName;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.messageText,
    this.isRead = false,
    this.createdAt,
    this.senderName,
    this.receiverName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      messageText: json['message_text'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      senderName: json['sender_name'] as String?,
      receiverName: json['receiver_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_text': messageText,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? messageText,
    bool? isRead,
    DateTime? createdAt,
    String? senderName,
    String? receiverName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageText: messageText ?? this.messageText,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
    );
  }
}
