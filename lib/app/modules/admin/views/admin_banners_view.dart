import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/banner_model.dart';
import '../../../shared/themes/app_themes.dart';
import '../controllers/admin_controller.dart';

class AdminBannersView extends GetView<AdminController> {
  const AdminBannersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Column(
      children: [
        // Header + Add button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: ext.surface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Home Page Banners',
                  style: TextStyle(
                      color: ext.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: ext.primary, size: 28),
                onPressed: () => _showBannerDialog(context, ext),
                tooltip: 'Add Banner',
              ),
            ],
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoadingBanners.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.banners.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No banners yet.\nTap + to add a promotional image for the Home page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ext.textSecondary),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.fetchBanners,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.banners.length,
                itemBuilder: (_, i) {
                  final banner = controller.banners[i];
                  return _BannerTile(
                    banner: banner,
                    ext: ext,
                    isFirst: i == 0,
                    isLast: i == controller.banners.length - 1,
                    onEdit: () => _showBannerDialog(context, ext, banner: banner),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showBannerDialog(BuildContext context, AppColorExtension ext,
      {BannerModel? banner}) {
    final imageCtrl = TextEditingController(text: banner?.imageUrl ?? '');
    final titleCtrl = TextEditingController(text: banner?.title ?? '');
    final linkCtrl = TextEditingController(text: banner?.linkUrl ?? '');
    final isEdit = banner != null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Banner' : 'Add Banner',
          style: TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageCtrl.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: CachedNetworkImage(
                          imageUrl: imageCtrl.text,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(color: ext.surface),
                          errorWidget: (_, _, _) => Container(
                            color: ext.surface,
                            child: Icon(Icons.broken_image_outlined,
                                color: ext.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                _DialogField(
                    label: 'Image URL *', controller: imageCtrl, ext: ext),
                const SizedBox(height: 8),
                Obx(() => OutlinedButton.icon(
                      onPressed: controller.isUploadingBannerImage.value
                          ? null
                          : () async {
                              final url =
                                  await controller.pickAndUploadBannerImage();
                              if (url != null) {
                                setState(() => imageCtrl.text = url);
                              }
                            },
                      icon: controller.isUploadingBannerImage.value
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: ext.primary),
                            )
                          : Icon(Icons.photo_library_outlined,
                              color: ext.primary, size: 18),
                      label: Text(
                        controller.isUploadingBannerImage.value
                            ? 'Uploading...'
                            : 'Upload from device',
                        style: TextStyle(color: ext.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ext.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
                const SizedBox(height: 12),
                _DialogField(
                    label: 'Title (optional)', controller: titleCtrl, ext: ext),
                const SizedBox(height: 12),
                _DialogField(
                    label: 'Link (route or URL, optional)',
                    controller: linkCtrl,
                    ext: ext),
                const SizedBox(height: 4),
                Text(
                  'Link can be an in-app route (e.g. /subscription) or an external URL (e.g. https://...)',
                  style: TextStyle(color: ext.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: ext.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final imageUrl = imageCtrl.text.trim();
              final title = titleCtrl.text.trim();
              final link = linkCtrl.text.trim();
              Navigator.of(dialogContext).pop();
              if (isEdit) {
                controller.updateBanner(banner,
                    imageUrl: imageUrl, title: title, linkUrl: link);
              } else {
                controller.addBanner(
                    imageUrl: imageUrl, title: title, linkUrl: link);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
        ),
      ),
    );
  }
}

class _BannerTile extends GetView<AdminController> {
  final BannerModel banner;
  final AppColorExtension ext;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;

  const _BannerTile({
    required this.banner,
    required this.ext,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ext.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 90,
              height: 56,
              child: banner.imageUrl.isEmpty
                  ? Container(
                      color: ext.surface,
                      child: Icon(Icons.image_outlined,
                          color: ext.textSecondary, size: 20),
                    )
                  : CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: ext.surface),
                      errorWidget: (_, _, _) => Container(
                        color: ext.surface,
                        child: Icon(Icons.broken_image_outlined,
                            color: ext.textSecondary, size: 20),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title.isEmpty ? '(No title)' : banner.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: ext.textPrimary, fontWeight: FontWeight.w600),
                ),
                if (banner.linkUrl.isNotEmpty)
                  Text(
                    banner.linkUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ext.textSecondary, fontSize: 12),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      color: isFirst ? ext.textSecondary.withValues(alpha: 0.3) : ext.textSecondary,
                      visualDensity: VisualDensity.compact,
                      onPressed: isFirst
                          ? null
                          : () => controller.reorderBanner(banner, -1),
                      tooltip: 'Move up',
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      color: isLast ? ext.textSecondary.withValues(alpha: 0.3) : ext.textSecondary,
                      visualDensity: VisualDensity.compact,
                      onPressed: isLast
                          ? null
                          : () => controller.reorderBanner(banner, 1),
                      tooltip: 'Move down',
                    ),
                    const Spacer(),
                    Switch(
                      value: banner.isActive,
                      activeThumbColor: ext.primary,
                      onChanged: (_) => controller.toggleBannerActive(banner),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: ext.textSecondary,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red,
                onPressed: () {
                  Get.dialog(AlertDialog(
                    title: const Text('Delete Banner'),
                    content: const Text('Delete this banner?'),
                    actions: [
                      TextButton(onPressed: Get.back, child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteBanner(banner.id);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final AppColorExtension ext;

  const _DialogField({
    required this.label,
    required this.controller,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: ext.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ext.textSecondary),
        filled: true,
        fillColor: ext.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
