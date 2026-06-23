import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/themes/app_themes.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  static const _count = 11;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        title: Text('terms_of_service'.tr),
        backgroundColor: ext.surface,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _count,
        itemBuilder: (_, i) {
          final n = i + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$n. ${'terms_s${n}_title'.tr}',
                  style: TextStyle(
                    color: ext.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'terms_s${n}_body'.tr,
                  style: TextStyle(color: ext.textSecondary, fontSize: 13, height: 1.6),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
