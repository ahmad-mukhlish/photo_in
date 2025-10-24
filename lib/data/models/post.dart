class Post {
  const Post({
    required this.id,
    required this.photoUrl,
    required this.caption,
    required this.authorId,
    required this.authorUsername,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['created_at'];
    final createdAtSeconds = createdAtValue is num
        ? createdAtValue.toInt()
        : int.tryParse('$createdAtValue') ?? 0;

    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      createdAtSeconds * 1000,
      isUtc: true,
    );

    return Post(
      id: json['id'] as int,
      photoUrl: json['photo_url'] as String,
      caption: (json['caption'] as String?) ?? '',
      authorId: json['author_id'] as int,
      authorUsername: (json['author_uname'] as String?) ?? '',
      createdAt: createdAt,
    );
  }

  final int id;
  final String photoUrl;
  final String caption;
  final int authorId;
  final String authorUsername;
  final DateTime createdAt;

  String get formattedCreatedAt {
    final local = createdAt.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

