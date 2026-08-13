import 'dart:async';

import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/library/services/library_service.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class LibraryController extends GetxController {
  late final LibraryService _libraryService;
  final _audio = AudioService.to;

  final likedMusics  = <MusicModel>[].obs;
  final isLoading    = false.obs;

  /// Index de la piste en lecture. -1 = aucune.
  final currentIndex = (-1).obs;

  StreamSubscription? _completeSub;

  @override
  void onInit() {
    super.onInit();
    _libraryService = Get.find<LibraryService>();
    if (MemoryService.instance.access == null) return;
    _syncAndLoad();
  }

  Future<void> _syncAndLoad() async {
    isLoading.value = true;
    final results = await _libraryService.syncAndFetchLiked();
    likedMusics.assignAll(results);
    isLoading.value = false;
  }

  Future<void> reloadLiked() async {
    if (MemoryService.instance.access == null) return;
    await _syncAndLoad();
  }

  Future<void> removeFromLiked(MusicModel music) async {
    final response = await Get.find<MusicApi>().deleteLike([music.id]);
    if (response.isSuccess) {
      likedMusics.remove(music);
      MemoryService.instance.removeLikedId(music.id);
      MemoryService.instance.musicLikedObs.remove(music.id);
    }
  }

  // ─── Lecture ─────────────────────────────────────────────────────────────────

  void playAt(int index) {
    if (index < 0 || index >= likedMusics.length) return;
    currentIndex.value = index;
    _completeSub?.cancel();
    _audio.play(AudioType.music, _resolveUrl(likedMusics[index].audioFile));
    _completeSub = _audio.onComplete(AudioType.music).listen((_) {
      final next = currentIndex.value + 1;
      if (next < likedMusics.length) {
        playAt(next);
      } else {
        currentIndex.value = -1;
      }
    });
  }

  void togglePlay() {
    if (_audio.isPlayingRx(AudioType.music).value) {
      _audio.pause(AudioType.music);
    } else {
      if (currentIndex.value >= 0) {
        _audio.resume(AudioType.music);
      } else if (likedMusics.isNotEmpty) {
        playAt(0);
      }
    }
  }

  /// Appelé par MainController quand on quitte l'onglet library.
  void stopMusic() {
    _completeSub?.cancel();
    _audio.stop(AudioType.music);
    currentIndex.value = -1;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String? resolveCoverUrl(String? coverImage) {
    if (coverImage == null) return null;
    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
      return coverImage;
    }
    return '${ApiConfiguration.baseUrl}$coverImage';
  }

  String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get totalDurationText {
    final total = likedMusics.fold<int>(0, (sum, m) => sum + (m.duration ?? 0));
    if (total == 0) return '';
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m} min';
  }

  String _resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) {
      return audioFile;
    }
    final base = ApiConfiguration.baseUrl;
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '$base$path'; // ignore: unnecessary_brace_in_string_interps
  }
}
