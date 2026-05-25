import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/utils/app_utils.dart';

class PromoCodeController extends GetxController {
  final _db = FirebaseFirestore.instance;

  final promoCode = ''.obs;
  final promoController = TextEditingController();
  final isValidating = false.obs;
  final appliedDiscount = 0.0.obs;
  final isApplied = false.obs;
  final discountLabel = ''.obs;

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }

  Future<void> validateAndApply(String planId, double originalPrice) async {
    final code = promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppSnackbar.error('enter_promo_code'.tr);
      return;
    }

    isValidating.value = true;
    try {
      final snap = await _db
          .collection('promo_codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        AppSnackbar.error('invalid_promo_code'.tr);
        return;
      }

      final data = snap.docs.first.data();
      final expiry = (data['expiresAt'] as Timestamp?)?.toDate();
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        AppSnackbar.error('promo_code_expired'.tr);
        return;
      }

      final maxUsage = data['maxUsage'] as int? ?? 0;
      final usageCount = data['usageCount'] as int? ?? 0;
      if (maxUsage > 0 && usageCount >= maxUsage) {
        AppSnackbar.error('promo_code_maxed'.tr);
        return;
      }

      final applicablePlans = (data['applicablePlans'] as List?)?.cast<String>();
      if (applicablePlans != null && !applicablePlans.contains(planId)) {
        AppSnackbar.error('promo_not_for_plan'.tr);
        return;
      }

      final discountType = data['discountType'] as String; // percent | fixed
      final discountValue = (data['discountValue'] as num).toDouble();

      double discount = 0;
      if (discountType == 'percent') {
        discount = originalPrice * (discountValue / 100);
        discountLabel.value = '${discountValue.toInt()}% off';
      } else {
        discount = discountValue;
        discountLabel.value = '\$${discountValue.toStringAsFixed(2)} off';
      }

      appliedDiscount.value = discount;
      promoCode.value = code;
      isApplied.value = true;

      AppSnackbar.success('Promo applied: ${discountLabel.value}');
    } catch (e) {
      AppSnackbar.error('promo_error'.tr);
    } finally {
      isValidating.value = false;
    }
  }

  void removePromo() {
    promoCode.value = '';
    appliedDiscount.value = 0;
    isApplied.value = false;
    discountLabel.value = '';
    promoController.clear();
  }

  Future<void> markCodeUsed() async {
    if (promoCode.value.isEmpty) return;
    try {
      final snap = await _db
          .collection('promo_codes')
          .where('code', isEqualTo: promoCode.value)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'usageCount': FieldValue.increment(1),
        });
      }
    } catch (_) {}
  }
}

// ── Promo Code Widget ─────────────────────────────────────────────────────────
class PromoCodeField extends StatelessWidget {
  final PromoCodeController controller;
  final String planId;
  final double originalPrice;

  const PromoCodeField({
    super.key,
    required this.controller,
    required this.planId,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isApplied.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.promoCode.value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      controller.discountLabel.value,
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: controller.removePromo,
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.promoController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'enter_promo_code'.tr,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => ElevatedButton(
                onPressed: controller.isValidating.value
                    ? null
                    : () => controller.validateAndApply(
                        planId, originalPrice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isValidating.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ))
                    : Text('apply'.tr),
              )),
        ],
      );
    });
  }
}
