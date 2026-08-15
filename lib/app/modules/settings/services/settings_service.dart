import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';

class SettingsService extends GetxService {
  final AuthApi  _authApi  = Get.find<AuthApi>();
  final MusicApi _musicApi = Get.find<MusicApi>();

  Future<void> syncPendingLikes({
    required List<String> liked,
    required List<String> disliked,
  }) async {
    if (liked.isNotEmpty)    await _musicApi.postLike(liked);
    if (disliked.isNotEmpty) await _musicApi.deleteLike(disliked);
  }

  Future<({bool success, String? error})> deleteAccount() async {
    final res = await _authApi.deleteMe();
    if (res.isSuccess) return (success: true, error: null);
    return (success: false, error: res.errorMessage ?? 'Une erreur est survenue');
  }

  Future<({bool success, String? error})> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _authApi.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (res.isSuccess) return (success: true, error: null);
    return (success: false, error: res.errorMessage ?? 'Une erreur est survenue');
  }
}
