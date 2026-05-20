import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/chat_model.dart';
import '../../../services/auth_service.dart';
import '../../../../app_config.dart';

class SupportController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final messageController = TextEditingController();
  final messages = <ChatModel>[].obs;
  final isTyping = false.obs;
  final isSending = false.obs;

  // Use Firebase Auth uid directly — always available after login
  String get userId => _authService.firebaseUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      _listenToMessages();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void _listenToMessages() {
    _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      messages.value =
          snap.docs.map((d) => ChatModel.fromFirestore(d)).toList();
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;
    messageController.clear();

    try {
      final msg = ChatModel(
        id: '',
        senderId: userId,
        message: text,
        timestamp: DateTime.now(),
        type: MessageType.text,
        isFromAdmin: false,
      );

      await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add(msg.toMap());

      // Also update chat metadata
      await _firestore.collection('chats').doc(userId).set({
        'userId': userId,
        'userName': _authService.currentUser.value?.name ?? '',
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadByAdmin': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    isSending.value = true;
    try {
      final ref = _storage.ref(
          'chat_images/$userId/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(image.path));
      final imageUrl = await ref.getDownloadURL();

      final msg = ChatModel(
        id: '',
        senderId: userId,
        message: '[Image]',
        timestamp: DateTime.now(),
        type: MessageType.image,
        imageUrl: imageUrl,
        isFromAdmin: false,
      );

      await _firestore
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .add(msg.toMap());
    } catch (e) {
      Get.snackbar('Error', 'Failed to send image');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> openTelegram() async {
    final uri = Uri.parse(AppConfig.telegramSupportUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
