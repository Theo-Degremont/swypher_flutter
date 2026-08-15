import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/api_response.dart';
import 'package:swypher_flutter/shared/data/models/auth_model.dart';
import 'package:swypher_flutter/shared/data/network/api_client.dart';

class AuthApi extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  /// Crée un nouveau compte.
  Future<ApiResponse<AuthData>> register({
    required String pseudo,
    required String email,
    required String password,
  }) =>
      _client.post<AuthData>(
        ApiConfiguration.registerPath,
        body: {
          'pseudo': pseudo,
          'email': email,
          'password': password,
        },
        fromData: (data) => AuthData.fromJson(data as Map<String, dynamic>),
      );

  /// Authentifie un utilisateur existant.
  Future<ApiResponse<AuthData>> login({
    required String email,
    required String password,
  }) =>
      _client.post<AuthData>(
        ApiConfiguration.loginPath,
        body: {
          'email': email,
          'password': password,
        },
        fromData: (data) => AuthData.fromJson(data as Map<String, dynamic>),
      );

  /// Renouvelle la paire de tokens (refresh → rotation).
  Future<ApiResponse<RefreshData>> refreshTokens({
    required String refreshToken,
  }) =>
      _client.post<RefreshData>(
        ApiConfiguration.refreshPath,
        body: {'refreshToken': refreshToken},
        fromData: (data) => RefreshData.fromJson(data as Map<String, dynamic>),
      );

  /// Récupère le profil de l'utilisateur connecté (GET /user/me).
  Future<ApiResponse<UserModel>> getMe() =>
      _client.get<UserModel>(
        ApiConfiguration.mePath,
        requiresAuth: true,
        fromData: (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

  /// Supprime le compte de l'utilisateur connecté (DELETE /user/me).
  Future<ApiResponse<void>> deleteMe() =>
      _client.delete<void>(ApiConfiguration.mePath, requiresAuth: true);

  Future<ApiResponse<UserModel>> updateMe({
    String? pseudo,
    String? stageName,
    String? description,
  }) async {
    final body = <String, dynamic>{
      if (pseudo      != null) 'pseudo':      pseudo,
      if (stageName   != null) 'stageName':   stageName,
      if (description != null) 'description': description,
    };
    return _client.patch<UserModel>(
      ApiConfiguration.mePath,
      body: body,
      fromData: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
