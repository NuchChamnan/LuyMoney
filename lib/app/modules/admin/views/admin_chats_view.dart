import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chat_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/admin_controller.dart';

class AdminChatsView extends GetView<AdminController> {
  const AdminChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final isWide = MediaQuery.of(context).size.width > 600;

    return isWide
        ? _WideChatsLayout(ext: ext)
        : _NarrowChatsLayout(ext: ext);
  }
}

// ── Wide layout: chat list + conversation side by side ────────────────────────
class _WideChatsLayout extends GetView<AdminController> {
  final AppColorExtension ext;
  const _WideChatsLayout({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: _ChatListPanel(ext: ext),
        ),
        VerticalDivider(width: 1, color: ext.border),
        Expanded(
          child: Obx(() => controller.selectedChatUserId.value.isEmpty
              ? _EmptyConversation(ext: ext)
              : _ConversationPanel(ext: ext)),
        ),
      ],
    );
  }
}

// ── Narrow layout: list → tap → conversation ─────────────────────────────────
class _NarrowChatsLayout extends GetView<AdminController> {
  final AppColorExtension ext;
  const _NarrowChatsLayout({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedChatUserId.value.isEmpty
        ? _ChatListPanel(ext: ext)
        : _ConversationPanel(ext: ext, showBackButton: true));
  }
}

