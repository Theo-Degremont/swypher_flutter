import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/home/services/home_service.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';

class HomeController extends GetxController {
  late final HomeService _service;

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

  bool _toplineFeedFetched = false;
  final _musicFetchedIndices   = <int>{};
  final _toplineFetchedIndices = <int>{};

  // ─── Audio ───────────────────────────────────────────────────────────────────

  final _audio = AudioService.to;

  // ─── Init / Close ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _service              = Get.find<HomeService>();
    musicPageController   = PageController();
    toplinePageController = PageController();
    _fetchMusicFeed();
  }

  @override
  void onClose() {
    musicPageController.dispose();
    toplinePageController.dispose();
    super.onClose();
  }

  // ─── Sélection d'onglet ──────────────────────────────────────────────────────

  void selectTab(int tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;

    if (tab == 1) {
      if (!_toplineFeedFetched) {
        _fetchToplineFeed();
      } else if (toplineList.isNotEmpty) {
        _playToplineAt(_toplineIndex);
      }
    } else {
      if (musicList.isNotEmpty) {
        _playMusicAt(_musicIndex);
      }
    }
  }

  // ─── Fetch feed complet ──────────────────────────────────────────────────────

  Future<void> _fetchMusicFeed() async {
    isLoading.value = true;
    final results = await _service.fetchMusicFeed();
    isLoading.value = false;
    if (results.isNotEmpty) {
      musicList.assignAll(results);
      _playMusicAt(0);
    }
  }

  Future<void> _fetchToplineFeed() async {
    isLoading.value = true;
    final results = await _service.fetchToplineFeed();
    isLoading.value = false;
    _toplineFeedFetched = true;
    if (results.isNotEmpty) {
      toplineList.assignAll(results);
      _playToplineAt(0);
    }
  }

  // ─── Fetch +1 au swipe bas ───────────────────────────────────────────────────

  Future<void> _fetchMusicOne() async {
    final music = await _service.fetchMusicOne();
    if (music != null) musicList.add(music);
  }

  Future<void> _fetchToplineOne() async {
    final music = await _service.fetchToplineOne();
    if (music != null) toplineList.add(music);
  }

  // ─── Lecture ─────────────────────────────────────────────────────────────────

  void _playMusicAt(int index) {
    _musicIndex = index;
    final music = musicList[index];
    _audio.setQueue(musicList.toList(), index);
    _audio
        .play(AudioType.music, _service.resolveUrl(music.audioFile))
        .catchError((_) => _onTrackComplete());
    _audio.setCurrentMusic(music, _service.resolveCoverUrl(music.coverImage));
    _audio.listenToMusicComplete(_onTrackComplete);
  }

  void _playToplineAt(int index) {
    _toplineIndex = index;
    final music = toplineList[index];
    _audio.setQueue(toplineList.toList(), index);
    _audio
        .play(AudioType.music, _service.resolveUrl(music.audioFile))
        .catchError((_) => _onTrackComplete());
    _audio.setCurrentMusic(music, _service.resolveCoverUrl(music.coverImage));
    _audio.listenToMusicComplete(_onTrackComplete);
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
      } else {
        _audio.clearCurrentMusic();
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
      } else {
        _audio.clearCurrentMusic();
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
}
