import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:swypher_flutter/app/modules/main/controllers/main_controller.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/constants/color.dart';

class RecordMusicController extends GetxController {
  late final MainController mainController;

  // ─── Fichiers ────────────────────────────────────────────────────────────────
  final Rx<PlatformFile?> toplineFile   = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> recordedVoice = Rx<PlatformFile?>(null);

  // ─── État enregistrement ──────────────────────────────────────────────────────
  final isRecording = false.obs;

  /// Barres accumulées du visualiseur (persist entre pause et reprise).
  final bars = RxList<double>([]);

  // ─── Internes ─────────────────────────────────────────────────────────────────
  late final AudioRecorder _recorder;
  StreamSubscription<Amplitude>? _amplitudeSub;

  /// Segments audio enregistrés (chaque appui pause → reprise crée un nouveau segment).
  final List<String> _segments = [];

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
    _recorder = AudioRecorder();
  }

  // ─── Topline ──────────────────────────────────────────────────────────────────

  Future<void> pickToplineFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'webm'],
    );
    if (result != null) toplineFile.value = result.files.single;
  }

  void removeToplineFile() => toplineFile.value = null;

  // ─── Enregistrement ───────────────────────────────────────────────────────────

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showError('Autorisez l\'accès au microphone pour enregistrer.');
      return;
    }

    final path =
        '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    // Amplitude : dBFS de -60 à 0 → normalisé 0.0 à 1.0
    // Les barres s'accumulent dans `bars` et persistent entre les pauses.
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      bars.add(normalized);
      if (bars.length > 500) bars.removeAt(0);
    });

    isRecording.value = true;
  }

  Future<void> _stopRecording() async {
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    final path = await _recorder.stop();
    isRecording.value = false;

    if (path != null) {
      _segments.add(path);
      // recordedVoice pointe toujours sur le dernier segment enregistré.
      final file = File(path);
      recordedVoice.value = PlatformFile(
        path: path,
        name: 'voice_record.m4a',
        size: await file.length(),
      );
    }
  }

  void deleteRecording() {
    recordedVoice.value = null;
    bars.clear();
    _segments.clear();
  }

  // ─── Navigation ───────────────────────────────────────────────────────────────

  void goToCompleteMusic() {
    Get.toNamed(
      Routes.COMPLETE_MUSIC,
      arguments: {
        'toplineFile': toplineFile.value,
        'voiceFile': recordedVoice.value,
      },
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  void _showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.backgroundColor,
      colorText: AppColors.primaryTextColor,
      borderColor: AppColors.primaryColor.withValues(alpha: 0.4),
      borderWidth: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() async {
    await _amplitudeSub?.cancel();
    await _recorder.dispose();
    super.onClose();
  }
}
