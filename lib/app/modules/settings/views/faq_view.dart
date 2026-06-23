import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/themes/app_themes.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const _count = 8;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        title: Text('faq'.tr),
        backgroundColor: ext.surface,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _count,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = i + 1;
          return _FaqTile(
            question: 'faq_q$n'.tr,
            answer: 'faq_a$n'.tr,
            ext: ext,
          );
        },
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final AppColorExtension ext;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.gold,
          collapsedIconColor: ext.textSecondary,
          title: Text(
            question,
            style: TextStyle(
              color: ext.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: TextStyle(color: ext.textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
