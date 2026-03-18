import 'package:flutter/material.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class ChatRoomTile extends StatelessWidget {
  final ChatRoomModel chatRoom;
  final String otherUserId;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatRoomTile({
    super.key,
    required this.chatRoom,
    required this.otherUserId,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: AuthService.getUserStream(otherUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'Loading...';
        final isOnline = user?.isOnline ?? false;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: onTap,
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(
                        Helpers.getInitials(name),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.onlineColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: chatRoom.lastMessage != null
              ? Text(
                  chatRoom.lastMessageSenderId == AuthService.currentUserId
                      ? 'You: ${chatRoom.lastMessage}'
                      : chatRoom.lastMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    color: unreadCount > 0
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontWeight: unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (chatRoom.lastMessageTime != null)
                Text(
                  Helpers.formatTimeAgo(chatRoom.lastMessageTime!),
                  style: TextStyle(
                    fontSize: 11,
                    color: unreadCount > 0
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
              const SizedBox(height: 4),
              if (unreadCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
