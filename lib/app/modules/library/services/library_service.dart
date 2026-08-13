import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class LibraryService extends GetxService {
  final MusicApi _musicApi = Get.find<MusicApi>();

  /// Synchronise les likes/dislikes en attente puis récupère les musiques
  /// likées depuis l'API.
  ///
  /// - Envoie [postLike] si [musicLikedObs] est non vide.
  /// - Envoie [deleteLike] si [musicDislikedObs] est non vide.
  /// - Une fois la sync faite, vide les listes locales.
  /// - Appelle ensuite GET /music/like et retourne la liste.
  ///
  /// Ne fait rien si l'utilisateur n'est pas connecté.
  Future<List<MusicModel>> syncAndFetchLiked() async {
    final memory = MemoryService.instance;

    if (memory.access == null) return [];

    final liked    = List<String>.from(memory.musicLikedObs);
    final disliked = List<String>.from(memory.musicDislikedObs);

    // ── Sync en parallèle si nécessaire ──────────────────────────────────────
    final futures = <Future<void>>[];

    if (liked.isNotEmpty) {
      futures.add(
        _musicApi.postLike(liked).then((r) {
          if (r.isSuccess) memory.clearLiked();
        }),
      );
    }

    if (disliked.isNotEmpty) {
      futures.add(
        _musicApi.deleteLike(disliked).then((r) {
          if (r.isSuccess) memory.clearDisliked();
        }),
      );
    }

    if (futures.isNotEmpty) await Future.wait(futures);

    // ── Fetch des musiques likées ─────────────────────────────────────────────
    final parsed = await _musicApi.getLiked();
    final musics = parsed.data ?? [];
    memory.syncLikedIds(musics.map((m) => m.id).toList());
    return musics;
  }
}
