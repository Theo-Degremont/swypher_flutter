import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:swypher_flutter/shared/data/models/auth_model.dart';

class MemoryService extends GetxService {
  final currentUserObs = Rx<UserModel?>(null);

  final musicLikedObs    = <String>[].obs;
  final musicDislikedObs = <String>[].obs;

  final likedMusicIdsObs = <String>[].obs;

  final musicRepostedObs   = <String>[].obs;
  final searchHistoryObs   = <String>[].obs;

  static final MemoryService _mInstance = MemoryService._();
  static MemoryService get instance => _mInstance;

  // Refresh token : cache RAM + Keychain/Keystore chiffré (iOS Keychain, Android Keystore)
  String? _refreshCache;
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late GetStorage _storage;

  MemoryService._();

  Future<void> initialize() async {
    await GetStorage.init('sifflard');
    _storage = GetStorage('sifflard');

    // Charger le refresh token depuis le stockage sécurisé au démarrage
    _refreshCache = await _secureStorage.read(key: 'refresh');

    final liked     = _storage.read<List>('musicLiked')     ?? [];
    final disliked  = _storage.read<List>('musicDisliked')  ?? [];
    final reposted  = _storage.read<List>('musicReposted')  ?? [];
    final history   = _storage.read<List>('searchHistory')  ?? [];
    musicLikedObs.assignAll(liked.cast<String>());
    musicDislikedObs.assignAll(disliked.cast<String>());
    musicRepostedObs.assignAll(reposted.cast<String>());
    searchHistoryObs.assignAll(history.cast<String>());

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


  List<String> get musicLiked    => List.unmodifiable(musicLikedObs);
  List<String> get musicDisliked => List.unmodifiable(musicDislikedObs);

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


  void addRepost(String musicId) {
    if (musicRepostedObs.contains(musicId)) return;
    musicRepostedObs.add(musicId);
    _storage.write('musicReposted', musicRepostedObs.toList());
  }


  void clearLiked() {
    musicLikedObs.clear();
    _storage.remove('musicLiked');
  }

  void clearDisliked() {
    musicDislikedObs.clear();
    _storage.remove('musicDisliked');
  }

  void clearRepost() {
    musicRepostedObs.clear();
    _storage.remove('musicReposted');
  }

  void addSearchHistory(String title) {
    searchHistoryObs.remove(title);
    searchHistoryObs.insert(0, title);
    if (searchHistoryObs.length > 20) searchHistoryObs.removeLast();
    _storage.write('searchHistory', searchHistoryObs.toList());
  }

  void removeSearchHistoryEntry(String title) {
    searchHistoryObs.remove(title);
    _storage.write('searchHistory', searchHistoryObs.toList());
  }

  void clearSearchHistory() {
    searchHistoryObs.clear();
    _storage.remove('searchHistory');
  }

  /// Vide toutes les données de session (déconnexion / suppression de compte).
  Future<void> clearSessionData() async {
    access = null;  // RAM uniquement — pas d'I/O
    await setRefresh(null);
    clearCurrentUser();
    clearLocalAvatarPath();
    clearLiked();
    clearDisliked();
    clearRepost();
    likedMusicIdsObs.clear();
    _storage.write('likedMusicIds', <String>[]);
  }

  // ─── Access token : RAM uniquement ───────────────────────────────────────────
  // Champ public direct : pas de disque, pas de chiffrement — la durée de vie
  // de 15 min rend le stockage persistant inutile.
  String? access;

  // ─── Refresh token : Keychain (iOS) / Keystore (Android) ─────────────────────

  String? get refresh => _refreshCache;

  Future<void> setRefresh(String? value) async {
    _refreshCache = value;
    if (value == null) {
      await _secureStorage.delete(key: 'refresh');
    } else {
      await _secureStorage.write(key: 'refresh', value: value);
    }
  }

  String? get languageCode => _storage.read('languageCode');
  set languageCode(String? value) => _storage.write('languageCode', value);
}
