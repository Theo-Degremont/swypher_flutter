import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swypher_flutter/shared/data/models/auth_model.dart';

class MemoryService extends GetxService {
  late final RxBool hasTruffleObs = RxBool(false);

  // ─── Utilisateur courant ──────────────────────────────────────────────────────
  /// Profil de l'utilisateur connecté, null si non chargé ou non connecté.
  final currentUserObs = Rx<UserModel?>(null);

  // ─── Like / Dislike ──────────────────────────────────────────────────────────
  final musicLikedObs    = <String>[].obs;
  final musicDislikedObs = <String>[].obs;

  /// IDs des musiques réellement likées (pour l'affichage du cœur).
  final likedMusicIdsObs = <String>[].obs;

  // ─── Repost ──────────────────────────────────────────────────────────────────
  final musicRepostedObs = <String>[].obs;

  static final MemoryService _mInstance = MemoryService._();
  static MemoryService get instance => _mInstance;

  late SharedPreferences _prefs;
  late GetStorage _storage;

  MemoryService._();

  Future<void> initialize() async {
    await GetStorage.init('sifflard');
    _storage = GetStorage('sifflard');

    _prefs = await SharedPreferences.getInstance();

    final liked     = _storage.read<List>('musicLiked')     ?? [];
    final disliked  = _storage.read<List>('musicDisliked')  ?? [];
    final reposted  = _storage.read<List>('musicReposted')  ?? [];
    musicLikedObs.assignAll(liked.cast<String>());
    musicDislikedObs.assignAll(disliked.cast<String>());
    musicRepostedObs.assignAll(reposted.cast<String>());

    final likedIds = _storage.read<List>('likedMusicIds') ?? [];
    likedMusicIdsObs.assignAll(likedIds.cast<String>());

    final avatarPath = _storage.read<String>('localAvatarPath');
    if (avatarPath != null) localAvatarPathObs.value = avatarPath;
  }

  Future<void> ensureInitialized() async {
    if (!GetStorage().hasData('sifflard')) {
      await initialize();
    }
  }

  // ─── Getters ─────────────────────────────────────────────────────────────────

  List<String> get musicLiked    => List.unmodifiable(musicLikedObs);
  List<String> get musicDisliked => List.unmodifiable(musicDislikedObs);

  // ─── Profil utilisateur ───────────────────────────────────────────────────────

  final localAvatarPathObs = Rx<String?>(null);

  UserModel? get currentUser => currentUserObs.value;

  void setCurrentUser(UserModel user) {
    currentUserObs.value = user;
    languageCode = user.language;
  }

  void clearCurrentUser() {
    currentUserObs.value = null;
  }

  String? get localAvatarPath => localAvatarPathObs.value;

  void setLocalAvatarPath(String path) {
    localAvatarPathObs.value = path;
    _storage.write('localAvatarPath', path);
  }

  void clearLocalAvatarPath() {
    localAvatarPathObs.value = null;
    _storage.remove('localAvatarPath');
  }

  // ─── Toggle like ─────────────────────────────────────────────────────────────

  void toggleLike(String musicId) {
    if (musicLikedObs.contains(musicId)) {
      musicLikedObs.remove(musicId);
      if (!musicDislikedObs.contains(musicId)) musicDislikedObs.add(musicId);
      likedMusicIdsObs.remove(musicId);
    } else {
      musicDislikedObs.remove(musicId);
      musicLikedObs.add(musicId);
      if (!likedMusicIdsObs.contains(musicId)) likedMusicIdsObs.add(musicId);
    }
    _storage.write('musicLiked',    musicLikedObs.toList());
    _storage.write('musicDisliked', musicDislikedObs.toList());
    _storage.write('likedMusicIds', likedMusicIdsObs.toList());
  }

  void syncLikedIds(List<String> ids) {
    likedMusicIdsObs.assignAll(ids);
    _storage.write('likedMusicIds', ids);
  }

  void removeLikedId(String musicId) {
    likedMusicIdsObs.remove(musicId);
    _storage.write('likedMusicIds', likedMusicIdsObs.toList());
  }

  // ─── Repost ──────────────────────────────────────────────────────────────────

  void addRepost(String musicId) {
    if (musicRepostedObs.contains(musicId)) return;
    musicRepostedObs.add(musicId);
    _storage.write('musicReposted', musicRepostedObs.toList());
  }

  // ─── Clear après sync API ────────────────────────────────────────────────────

  void clearLiked() {
    musicLikedObs.clear();
    _storage.remove('musicLiked');
  }

  void clearDisliked() {
    musicDislikedObs.clear();
    _storage.remove('musicDisliked');
  }

  String? get access {
    final value = _prefs.getString('access');
    return value;
  }

  set access(String? value) {
    if (value == null) {
      _prefs.remove('access');
    } else {
      _prefs.setString('access', value);
    }
  }

  String? get refresh {
    final value = _prefs.getString('refresh');
    return value;
  }

  set refresh(String? value) {
    if (value == null) {
      _prefs.remove('refresh');
    } else {
      _prefs.setString('refresh', value);
    }
  }

  String? get languageCode => _storage.read('languageCode');
  set languageCode(String? value) => _storage.write('languageCode', value);
}
