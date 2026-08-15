import 'dart:async';

import 'package:get/get.dart';
import 'package:swypher_flutter/app/modules/profile/services/profile_service.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class ProfileController extends GetxController {
  late final ProfileService _service;
  final _audio  = AudioService.to;
  final _memory = MemoryService.instance;

  final selectedTab = 0.obs;
  final isLoading   = false.obs;

  final publishedMusics = <MusicModel>[].obs;
  final prodMusics      = <MusicModel>[].obs;
  final repostMusics    = <MusicModel>[].obs;
  final draftMusics     = <MusicModel>[].obs;

  final currentIndex = (-1).obs;
  StreamSubscription? _completeSub;

  bool _musicsFetched   = false;
  bool _toplinesFetched = false;
  bool _repostsFetched  = false;

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ProfileService>();
    if (_memory.access == null) return;
    _initProfile();
  }

  Future<void> _initProfile() async {
    isLoading.value = true;

    final user = await _service.fetchCurrentUser();
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _userId = user.id;
    await _loadMusics();

    isLoading.value = false;
  }

  Future<void> _loadMusics() async {
    if (_musicsFetched || _userId == null) return;
    _musicsFetched = true;

    final result = await _service.fetchUserMusics(_userId!);
    publishedMusics.assignAll(result.published);
    draftMusics.assignAll(result.drafts);
  }

  Future<void> _loadToplines() async {
    if (_toplinesFetched || _userId == null) return;
    _toplinesFetched = true;
    isLoading.value = true;

    final result = await _service.fetchUserToplines(_userId!);
    isLoading.value = false;

    prodMusics.assignAll(result.published);
    draftMusics.addAll(result.drafts);
  }

  Future<void> _loadReposts() async {
    if (_repostsFetched || _userId == null) return;
    _repostsFetched = true;
    isLoading.value = true;

    final musics = await _service.fetchUserReposts(_userId!);
    isLoading.value = false;

    repostMusics.assignAll(musics);
  }

  Future<void> selectTab(int tab) async {
    selectedTab.value = tab;
    currentIndex.value = -1;
    _completeSub?.cancel();
    _audio.stop(AudioType.music);

    switch (tab) {
      case 1:
        await _loadToplines();
      case 2:
        await _loadReposts();
      case 3:
        await _loadMusics();
        await _loadToplines();
      default:
        break;
    }
  }

  List<MusicModel> get activeList {
    switch (selectedTab.value) {
      case 0: return publishedMusics;
      case 1: return prodMusics;
      case 2: return repostMusics;
      case 3: return draftMusics;
      default: return [];
    }
  }

  void playAt(int index) {
    final list = activeList;
    if (index < 0 || index >= list.length) return;
    currentIndex.value = index;
    _completeSub?.cancel();
    _audio.play(AudioType.music, _resolveUrl(list[index].audioFile));
    _completeSub = _audio.onComplete(AudioType.music).listen((_) {
      final next = currentIndex.value + 1;
      if (next < activeList.length) {
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
      } else if (activeList.isNotEmpty) {
        playAt(0);
      }
    }
  }

  void stopMusic() {
    _completeSub?.cancel();
    _audio.stop(AudioType.music);
    currentIndex.value = -1;
  }

  Future<void> deleteMusic(MusicModel music) async {
    final success = await _service.deleteMusic(music.id);
    if (!success) return;
    publishedMusics.remove(music);
    prodMusics.remove(music);
    draftMusics.remove(music);
    if (currentIndex.value >= activeList.length) {
      currentIndex.value = activeList.isEmpty ? -1 : activeList.length - 1;
    }
  }

  void resetData() {
    stopMusic();
    _musicsFetched    = false;
    _toplinesFetched  = false;
    _repostsFetched   = false;
    _userId           = null;
    selectedTab.value = 0;
    publishedMusics.clear();
    prodMusics.clear();
    repostMusics.clear();
    draftMusics.clear();
    _initProfile();
  }

  String? resolveCoverUrl(String? coverImage) {
    if (coverImage == null) return null;
    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
      return coverImage;
    }
    return '${ApiConfiguration.baseUrl}$coverImage';
  }

  String? resolveAvatarUrl(String? profilePicture) => resolveCoverUrl(profilePicture);

  String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  MemoryService get memory => _memory;

  String _resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) {
      return audioFile;
    }
    final base = ApiConfiguration.baseUrl;
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '$base$path';
  }

  @override
  void onClose() {
    _completeSub?.cancel();
    _audio.stop(AudioType.music);
    super.onClose();
  }
}
