import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/models/auth_model.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class ProfileService extends GetxService {
  final AuthApi  _authApi  = Get.find<AuthApi>();
  final MusicApi _musicApi = Get.find<MusicApi>();

  Future<UserModel?> fetchCurrentUser() async {
    final memory = MemoryService.instance;
    if (memory.currentUser != null) return memory.currentUser;

    final res = await _authApi.getMe();
    if (res.isSuccess && res.data != null) {
      memory.setCurrentUser(res.data!);
      return res.data;
    }
    return null;
  }

  Future<({List<MusicModel> published, List<MusicModel> drafts})>
      fetchUserMusics(String userId) async {
    final res = await _musicApi.getUserMusics(userId);
    return _splitByStatus(res.data ?? []);
  }

  Future<({List<MusicModel> published, List<MusicModel> drafts})>
      fetchUserToplines(String userId) async {
    final res = await _musicApi.getUserToplines(userId);
    return _splitByStatus(res.data ?? []);
  }

  Future<List<MusicModel>> fetchUserReposts(String userId) async {
    final res = await _musicApi.getUserReposts(userId);
    return res.data ?? [];
  }

  Future<bool> deleteMusic(String musicId) async {
    final res = await _musicApi.deleteMusic(musicId);
    return res.isSuccess;
  }

  Future<({UserModel? user, String? error})> updateProfile({
    String? pseudo,
    String? stageName,
    String? description,
  }) async {
    final res = await _authApi.updateMe(
      pseudo: pseudo,
      stageName: stageName,
      description: description,
    );
    if (res.isSuccess && res.data != null) {
      MemoryService.instance.setCurrentUser(res.data!);
      return (user: res.data, error: null);
    }
    return (user: null, error: res.errorMessage ?? 'Une erreur est survenue');
  }

  ({List<MusicModel> published, List<MusicModel> drafts}) _splitByStatus(
      List<MusicModel> musics) {
    final published = <MusicModel>[];
    final drafts    = <MusicModel>[];
    for (final m in musics) {
      if (m.status == 'draft') {
        drafts.add(m);
      } else {
        published.add(m);
      }
    }
    return (published: published, drafts: drafts);
  }
}
