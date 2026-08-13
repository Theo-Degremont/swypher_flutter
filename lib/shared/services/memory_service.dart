import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryService extends GetxService {
  late final RxBool hasTruffleObs = RxBool(false);

  // ─── Like / Dislike ──────────────────────────────────────────────────────────
  final musicLikedObs    = <String>[].obs;
  final musicDislikedObs = <String>[].obs;

  /// IDs des musiques réellement likées (pour l'affichage du cœur).
  /// Mis à jour au toggle et synchronisé depuis l'API au chargement de la library.
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

    // Restaure les listes persistées
    final liked     = _storage.read<List>('musicLiked')     ?? [];
    final disliked  = _storage.read<List>('musicDisliked')  ?? [];
    final reposted  = _storage.read<List>('musicReposted')  ?? [];
    musicLikedObs.assignAll(liked.cast<String>());
    musicDislikedObs.assignAll(disliked.cast<String>());
    musicRepostedObs.assignAll(reposted.cast<String>());

    final likedIds = _storage.read<List>('likedMusicIds') ?? [];
    likedMusicIdsObs.assignAll(likedIds.cast<String>());
  }

  Future<void> ensureInitialized() async {
    if (!GetStorage().hasData('sifflard')) {
      await initialize();
    }
  }

  // ─── Getters ─────────────────────────────────────────────────────────────────

  List<String> get musicLiked    => List.unmodifiable(musicLikedObs);
  List<String> get musicDisliked => List.unmodifiable(musicDislikedObs);

  // ─── Toggle like ─────────────────────────────────────────────────────────────

  /// - Pas liké       → like   (ajoute dans liked)
  /// - Déjà liké      → unlike (retire de liked, ajoute dans disliked)
  /// - Dans disliked   → re-like (retire de disliked, ajoute dans liked)
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

  /// Synchronise la liste d'affichage avec les IDs récupérés depuis l'API.
  void syncLikedIds(List<String> ids) {
    likedMusicIdsObs.assignAll(ids);
    _storage.write('likedMusicIds', ids);
  }

  /// Retire un ID de la liste d'affichage (après suppression depuis la library).
  void removeLikedId(String musicId) {
    likedMusicIdsObs.remove(musicId);
    _storage.write('likedMusicIds', likedMusicIdsObs.toList());
  }

  // ─── Repost ──────────────────────────────────────────────────────────────────

  /// Marque une musique comme repostée (irrévocable côté API).
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