class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final SenderInfo sender;
  final String recipientId;
  final RecipientInfo recipient;
  final String? orderId;
  final String content;
  final String messageType; // 'text', 'image', 'document', etc.
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    required this.recipientId,
    required this.recipient,
    this.orderId,
    required this.content,
    required this.messageType,
    this.attachments,
    this.metadata,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      sender: SenderInfo.fromJson(json['sender'] as Map<String, dynamic>),
      recipientId: json['recipientId'] as String,
      recipient:
          RecipientInfo.fromJson(json['recipient'] as Map<String, dynamic>),
      orderId: json['orderId'] as String?,
      content: json['content'] as String,
      messageType: json['messageType'] as String? ?? 'text',
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'sender': sender.toJson(),
      'recipientId': recipientId,
      'recipient': recipient.toJson(),
      'orderId': orderId,
      'content': content,
      'messageType': messageType,
      'attachments': attachments,
      'metadata': metadata,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    SenderInfo? sender,
    String? recipientId,
    RecipientInfo? recipient,
    String? orderId,
    String? content,
    String? messageType,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      recipientId: recipientId ?? this.recipientId,
      recipient: recipient ?? this.recipient,
      orderId: orderId ?? this.orderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'MessageModel(id: $id, from: ${sender.name}, isRead: $isRead)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SenderInfo {
  final String id;
  final String name;
  final String? avatar;

  SenderInfo({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class RecipientInfo {
  final String id;
  final String name;
  final String? avatar;

  RecipientInfo({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory RecipientInfo.fromJson(Map<String, dynamic> json) {
    return RecipientInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class ConversationModel {
  final String conversationId;
  final String otherUserId;
  final UserInfo otherUser;
  final MessageModel lastMessage;
  final int unreadCount;
  final DateTime lastMessageAt;

  ConversationModel({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
    required this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversationId'] as String,
      otherUserId: json['otherUserId'] as String,
      otherUser: UserInfo.fromJson(json['otherUser'] as Map<String, dynamic>),
      lastMessage:
          MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'otherUserId': otherUserId,
      'otherUser': otherUser.toJson(),
      'lastMessage': lastMessage.toJson(),
      'unreadCount': unreadCount,
      'lastMessageAt': lastMessageAt.toIso8601String(),
    };
  }
}

class UserInfo {
  final String id;
  final String name;
  final String? avatar;
  final bool? isOnline;

  UserInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.isOnline,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      isOnline: json['isOnline'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
    };
  }
}
