import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/search/services/search_service.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class SearchController extends GetxController {
  late final SearchService _service;
  final _audio  = AudioService.to;
  final _memory = MemoryService.instance;

  late final TextEditingController searchCtrl;
  late final FocusNode            searchFocus;
  late final ValueNotifier<bool>  searchFocused;

  final query          = ''.obs;
  final musicResults   = <MusicModel>[].obs;
  final toplineResults = <MusicModel>[].obs;
  final selectedTab    = 0.obs;
  final currentIndex   = (-1).obs;
  final isLoading      = false.obs;
  final hasSearched    = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<SearchService>();

    searchCtrl    = TextEditingController();
    searchFocus   = FocusNode();
    searchFocused = ValueNotifier(false);

    searchFocus.addListener(
      () => searchFocused.value = searchFocus.hasFocus,
    );
    searchCtrl.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchCtrl
      ..removeListener(_onTextChanged)
      ..dispose();
    searchFocus.dispose();
    searchFocused.dispose();
    super.onClose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final q = searchCtrl.text.trim();
    query.value = q;

    if (q.isEmpty) {
      musicResults.clear();
      toplineResults.clear();
      hasSearched.value = false;
      currentIndex.value = -1;
      return;
    }

    _debounce = Timer(const Duration(seconds: 2), () => _doSearch(q));
  }

  Future<void> _doSearch(String q) async {
    isLoading.value = true;
    final res = await _service.search(q);
    isLoading.value = false;
    hasSearched.value = true;
    currentIndex.value = -1;

    if (res.isSuccess && res.data != null) {
      final all = res.data!.musics;
      musicResults.assignAll(
        all.where((m) => m.type != 'topline').toList(),
      );
      toplineResults.assignAll(
        all.where((m) => m.type == 'topline').toList(),
      );
      if (musicResults.isEmpty && toplineResults.isNotEmpty) {
        selectedTab.value = 1;
      } else {
        selectedTab.value = 0;
      }
    } else {
      musicResults.clear();
      toplineResults.clear();
      selectedTab.value = 0;
    }
  }

  void selectTab(int tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
    currentIndex.value = -1;
  }

  List<MusicModel> get _activeList =>
      selectedTab.value == 0 ? musicResults : toplineResults;

  void playAt(int index) {
    final list = _activeList;
    if (index < 0 || index >= list.length) return;

    currentIndex.value = index;
    final music = list[index];

    _memory.addSearchHistory(music.title);

    _audio.play(AudioType.music, _resolveUrl(music.audioFile));
    _audio.setCurrentMusic(music, _resolveCoverUrl(music.coverImage));
    _audio.listenToMusicComplete(() {
      final next = currentIndex.value + 1;
      if (next < _activeList.length) {
        playAt(next);
      } else {
        currentIndex.value = -1;
        _audio.clearCurrentMusic();
      }
    });
  }

  String formatDuration(int? seconds) => AudioService.formatDuration(seconds);

  String _resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) {
      return audioFile;
    }
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '${ApiConfiguration.baseUrl}$path';
  }

  String? _resolveCoverUrl(String? coverImage) {
    if (coverImage == null) return null;
    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
      return coverImage;
    }
    final path = coverImage.startsWith('/') ? coverImage : '/$coverImage';
    return '${ApiConfiguration.baseUrl}$path';
  }

  void removeHistoryEntry(String title) => _memory.removeSearchHistoryEntry(title);

  void clearAllHistory() => _memory.clearSearchHistory();

  MemoryService get memory => _memory;
}
