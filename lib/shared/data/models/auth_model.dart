class TokensModel {
  final String accessToken;
  final String refreshToken;

  TokensModel({required this.accessToken, required this.refreshToken});

  factory TokensModel.fromJson(Map<String, dynamic> json) => TokensModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

class UserModel {
  final String id;
  final String pseudo;
  final String email;
  final String? stageName;
  final String? description;
  final String? profilePicture;
  final String role;
  final String status;
  final String language;
  final bool isDeletionInProgress;
  final String? deletionDate;
  final bool isSubscribed;
  final String createdAt;
  final String? modifiedAt;

  UserModel({
    required this.id,
    required this.pseudo,
    required this.email,
    this.stageName,
    this.description,
    this.profilePicture,
    required this.role,
    required this.status,
    required this.language,
    required this.isDeletionInProgress,
    this.deletionDate,
    required this.isSubscribed,
    required this.createdAt,
    this.modifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        pseudo: json['pseudo'] as String,
        email: json['email'] as String? ?? '',
        stageName: json['stageName'] as String?,
        description: json['description'] as String?,
        profilePicture: json['profilePicture'] as String?,
        role: json['role'] as String? ?? 'user',
        status: json['status'] as String? ?? 'active',
        language: json['language'] as String? ?? 'fr',
        isDeletionInProgress:
            json['isDeletionInProgress'] as bool? ?? false,
        deletionDate: json['deletionDate'] as String?,
        isSubscribed: json['isSubscribed'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
        modifiedAt: json['modifiedAt'] as String?,
      );
}

class AuthData {
  final UserModel user;
  final TokensModel tokens;

  AuthData({required this.user, required this.tokens});

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        tokens: TokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}

class RefreshData {
  final TokensModel tokens;

  RefreshData({required this.tokens});

  factory RefreshData.fromJson(Map<String, dynamic> json) => RefreshData(
        tokens: TokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}
