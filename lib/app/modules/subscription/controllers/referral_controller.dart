import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/auth_service.dart';
import '../../../shared/utils/app_utils.dart';

class ReferralController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = Get.find<AuthService>();

  final referralCode = ''.obs;
  final referralCount = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReferralCode();
  }

  Future<void> _loadReferralCode() async {
    final uid = _auth.currentUser.value?.id;
    if (uid == null) return;

    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null && data['referralCode'] != null) {
      referralCode.value = data['referralCode'] as String;
    } else {
      // Generate new code
      final code = _generateCode(uid);
      await _db.collection('users').doc(uid).update({'referralCode': code});
      referralCode.value = code;
    }

    // Count referrals
    final refSnap = await _db
        .collection('referrals')
        .where('referrerId', isEqualTo: uid)
        .get();
    referralCount.value = refSnap.docs.length;
  }

  String _generateCode(String uid) {
    // Take first 6 chars of uid + timestamp suffix
    final base = uid.substring(0, 6).toUpperCase();
    final suffix = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    return '$base$suffix';
  }

  Future<void> applyReferralCode(String code) async {
    final uid = _auth.currentUser.value?.id;
    if (uid == null) return;

    isLoading.value = true;
    try {
      // Find referrer
      final snap = await _db
          .collection('users')
          .where('referralCode', isEqualTo: code.toUpperCase().trim())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        AppSnackbar.error('invalid_referral_code'.tr);
        return;
      }

      final referrerId = snap.docs.first.id;
      if (referrerId == uid) {
        AppSnackbar.error('cannot_use_own_referral'.tr);
        return;
      }

      // Check not already referred
      final existing = await _db
          .collection('referrals')
          .where('refereeId', isEqualTo: uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        AppSnackbar.error('already_referred'.tr);
        return;
      }

      // Create referral record
      await _db.collection('referrals').add({
        'referrerId': referrerId,
        'refereeId': uid,
        'code': code.toUpperCase(),
        'status': 'pending', // 'rewarded' once first purchase is made
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppSnackbar.success('referral_applied'.tr);
    } catch (e) {
      AppSnackbar.error('$e');
    } finally {
      isLoading.value = false;
    }
  }

  void shareReferralCode() {
    if (referralCode.value.isEmpty) return;

    final deepLink =
        'https://luymoney.page.link/ref?code=${referralCode.value}';

    Share.share(
      'Join Luy Money — the financial learning app! '
      'Use my code ${referralCode.value} to get 7 days free. '
      'Download: $deepLink',
      subject: 'Join Luy Money with my referral',
    );
  }

  Future<void> rewardReferral(String referralId) async {
    // Called after a successful subscription payment
    final doc = await _db.collection('referrals').doc(referralId).get();
    if (!doc.exists || doc['status'] == 'rewarded') return;

    final referrerId = doc['referrerId'] as String;

    // Extend referrer subscription by 30 days
    final subSnap = await _db
        .collection('subscriptions')
        .where('userId', isEqualTo: referrerId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (subSnap.docs.isNotEmpty) {
      final sub = subSnap.docs.first;
      final expiry = (sub['expiryDate'] as Timestamp).toDate();
      await sub.reference.update({
        'expiryDate': Timestamp.fromDate(expiry.add(const Duration(days: 30))),
      });
    }

    await _db.collection('referrals').doc(referralId).update({
      'status': 'rewarded',
      'rewardedAt': FieldValue.serverTimestamp(),
    });
  }
}
