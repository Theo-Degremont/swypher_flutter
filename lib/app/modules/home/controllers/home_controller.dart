import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class HomeController extends GetxController {
  // ─── Tab ─────────────────────────────────────────────────────────────────────

  final selectedTab = 0.obs;

  // ─── Listes ──────────────────────────────────────────────────────────────────

  final musicList   = <MusicModel>[].obs;
  final toplineList = <MusicModel>[].obs;
  final isLoading   = false.obs;

  // ─── PageControllers ─────────────────────────────────────────────────────────

  late final PageController musicPageController;
  late final PageController toplinePageController;
  int _musicIndex   = 0;
  int _toplineIndex = 0;

  // ─── Fetch tracking ──────────────────────────────────────────────────────────

  /// true dès que le feed topline a été chargé (évite un re-fetch au retour).
  bool _toplineFeedFetched = false;
  final _musicFetchedIndices   = <int>{};
  final _toplineFetchedIndices = <int>{};

  // ─── Audio ───────────────────────────────────────────────────────────────────

  final _audio = AudioService.to;
  StreamSubscription? _completeSub;

  // ─── Init / Close ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    musicPageController   = PageController();
    toplinePageController = PageController();
    _fetchMusicFeed();
  }

  @override
  void onClose() {
    _completeSub?.cancel();
    musicPageController.dispose();
    toplinePageController.dispose();
    _audio.stop(AudioType.music);
    super.onClose();
  }

  // ─── Sélection d'onglet ──────────────────────────────────────────────────────

  void selectTab(int tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;

    if (tab == 1) {
      // → Toplines : fetch si jamais fait, sinon reprend la lecture courante.
      if (!_toplineFeedFetched) {
        _fetchToplineFeed();
      } else if (toplineList.isNotEmpty) {
        _playToplineAt(_toplineIndex);
      }
    } else {
      // → Musiques : reprend sans re-fetch.
      if (musicList.isNotEmpty) {
        _playMusicAt(_musicIndex);
      }
    }
  }

  // ─── Fetch feed complet ──────────────────────────────────────────────────────

  Future<void> _fetchMusicFeed() async {
    isLoading.value = true;
    final response = await Get.find<MusicApi>().getFeed();
    isLoading.value = false;
    if (response.isSuccess && (response.data?.isNotEmpty ?? false)) {
      musicList.assignAll(response.data!);
      _playMusicAt(0);
    }
  }

  Future<void> _fetchToplineFeed() async {
    isLoading.value = true;
    final response = await Get.find<MusicApi>().getToplineFeed();
    isLoading.value = false;
    _toplineFeedFetched = true;
    if (response.isSuccess && (response.data?.isNotEmpty ?? false)) {
      toplineList.assignAll(response.data!);
      _playToplineAt(0);
    }
  }

  // ─── Fetch +1 au swipe bas ───────────────────────────────────────────────────

  Future<void> _fetchMusicOne() async {
    final response = await Get.find<MusicApi>().getMusicFeedOne();
    if (response.isSuccess && response.data != null) musicList.add(response.data!);
  }

  Future<void> _fetchToplineOne() async {
    final response = await Get.find<MusicApi>().getToplineFeedOne();
    if (response.isSuccess && response.data != null) toplineList.add(response.data!);
  }

  // ─── Lecture ─────────────────────────────────────────────────────────────────

  void _playMusicAt(int index) {
    _musicIndex = index;
    _completeSub?.cancel();
    _audio.play(AudioType.music, _resolveUrl(musicList[index].audioFile));
    _completeSub = _audio.onComplete(AudioType.music).listen((_) => _onTrackComplete());
  }

  void _playToplineAt(int index) {
    _toplineIndex = index;
    _completeSub?.cancel();
    _audio.play(AudioType.music, _resolveUrl(toplineList[index].audioFile));
    _completeSub = _audio.onComplete(AudioType.music).listen((_) => _onTrackComplete());
  }

  void _onTrackComplete() {
    if (selectedTab.value == 0) {
      final next = _musicIndex + 1;
      if (next < musicList.length) {
        musicPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _playMusicAt(next);
      }
    } else {
      final next = _toplineIndex + 1;
      if (next < toplineList.length) {
        toplinePageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _playToplineAt(next);
      }
    }
  }

  // ─── Page changed ────────────────────────────────────────────────────────────

  void onMusicPageChanged(int index) {
    final isForward = index > _musicIndex;
    if (index != _musicIndex) _playMusicAt(index);
    if (isForward && !_musicFetchedIndices.contains(index)) {
      _musicFetchedIndices.add(index);
      _fetchMusicOne();
    }
  }

  void onToplinePageChanged(int index) {
    final isForward = index > _toplineIndex;
    if (index != _toplineIndex) _playToplineAt(index);
    if (isForward && !_toplineFetchedIndices.contains(index)) {
      _toplineFetchedIndices.add(index);
      _fetchToplineOne();
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

  void pauseMusic() => _audio.pause(AudioType.music);

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) return audioFile;
    final base = ApiConfiguration.baseUrl;
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '$base$path';
  }
}
