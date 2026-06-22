import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/comment_model.dart';
import '../../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../themes/app_themes.dart';

/// Shared comment composer used by both the video and article detail pages.
class CommentInputBar extends StatelessWidget {
  final AppColorExtension ext;
  final TextEditingController controller;
  final RxBool isSending;
  final VoidCallback onSend;

  const CommentInputBar({
    super.key,
    required this.ext,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthService>().currentUser.value;
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
            backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              style: TextStyle(color: ext.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'add_comment_hint'.tr,
                hintStyle: TextStyle(color: ext.textSecondary, fontSize: 14),
                filled: true,
                fillColor: ext.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: ext.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: ext.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => isSending.value
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.gold),
                  ),
                )
              : GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.black, size: 18),
                  ),
                )),
        ],
      ),
    );
  }
}

/// Shared comment row used by both the video and article detail pages.
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final AppColorExtension ext;
  final bool canDelete;
  final VoidCallback onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    required this.ext,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        comment.userAvatarUrl != null && comment.userAvatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold.withValues(alpha: 0.2),
            backgroundImage:
                hasAvatar ? NetworkImage(comment.userAvatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    comment.userName.isNotEmpty
                        ? comment.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      comment.userName,
                      style: TextStyle(
                        color: ext.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatRelativeTime(comment.createdAt),
                    style: TextStyle(color: ext.textSecondary, fontSize: 11),
                  ),
                  if (canDelete) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline_rounded,
                          size: 16, color: ext.textSecondary),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                      color: ext.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatRelativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just_now'.tr;
  if (diff.inMinutes < 60) {
    return 'minutes_ago'.trParams({'count': '${diff.inMinutes}'});
  }
  if (diff.inHours < 24) {
    return 'hours_ago'.trParams({'count': '${diff.inHours}'});
  }
  if (diff.inDays < 7) {
    return 'days_ago'.trParams({'count': '${diff.inDays}'});
  }
  return '${dt.month}/${dt.day}/${dt.year}';
}
