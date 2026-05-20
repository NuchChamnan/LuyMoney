import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../data/models/content_model.dart';
import '../controllers/admin_controller.dart';

class AdminContentView extends GetView<AdminController> {
  const AdminContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Column(
      children: [
        // Tabs + Add button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: ext.surface,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _TabBtn(label: 'Videos', index: 0, ext: ext),
                    const SizedBox(width: 8),
                    _TabBtn(label: 'Articles', index: 1, ext: ext),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: ext.primary, size: 28),
                onPressed: () => _showAddDialog(context, ext),
                tooltip: 'Add Content',
              ),
            ],
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoadingContent.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.contentTab.value == 0) {
              return _buildVideosList(context, ext);
            } else {
              return _buildArticlesList(context, ext);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildVideosList(BuildContext context, AppColorExtension ext) {
    if (controller.videos.isEmpty) {
      return Center(
          child: Text('No videos yet',
              style: TextStyle(color: ext.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: controller.fetchContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.videos.length,
        itemBuilder: (_, i) {
          final video = controller.videos[i];
          return _ContentTile(
            title: video.title,
            subtitle: '${video.category} • ${video.viewCount} views',
            icon: Icons.play_circle_outline,
            ext: ext,
            onEdit: () => _showEditVideoDialog(context, ext, video),
            onDelete: () => controller.deleteVideo(video.id),
          );
        },
      ),
    );
  }

  Widget _buildArticlesList(BuildContext context, AppColorExtension ext) {
    if (controller.articles.isEmpty) {
      return Center(
          child: Text('No articles yet',
              style: TextStyle(color: ext.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: controller.fetchContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.articles.length,
        itemBuilder: (_, i) {
          final article = controller.articles[i];
          return _ContentTile(
            title: article.title,
            subtitle: '${article.category} • ${article.readTimeMinutes} min read',
            icon: Icons.article_outlined,
            ext: ext,
            onEdit: () {},
            onDelete: () => controller.deleteArticle(article.id),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppColorExtension ext) {
    final isVideo = controller.contentTab.value == 0;
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    final urlCtrl   = TextEditingController();
    final selectedCategory = controller.categories.first.obs;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isVideo ? 'Add Video' : 'Add Article',
          style: TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogField(label: 'Title *', controller: titleCtrl, ext: ext),
                const SizedBox(height: 12),
                _DialogField(
                    label: isVideo ? 'YouTube URL *' : 'Cover Image URL',
                    controller: urlCtrl,
                    ext: ext),
                const SizedBox(height: 16),

                // ── Category picker ────────────────────────────────────────
                Text('Category',
                    style: TextStyle(
                        color: ext.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...controller.categories.map((cat) {
                          final isSel = selectedCategory.value == cat;
                          return GestureDetector(
                            onTap: () => selectedCategory.value = cat,
                            onLongPress: () => _showCategoryOptionsDialog(
                                dialogContext, ext, cat, selectedCategory),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel ? ext.primary : ext.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSel ? ext.primary : ext.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat[0].toUpperCase() + cat.substring(1),
                                    style: TextStyle(
                                      color: isSel ? Colors.black : ext.textPrimary,
                                      fontSize: 13,
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSel) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.check, size: 14, color: Colors.black),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                        // + Add new category chip
                        GestureDetector(
                          onTap: () => _showAddCategoryDialog(
                              dialogContext, ext, selectedCategory),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: ext.primary,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: ext.primary, size: 16),
                                const SizedBox(width: 4),
                                Text('New',
                                    style: TextStyle(
                                        color: ext.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 12),
                _DialogField(
                    label: 'Description',
                    controller: descCtrl,
                    ext: ext,
                    maxLines: 3),
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
              final title    = titleCtrl.text.trim();
              final url      = urlCtrl.text.trim();
              final category = selectedCategory.value;
              final desc     = descCtrl.text.trim();
              Navigator.of(dialogContext).pop();
              if (isVideo) {
                controller.addVideo(
                    title: title, videoUrl: url,
                    category: category, description: desc);
              } else {
                controller.addArticle(
                    title: title, coverImageUrl: url,
                    category: category, description: desc);
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
    );
  }

  void _showCategoryOptionsDialog(
    BuildContext context,
    AppColorExtension ext,
    String category,
    RxString selectedCategory,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '"${category[0].toUpperCase()}${category.substring(1)}"',
          style: TextStyle(color: ext.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            ListTile(
              leading: Icon(Icons.edit_outlined, color: ext.primary),
              title: Text('Edit Category',
                  style: TextStyle(color: ext.textPrimary)),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(ctx).pop();
                _showEditCategoryDialog(
                    context, ext, category, selectedCategory);
              },
            ),
            Divider(color: ext.border, height: 1),
            // Delete
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove Category',
                  style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(ctx).pop();
                showDialog(
                  context: context,
                  builder: (confirm) => AlertDialog(
                    backgroundColor: ext.card,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text('Remove Category',
                        style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w700)),
                    content: Text(
                        'Remove "$category"? Videos using this category will keep the old value.',
                        style: TextStyle(color: ext.textSecondary)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(confirm).pop(),
                        child: Text('Cancel',
                            style: TextStyle(color: ext.textSecondary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(confirm).pop();
                          if (selectedCategory.value == category) {
                            selectedCategory.value =
                                controller.categories.isNotEmpty &&
                                        controller.categories.first != category
                                    ? controller.categories.first
                                    : '';
                          }
                          controller.deleteCategory(category);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: ext.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    AppColorExtension ext,
    String oldName,
    RxString selectedCategory,
  ) {
    final editCtrl = TextEditingController(
        text: oldName[0].toUpperCase() + oldName.substring(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Category',
            style: TextStyle(
                color: ext.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: editCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: ext.textPrimary),
          decoration: InputDecoration(
            hintText: 'Category name',
            hintStyle: TextStyle(color: ext.textSecondary),
            filled: true,
            fillColor: ext.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: ext.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = editCtrl.text.trim();
              if (newName.isEmpty) return;
              Navigator.of(ctx).pop();
              final wasSelected = selectedCategory.value == oldName;
              controller.updateCategory(oldName, newName).then((_) {
                if (wasSelected) {
                  selectedCategory.value = newName.toLowerCase();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    AppColorExtension ext,
    RxString selectedCategory,
  ) {
    final newCatCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Category',
            style: TextStyle(
                color: ext.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: newCatCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: ext.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Crypto, Real Estate...',
            hintStyle: TextStyle(color: ext.textSecondary),
            filled: true,
            fillColor: ext.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              Navigator.of(ctx).pop();
              controller.addCategory(v.trim()).then((_) {
                selectedCategory.value = v.trim().toLowerCase();
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: ext.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = newCatCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.of(ctx).pop();
              controller.addCategory(name).then((_) {
                selectedCategory.value = name.toLowerCase();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ext.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditVideoDialog(
      BuildContext context, AppColorExtension ext, VideoModel video) {
    final titleCtrl = TextEditingController(text: video.title);
    final descCtrl = TextEditingController(text: video.description);
    final urlCtrl = TextEditingController(text: video.videoUrl);

    Get.dialog(
      Dialog(
        backgroundColor: ext.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Video',
                  style: TextStyle(
                      color: ext.textPrimary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _DialogField(label: 'Title', controller: titleCtrl, ext: ext),
              const SizedBox(height: 12),
              _DialogField(label: 'Video URL', controller: urlCtrl, ext: ext),
              const SizedBox(height: 12),
              _DialogField(
                  label: 'Description',
                  controller: descCtrl,
                  ext: ext,
                  maxLines: 3),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: Get.back, child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      AppSnackbar.success('Video updated');
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBtn extends GetView<AdminController> {
  final String label;
  final int index;
  final AppColorExtension ext;
  const _TabBtn({required this.label, required this.index, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.contentTab.value == index;
      return GestureDetector(
        onTap: () => controller.contentTab.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? ext.primary : ext.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : ext.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }
}

class _ContentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppColorExtension ext;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.ext,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ext.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ext.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ext.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: ext.textPrimary, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        TextStyle(color: ext.textSecondary, fontSize: 12)),
              ],
            ),
          ),
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
                title: const Text('Delete'),
                content: Text('Delete "$title"?'),
                actions: [
                  TextButton(onPressed: Get.back, child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onDelete();
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ));
            },
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
  final int maxLines;

  const _DialogField({
    required this.label,
    required this.controller,
    required this.ext,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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

// ignore: avoid_classes_with_only_static_members
class AppSnackbar {
  static void success(String msg) => Get.snackbar('Success', msg,
      backgroundColor: Colors.green.shade800, colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM);
}
