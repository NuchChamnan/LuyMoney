import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/chat_model.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/utils/responsive_layout.dart';
import '../controllers/support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('chat_support'.tr),
          bottom: TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            tabs: [
              Tab(text: 'chat_support'.tr),
              Tab(text: 'telegram'.tr),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _InAppChatView(),
            _TelegramView(),
          ],
        ),
      ),
    );
  }
}

class _InAppChatView extends GetView<SupportController> {
  const _InAppChatView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: context.rPadding(h: 32, v: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: context.rSize(64), color: AppColors.gold),
                      SizedBox(height: context.rSize(16)),
                      Text('Start a conversation',
                          style: theme.textTheme.titleMedium),
                      SizedBox(height: context.rSize(8)),
                      Text(
                        'Our team typically replies within 24 hours',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(context.rSize(16)),
              reverse: true,
              itemCount: controller.messages.length,
              itemBuilder: (_, i) =>
                  _MessageBubble(message: controller.messages[i]),
            );
          }),
        ),
        // Input bar
        Container(
          padding: EdgeInsets.fromLTRB(
            context.rSize(12),
            context.rSize(8),
            context.rSize(12),
            context.rSize(12),
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: controller.sendImage,
                  icon: Icon(Icons.image_outlined, size: context.rSize(22)),
                  color: AppColors.gold,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: context.rSize(40),
                    minHeight: context.rSize(40),
                  ),
                ),
                SizedBox(width: context.rSize(4)),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'type_message'.tr,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(context.rSize(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.rSize(14),
                        vertical: context.rSize(10),
                      ),
                      isDense: true,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                SizedBox(width: context.rSize(8)),
                Obx(() => GestureDetector(
                      onTap: controller.sendMessage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: context.rSize(44),
                        height: context.rSize(44),
                        decoration: const BoxDecoration(
                          gradient: AppColors.goldGradient,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isSending.value
                            ? Padding(
                                padding:
                                    EdgeInsets.all(context.rSize(10)),
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black),
                              )
                            : Icon(Icons.send_rounded,
                                color: Colors.black,
                                size: context.rSize(20)),
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

class _MessageBubble extends StatelessWidget {
  final ChatModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = !message.isFromAdmin;
    final maxBubbleWidth = context.screenWidth * 0.72;

    return Padding(
      padding: EdgeInsets.only(bottom: context.rSize(12)),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: context.rSize(16),
              backgroundColor: AppColors.gold,
              child: Text(
                'LM',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: context.rFont(10),
                ),
              ),
            ),
            SizedBox(width: context.rSize(8)),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSize(14),
                    vertical: context.rSize(10),
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppColors.goldGradient : null,
                    color: isUser ? null : theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: theme.dividerColor),
                  ),
                  child: message.type == MessageType.image &&
                          message.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: message.imageUrl!,
                            width: context.screenWidth * 0.5,
                            height: context.screenWidth * 0.375,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          message.message,
                          style: TextStyle(
                            color: isUser
                                ? Colors.black
                                : theme.colorScheme.onSurface,
                            fontSize: context.rFont(14),
                          ),
                        ),
                ),
                SizedBox(height: context.rSize(4)),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: context.rFont(11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TelegramView extends GetView<SupportController> {
  const _TelegramView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.rSize(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.rSize(100),
              height: context.rSize(100),
              decoration: BoxDecoration(
                color: const Color(0xFF26A5E4).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.telegram,
                  size: context.rSize(56),
                  color: const Color(0xFF26A5E4)),
            ),
            SizedBox(height: context.rSize(24)),
            Text(
              'Join Our Telegram',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: context.rSize(8)),
            Text(
              'Get real-time support, share insights, and connect with our financial community.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: context.rSize(32)),
            ElevatedButton.icon(
              onPressed: controller.openTelegram,
              icon: const Icon(Icons.telegram, color: Colors.black),
              label: Text(
                'join_telegram'.tr,
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A5E4),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSize(24),
                  vertical: context.rSize(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
