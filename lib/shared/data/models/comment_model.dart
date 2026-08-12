class CommentUser {
  final String id;
  final String pseudo;
  final String? profilePicture;

  CommentUser({required this.id, required this.pseudo, this.profilePicture});

  factory CommentUser.fromJson(Map<String, dynamic> json) => CommentUser(
        id: json['id'] as String,
        pseudo: json['pseudo'] as String? ?? 'Anonyme',
        profilePicture: json['profilePicture'] as String?,
      );
}

class CommentModel {
  final String id;
  final String content;
  final String createdAt;
  final CommentUser user;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String,
        content: json['content'] as String,
        createdAt: json['createdAt'] as String,
        user: CommentUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}
