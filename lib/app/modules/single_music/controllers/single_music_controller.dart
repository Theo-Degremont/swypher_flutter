import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/modules/single_music/services/single_music_service.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class SingleMusicController extends GetxController {
  late final MainController mainController;
  late final SingleMusicService _service;
  final _audio = AudioService.to;

  late final PageController pageController;

  // Index courant dans la file (miroir de currentQueueIndexObs)
  int _idx = 0;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _service       = Get.find<SingleMusicService>();

    // Trouver la position initiale à partir de la musique en cours
    final current = _audio.currentMusicObs.value;
    final queue   = _audio.currentQueueObs;

    if (current != null && queue.isNotEmpty) {
      final found = queue.indexWhere((m) => m.id == current.id);
      _idx = found >= 0 ? found : _audio.currentQueueIndexObs.value.clamp(0, queue.length - 1);
    } else {
      _idx = _audio.currentQueueIndexObs.value.clamp(0, queue.isEmpty ? 0 : queue.length - 1);
    }

    pageController = PageController(initialPage: _idx);

    // Reprend le listener de fin de piste pour l'auto-avance depuis cette vue
    _audio.listenToMusicComplete(_onTrackComplete);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // ─── Changement de page (swipe) ───────────────────────────────────────────

  void onPageChanged(int index) {
    if (index == _idx) return;
    _playAt(index);
  }

  // ─── Lecture interne ──────────────────────────────────────────────────────

  void _playAt(int index) {
    final queue = _audio.currentQueueObs;
    if (index < 0 || index >= queue.length) return;
    _idx = index;
    _audio.currentQueueIndexObs.value = index;

    final music = queue[index];
    _audio.play(AudioType.music, _service.resolveUrl(music.audioFile));
    _audio.setCurrentMusic(music, _service.resolveCoverUrl(music.coverImage));
    _audio.listenToMusicComplete(_onTrackComplete);
  }

  // ─── Auto-avance à la fin de piste ───────────────────────────────────────

  void _onTrackComplete() {
    final next = _idx + 1;
    if (next < _audio.currentQueueObs.length) {
      _playAt(next);
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _audio.clearCurrentMusic();
    }
  }
}
