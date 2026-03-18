import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  /// Get or create a chat room between two users
  static Future<String> getOrCreateChatRoom(String otherUserId) async {
    final currentUserId = AuthService.currentUserId!;
    final participants = [currentUserId, otherUserId]..sort();
    final roomId = '${participants[0]}_${participants[1]}';

    final doc = await _firestore.collection('chatRooms').doc(roomId).get();

    if (!doc.exists) {
      final chatRoom = ChatRoomModel(
        id: roomId,
        participants: participants,
        unreadCount: {currentUserId: 0, otherUserId: 0},
      );
      await _firestore
          .collection('chatRooms')
          .doc(roomId)
          .set(chatRoom.toMap());
    }

    return roomId;
  }

  /// Send a text message
  static Future<void> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final messageId = _uuid.v4();
    final message = MessageModel(
      id: messageId,
      senderId: AuthService.currentUserId!,
      receiverId: receiverId,
      content: content,
      type: type,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
    );

    final batch = _firestore.batch();

    // Add message to subcollection
    batch.set(
      _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId),
      message.toMap(),
    );

    // Update chat room with last message info
    batch.update(
      _firestore.collection('chatRooms').doc(chatRoomId),
      {
        'lastMessage':
            type == MessageType.image ? '📷 Photo' : content,
        'lastMessageSenderId': AuthService.currentUserId,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'unreadCount.$receiverId': FieldValue.increment(1),
      },
    );

    await batch.commit();
  }

  /// Stream of messages in a chat room
  static Stream<List<MessageModel>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream of chat rooms for the current user
  static Stream<List<ChatRoomModel>> getChatRooms() {
    final currentUserId = AuthService.currentUserId!;
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead(String chatRoomId) async {
    final currentUserId = AuthService.currentUserId!;

    // Reset unread count
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'unreadCount.$currentUserId': 0,
    });

    // Mark individual unread messages as read
    final unreadMessages = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isNotEqualTo: MessageStatus.read.name)
        .get();

    final batch = _firestore.batch();
    final now = Timestamp.fromDate(DateTime.now());

    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'status': MessageStatus.read.name,
        'readAt': now,
      });
    }

    await batch.commit();
  }

  /// Search users by name or email
  static Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final currentUserId = AuthService.currentUserId!;
    final lowercaseQuery = query.toLowerCase();

    final snapshot = await _firestore.collection('users').get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) =>
            user.uid != currentUserId &&
            (user.name.toLowerCase().contains(lowercaseQuery) ||
                user.email.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  /// Delete a message
  static Future<void> deleteMessage(
      String chatRoomId, String messageId) async {
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