// ── Chat List ─────────────────────────────────────────────────────────────────
class _ChatListPanel extends GetView<AdminController> {
  final AppColorExtension ext;
  const _ChatListPanel({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: ext.surface,
          child: Row(
            children: [
              Icon(Icons.support_agent, color: ext.primary),
              const SizedBox(width: 8),
              Text('admin_customer_chats'.tr,
                  style: TextStyle(
                      color: ext.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const Spacer(),
              Obx(() => controller.isLoadingChats.value
                  ? SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: ext.primary))
                  : IconButton(
                      icon: Icon(Icons.refresh, color: ext.textSecondary, size: 20),
                      onPressed: controller.fetchAdminChats)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingChats.value && controller.adminChats.isEmpty) {
              return Center(child: CircularProgressIndicator(color: ext.primary));
            }
            if (controller.adminChats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 48, color: ext.textSecondary),
                    const SizedBox(height: 12),
                    Text('admin_no_customer_messages'.tr,
                        style: TextStyle(color: ext.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: controller.adminChats.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: ext.border),
              itemBuilder: (_, i) {
                final chat = controller.adminChats[i];
                final userId = chat['userId'] as String? ?? '';
                final userName = chat['userName'] as String? ?? 'Unknown';
                final lastMsg = chat['lastMessage'] as String? ?? '';
                final unread = (chat['unreadByAdmin'] as int?) ?? 0;
                final lastAt = chat['lastMessageAt'] as Timestamp?;
                final timeStr = lastAt != null
                    ? DateFormat('HH:mm').format(lastAt.toDate())
                    : '';

                return Obx(() {
                  final isSelected = controller.selectedChatUserId.value == userId;
                  return InkWell(
                    onTap: () => controller.selectChat(userId, userName),
                    child: Container(
                      color: isSelected
                          ? ext.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: ext.primary.withValues(alpha: 0.2),
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                  color: ext.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName,
                                    style: TextStyle(
                                        color: ext.textPrimary,
                                        fontWeight: unread > 0
                                            ? FontWeight.w700
                                            : FontWeight.normal)),
                                const SizedBox(height: 2),
                                Text(lastMsg,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: ext.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(timeStr,
                                  style: TextStyle(
                                      color: ext.textSecondary, fontSize: 11)),
                              if (unread > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('$unread',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }
}

// ── Conversation Panel ────────────────────────────────────────────────────────
class _ConversationPanel extends GetView<AdminController> {
  final AppColorExtension ext;
  final bool showBackButton;
  const _ConversationPanel({required this.ext, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.only(
            top: showBackButton ? MediaQuery.of(context).padding.top + 8 : 12,
            bottom: 12,
            left: showBackButton ? 4 : 16,
            right: 16,
          ),
          color: ext.surface,
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: Icon(Icons.arrow_back, color: ext.textPrimary),
                  onPressed: () => controller.selectedChatUserId.value = '',
                ),
              CircleAvatar(
                radius: 18,
                backgroundColor: ext.primary.withValues(alpha: 0.2),
                child: Obx(() => Text(
                      controller.selectedChatUserName.value.isNotEmpty
                          ? controller.selectedChatUserName.value[0]
                              .toUpperCase()
                          : 'U',
                      style: TextStyle(
                          color: ext.primary, fontWeight: FontWeight.w700),
                    )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => Text(
                      controller.selectedChatUserName.value,
                      style: TextStyle(
                          color: ext.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    )),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: ext.border),

        // Messages
        Expanded(
          child: Obx(() {
            final msgs = controller.selectedChatMessages;
            if (msgs.isEmpty) {
              return Center(
                  child: Text('admin_no_messages'.tr,
                      style: TextStyle(color: ext.textSecondary)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: msgs.length,
              itemBuilder: (_, i) => _AdminMessageBubble(
                message: msgs[i],
                ext: ext,
              ),
            );
          }),
        ),

        // Reply input
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
          decoration: BoxDecoration(
            color: ext.surface,
            border: Border(top: BorderSide(color: ext.border)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Image picker button
                Obx(() => IconButton(
                      onPressed: controller.isSendingImage.value
                          ? null
                          : controller.sendAdminImage,
                      icon: controller.isSendingImage.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: ext.primary))
                          : Icon(Icons.image_outlined, color: ext.primary),
                      tooltip: 'admin_send_image'.tr,
                    )),
                Expanded(
                  child: TextField(
                    controller: controller.adminReplyController,
                    style: TextStyle(color: ext.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'admin_type_reply'.tr,
                      hintStyle: TextStyle(color: ext.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: ext.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    maxLines: null,
                    onSubmitted: (_) => controller.sendAdminReply(),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => GestureDetector(
                      onTap: controller.isSendingReply.value
                          ? null
                          : controller.sendAdminReply,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: controller.isSendingReply.value
                              ? null
                              : AppColors.goldGradient,
                          color: controller.isSendingReply.value
                              ? ext.border
                              : null,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isSendingReply.value
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ext.textSecondary))
                            : const Icon(Icons.send_rounded,
                                color: Colors.black, size: 20),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyConversation extends StatelessWidget {
  final AppColorExtension ext;
  const _EmptyConversation({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: ext.textSecondary),
          const SizedBox(height: 16),
          Text('admin_select_conversation'.tr,
              style: TextStyle(color: ext.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────
class _AdminMessageBubble extends StatelessWidget {
  final ChatModel message;
  final AppColorExtension ext;
  const _AdminMessageBubble({required this.message, required this.ext});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isFromAdmin;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: ext.primary.withValues(alpha: 0.2),
              child:
                  Text('U', style: TextStyle(color: ext.primary, fontSize: 11)),
            ),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65),
            child: Column(
              crossAxisAlignment: isAdmin
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image &&
                    message.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                      bottomRight: Radius.circular(isAdmin ? 4 : 16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: message.imageUrl!,
                      width: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        width: 200,
                        height: 120,
                        color: ext.surface,
                        child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: ext.primary)),
                      ),
                      errorWidget: (_, _, _) => Container(
                        width: 200,
                        height: 120,
                        color: ext.surface,
                        child: Icon(Icons.broken_image_outlined,
                            color: ext.textSecondary),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isAdmin ? AppColors.goldGradient : null,
                      color: isAdmin ? null : ext.card,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                        bottomRight: Radius.circular(isAdmin ? 4 : 16),
                      ),
                      border: isAdmin ? null : Border.all(color: ext.border),
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(
                        color: isAdmin ? Colors.black : ext.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                      color: ext.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: const Text('A',
                  style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }
}
