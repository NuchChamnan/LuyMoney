import 'package:cloud_firestore/cloud_firestore.dart';

enum VideoHostType { youtube, vimeo, direct }

const List<String> contentCategories = [
  'all',
  'finance',
  'investment',
  'mindset',
  'trading',
  'savings',
  'business',
];

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final VideoHostType hostType;
  final String category;
  final Duration duration;
  final DateTime publishedAt;
  final bool isPremium;
  final int viewCount;
  final bool isBookmarked;
  final bool isLiked;
  final double watchProgress; // 0.0 - 1.0

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.hostType,
    required this.category,
    required this.duration,
    required this.publishedAt,
    this.isPremium = true,
    this.viewCount = 0,
    this.isBookmarked = false,
    this.isLiked = false,
    this.watchProgress = 0.0,
  });

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get youtubeVideoId {
    if (hostType != VideoHostType.youtube) return '';
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return '';
    if (uri.host.contains('youtu.be')) return uri.pathSegments.first;
    return uri.queryParameters['v'] ?? '';
  }

  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      hostType: VideoHostType.values.byName(data['hostType'] ?? 'youtube'),
      category: data['category'] ?? 'finance',
      duration: Duration(seconds: data['durationSeconds'] ?? 0),
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPremium: data['isPremium'] ?? true,
      viewCount: data['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'videoUrl': videoUrl,
        'hostType': hostType.name,
        'category': category,
        'durationSeconds': duration.inSeconds,
        'publishedAt': Timestamp.fromDate(publishedAt),
        'isPremium': isPremium,
        'viewCount': viewCount,
      };

  VideoModel copyWith({
    bool? isBookmarked,
    bool? isLiked,
    double? watchProgress,
  }) {
    return VideoModel(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      hostType: hostType,
      category: category,
      duration: duration,
      publishedAt: publishedAt,
      isPremium: isPremium,
      viewCount: viewCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLiked: isLiked ?? this.isLiked,
      watchProgress: watchProgress ?? this.watchProgress,
    );
  }
}

class ArticleModel {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String coverImageUrl;
  final String category;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime publishedAt;
  final int readTimeMinutes;
  final bool isPremium;
  final bool isBookmarked;
  final double scrollProgress;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.coverImageUrl,
    required this.category,
    required this.authorName,
    this.authorAvatarUrl,
    required this.publishedAt,
    required this.readTimeMinutes,
    this.isPremium = true,
    this.isBookmarked = false,
    this.scrollProgress = 0.0,
  });

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      excerpt: data['excerpt'] ?? '',
      content: data['content'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      category: data['category'] ?? 'finance',
      authorName: data['authorName'] ?? 'Luy Money',
      authorAvatarUrl: data['authorAvatarUrl'],
      publishedAt: data['publishedAt'] != null
          ? (data['publishedAt'] as Timestamp).toDate()
          : DateTime.now(),
      readTimeMinutes: data['readTimeMinutes'] ?? 5,
      isPremium: data['isPremium'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() => {
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'coverImageUrl': coverImageUrl,
        'category': category,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
        'publishedAt': Timestamp.fromDate(publishedAt),
        'readTimeMinutes': readTimeMinutes,
        'isPremium': isPremium,
      };

  ArticleModel copyWith({bool? isBookmarked, double? scrollProgress}) {
    return ArticleModel(
      id: id,
      title: title,
      excerpt: excerpt,
      content: content,
      coverImageUrl: coverImageUrl,
      category: category,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      publishedAt: publishedAt,
      readTimeMinutes: readTimeMinutes,
      isPremium: isPremium,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      scrollProgress: scrollProgress ?? this.scrollProgress,
    );
  }
}
