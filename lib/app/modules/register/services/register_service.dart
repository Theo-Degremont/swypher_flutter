import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/models/api_response.dart';
import 'package:swypher_flutter/shared/data/models/auth_model.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class RegisterService extends GetxService {
  final AuthApi _authApi = Get.find<AuthApi>();
  final MemoryService _memory = Get.find<MemoryService>();

  /// Inscrit un nouvel utilisateur et sauvegarde les tokens en local.
  /// Retourne l'ApiResponse pour que le controller gère l'UI.
  Future<ApiResponse<AuthData>> register({
    required String pseudo,
    required String email,
    required String password,
  }) async {
    final response = await _authApi.register(
      pseudo: pseudo,
      email: email,
      password: password,
    );

    if (response.isSuccess && response.data != null) {
      _memory.access = response.data!.tokens.accessToken;
      await _memory.setRefresh(response.data!.tokens.refreshToken);
    }

    return response;
  }
}
