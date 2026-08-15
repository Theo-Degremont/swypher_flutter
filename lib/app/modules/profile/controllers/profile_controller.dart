import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swypher_flutter/app/modules/profile/services/profile_service.dart';
import 'package:swypher_flutter/shared/constants/color.dart';
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

  // ─── Edit mode ───────────────────────────────────────────────────────────────
  final isEditMode       = false.obs;
  final isSaving         = false.obs;
  final pendingAvatarFile = Rx<File?>(null);

  late final TextEditingController stageNameCtrl;
  late final TextEditingController pseudoCtrl;
  late final TextEditingController descriptionCtrl;

  bool _musicsFetched   = false;
  bool _toplinesFetched = false;
  bool _repostsFetched  = false;

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ProfileService>();
    stageNameCtrl   = TextEditingController();
    pseudoCtrl      = TextEditingController();
    descriptionCtrl = TextEditingController();
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

  // ─── Edit mode ───────────────────────────────────────────────────────────────

  void enterEditMode() {
    final user = _memory.currentUser;
    stageNameCtrl.text   = user?.stageName ?? user?.pseudo ?? '';
    pseudoCtrl.text      = user?.pseudo ?? '';
    descriptionCtrl.text = user?.description ?? '';
    pendingAvatarFile.value = null;
    isEditMode.value = true;
  }

  void cancelEditMode() {
    isEditMode.value = false;
    pendingAvatarFile.value = null;
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) pendingAvatarFile.value = File(picked.path);
  }

  Future<void> confirmEdit() async {
    final pseudo      = pseudoCtrl.text.trim();
    final stageName   = stageNameCtrl.text.trim();
    final description = descriptionCtrl.text.trim();

    isSaving.value = true;
    final result = await _service.updateProfile(
      pseudo:      pseudo.isNotEmpty      ? pseudo      : null,
      stageName:   stageName.isNotEmpty   ? stageName   : null,
      description: description.isNotEmpty ? description : null,
    );
    isSaving.value = false;

    if (result.error != null) {
      Get.snackbar(
        'Erreur',
        result.error!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.backgroundColor,
        colorText: AppColors.primaryTextColor,
        borderColor: AppColors.primaryColor.withValues(alpha: 0.4),
        borderWidth: 1,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (pendingAvatarFile.value != null) {
      _memory.setLocalAvatarPath(pendingAvatarFile.value!.path);
    }
    isEditMode.value = false;
    pendingAvatarFile.value = null;
  }

  void playAt(int index) {
    if (isEditMode.value) cancelEditMode();
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
    cancelEditMode();
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
    stageNameCtrl.dispose();
    pseudoCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
