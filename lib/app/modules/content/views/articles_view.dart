import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/article_card.dart';
import '../../../shared/widgets/category_chips.dart';
import '../controllers/content_controller.dart';

class ArticlesView extends GetView<ContentController> {
  const ArticlesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('articles'.tr),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() => CategoryChips(
            categories: controller.categories,
            selectedCategory: controller.selectedCategory.value,
            onSelected: controller.filterByCategory,
          )),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingArticles.value && controller.articles.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold));
              }
              if (controller.articles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.article_outlined,
                          size: 64, color: AppColors.gold),
                      const SizedBox(height: 16),
                      Text('no_results'.tr, style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.articles.length +
                    (controller.hasMoreArticles.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == controller.articles.length) {
                    controller.loadArticles();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    );
                  }
                  final article = controller.articles[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ArticleCard(
                      article: article,
                      onBookmark: () =>
                          controller.toggleArticleBookmark(article.id),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
