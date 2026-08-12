class MusicModel {
  final String id;
  final String title;
  final String? coverImage;
  final String audioFile;
  final String? beatmakerId;
  final String? beatmakerName;
  final String type;
  final int? duration;
  final int listenCount;
  final int likeCount;
  final int favoriteCount;
  final int repostCount;
  final String status;
  final String createdAt;

  MusicModel({
    required this.id,
    required this.title,
    this.coverImage,
    required this.audioFile,
    this.beatmakerId,
    this.beatmakerName,
    required this.type,
    this.duration,
    required this.listenCount,
    required this.likeCount,
    required this.favoriteCount,
    required this.repostCount,
    required this.status,
    required this.createdAt,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    // Beatmaker name peut venir d'un objet imbriqué beatmaker ou user.
    final beatmaker = json['beatmaker'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    final beatmakerName =
        (beatmaker?['username'] ?? beatmaker?['name'] ?? user?['username'] ?? user?['name'])
            as String?;

    return MusicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverImage: json['coverImage'] as String?,
      audioFile: json['audioFile'] as String,
      beatmakerId: json['beatmakerId'] as String?,
      beatmakerName: beatmakerName,
      type: json['type'] as String,
      duration: json['duration'] as int?,
      listenCount: json['listenCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
