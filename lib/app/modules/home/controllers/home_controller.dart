import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class HomeController extends GetxController {
  // ─── Tab ────────────────────────────────────────────────────────────────────

  final selectedTab = 0.obs;
  void selectTab(int index) => selectedTab.value = index;

  // ─── Feed ────────────────────────────────────────────────────────────────────

  final musicList = <MusicModel>[].obs;
  final isLoading = false.obs;

  /// Index qui ont déjà déclenché un fetch topline (évite les doublons).
  final _fetchedIndices = <int>{};

  // ─── PageView ────────────────────────────────────────────────────────────────

  late final PageController pageController;
  int _currentIndex = 0;

  // ─── Audio ───────────────────────────────────────────────────────────────────

  final _audio = AudioService.to;
  StreamSubscription? _completeSub;

  // ─── Init / Close ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _fetchFeed();
  }

  @override
  void onClose() {
    _completeSub?.cancel();
    pageController.dispose();
    _audio.stop(AudioType.music);
    super.onClose();
  }

  // ─── Fetch ───────────────────────────────────────────────────────────────────

  Future<void> _fetchFeed() async {
    isLoading.value = true;
    final response = await Get.find<MusicApi>().getFeed();
    isLoading.value = false;
    if (response.isSuccess && (response.data?.isNotEmpty ?? false)) {
      musicList.assignAll(response.data!);
      _playIndex(0);
    }
  }

  // ─── Lecture ─────────────────────────────────────────────────────────────────

  void _playIndex(int index) {
    _currentIndex = index;
    _completeSub?.cancel();
    final music = musicList[index];
    final url = _resolveUrl(music.audioFile);
    _audio.play(AudioType.music, url);
    _completeSub = _audio.onComplete(AudioType.music).listen((_) => _onTrackComplete());
  }

  /// Construit l'URL complète si audioFile est un chemin relatif serveur.
  String _resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) {
      return audioFile;
    }
    final base = ApiConfiguration.baseUrl;
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '$base$path';
  }

  void _onTrackComplete() {
    final nextIndex = _currentIndex + 1;
    if (nextIndex < musicList.length) {
      pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _playIndex(nextIndex);
    }
  }

  /// Appelé par PageView.builder lors d'un swipe.
  void onPageChanged(int index) {
    final isForward = index > _currentIndex;
    if (index != _currentIndex) {
      _playIndex(index);
    }
    if (isForward && !_fetchedIndices.contains(index)) {
      _fetchedIndices.add(index);
      _fetchToplineOne();
    }
  }

  Future<void> _fetchToplineOne() async {
    final response = await Get.find<MusicApi>().getToplineFeedOne();
    if (response.isSuccess && response.data != null) {
      musicList.add(response.data!);
    }
  }

  // ─── Play / Pause ────────────────────────────────────────────────────────────

  void togglePlay() {
    if (_audio.isPlayingRx(AudioType.music).value) {
      _audio.pause(AudioType.music);
    } else {
      _audio.resume(AudioType.music);
    }
  }
}
