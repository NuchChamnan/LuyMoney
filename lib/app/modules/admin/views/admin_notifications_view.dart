import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../shared/widgets/gold_button.dart';
import '../controllers/admin_controller.dart';

class AdminNotificationsView extends GetView<AdminController> {
  const AdminNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Push Notification',
              style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // Target selector
          Text('Target Audience',
              style: TextStyle(color: ext.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          Obx(() => Row(
                children: [
                  {'label': 'All Users', 'value': 'all'},
                  {'label': 'Active', 'value': 'active'},
                  {'label': 'Expiring', 'value': 'expiring'},
                ].map((opt) {
                  final isSelected =
                      controller.notifTarget.value == opt['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          controller.notifTarget.value = opt['value']!,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ext.primary.withValues(alpha: 0.2)
                              : ext.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? ext.primary : ext.border,
                          ),
                        ),
                        child: Text(
                          opt['label']!,
                          style: TextStyle(
                            color: isSelected ? ext.primary : ext.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: 20),

          // Title
          _Field(
            label: 'Notification Title',
            controller: titleCtrl,
            hint: 'e.g. Special Offer!',
            ext: ext,
            onChanged: (v) => controller.notifTitle.value = v,
          ),
          const SizedBox(height: 14),

          // Body
          _Field(
            label: 'Message Body',
            controller: bodyCtrl,
            hint: 'Write your message here...',
            ext: ext,
            maxLines: 4,
            onChanged: (v) => controller.notifBody.value = v,
          ),
          const SizedBox(height: 24),

          Obx(() => GoldButton(
                label: 'Send Notification',
                icon: Icons.send,
                isLoading: controller.isLoading.value,
                onPressed: () {
                  controller.notifTitle.value = titleCtrl.text;
                  controller.notifBody.value = bodyCtrl.text;
                  controller.sendPushNotification();
                },
              )),

          const SizedBox(height: 32),

          // Quick templates
          Text('Quick Templates',
              style: TextStyle(
                  color: ext.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          ..._templates.map((t) => _TemplateTile(
                title: t['title']!,
                body: t['body']!,
                ext: ext,
                onTap: () {
                  titleCtrl.text = t['title']!;
                  bodyCtrl.text = t['body']!;
                  controller.notifTitle.value = t['title']!;
                  controller.notifBody.value = t['body']!;
                },
              )),
        ],
      ),
    );
  }

  static const _templates = [
    {
      'title': '⏰ Subscription Expiring Soon',
      'body':
          'Your Luy Money subscription expires in 7 days. Renew now to keep learning!',
    },
    {
      'title': '🔒 Subscription Expired',
      'body':
          'Your subscription has expired. Renew today to regain access to premium content.',
    },
    {
      'title': '🎉 New Content Available',
      'body':
          'Fresh financial insights just dropped! Check out the latest videos and articles.',
    },
    {
      'title': '🎁 Special Offer',
      'body': 'Limited time: Get 20% off any subscription plan. Offer ends soon!',
    },
  ];
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final AppColorExtension ext;
  final int maxLines;
  final void Function(String)? onChanged;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.ext,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: ext.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: ext.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: ext.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: ext.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ext.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ext.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ext.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final String title;
  final String body;
  final AppColorExtension ext;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.title,
    required this.body,
    required this.ext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ext.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ext.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: ext.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: ext.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: ext.textSecondary),
          ],
        ),
      ),
    );
  }
}
