import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory, AVAudioSessionOptions;
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';

// ─── Type d'audio ─────────────────────────────────────────────────────────────

enum AudioType { voice, music, topline, record}

// ─── Piste interne ────────────────────────────────────────────────────────────

class _AudioTrack {
  _AudioTrack() : player = AudioPlayer() {
    _bindListeners();
  }

  final AudioPlayer player;

  String? source;
  Duration savedPosition = Duration.zero;

  final isPlaying = false.obs;
  final position  = Duration.zero.obs;
  final duration  = Duration.zero.obs;
  final volume    = 1.0.obs;

  StreamSubscription? _stateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  void _bindListeners() {
    _stateSub = player.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
    _posSub = player.onPositionChanged.listen((pos) {
      position.value = pos;
      savedPosition = pos;
    });
    _durSub = player.onDurationChanged.listen((dur) {
      duration.value = dur;
    });
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _posSub?.cancel();
    await _durSub?.cancel();
    await player.dispose();
  }
}

// ─── AudioService ─────────────────────────────────────────────────────────────

/// Service audio global, disponible partout via [AudioService.to].
class AudioService extends GetxService {

  static AudioService get to => Get.find<AudioService>();

  static Future<AudioService> initialize() async {
    return Get.put(AudioService());
  }

  // ─── Pistes ─────────────────────────────────────────────────────────────────

  late final Map<AudioType, _AudioTrack> _tracks;

  // ─── Musique en cours (état global partagé entre les pages) ─────────────────

  final currentMusicObs    = Rx<MusicModel?>(null);
  final currentCoverUrlObs = Rx<String?>(null);

  /// Abonnement unique à la fin de piste music — remplace tout précédent.
  StreamSubscription<void>? _musicCompleteSub;

  @override
  void onInit() {
    super.onInit();
    _tracks = {
      AudioType.voice:   _AudioTrack(),
      AudioType.music:   _AudioTrack(),
      AudioType.topline: _AudioTrack(),
      AudioType.record:  _AudioTrack(),
    };
    _configureAudioSession();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  // ─── Now playing ─────────────────────────────────────────────────────────────

  final currentQueueObs      = <MusicModel>[].obs;
  final currentQueueIndexObs = (-1).obs;

  void setCurrentMusic(MusicModel music, String? coverUrl) {
    currentMusicObs.value    = music;
    currentCoverUrlObs.value = coverUrl;
  }

  void clearCurrentMusic() {
    currentMusicObs.value    = null;
    currentCoverUrlObs.value = null;
  }

  /// Définit la file de lecture courante (liste source + position).
  void setQueue(List<MusicModel> queue, int index) {
    currentQueueObs.assignAll(queue);
    currentQueueIndexObs.value = index;
  }

  /// Bascule play/pause sur la piste music sans changer de source.
  void toggleMusicPlay() {
    if (isPlayingRx(AudioType.music).value) {
      pause(AudioType.music);
    } else {
      resume(AudioType.music);
    }
  }

  // ─── Completion listener (unique, géré globalement) ──────────────────────────

  /// Remplace tout listener précédent par [callback] déclenché à la fin de piste.
  void listenToMusicComplete(void Function() callback) {
    _musicCompleteSub?.cancel();
    _musicCompleteSub = _tracks[AudioType.music]!.player.onPlayerComplete
        .listen((_) => callback());
  }

  void cancelMusicCompleteListener() {
    _musicCompleteSub?.cancel();
    _musicCompleteSub = null;
  }

  // ─── Utilitaire de durée ─────────────────────────────────────────────────────

  static String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // ─── Play ────────────────────────────────────────────────────────────────────

  Future<void> play(
    AudioType type,
    String source, {
    bool exclusive = false,
    double? volume,
  }) async {
    if (exclusive) await _pauseOthers(type);

    final track = _tracks[type]!;

    final targetVolume = volume != null
        ? volume.clamp(0.0, 1.0)
        : track.volume.value;

    if (volume != null) track.volume.value = targetVolume;

    track.source = source;
    track.savedPosition = Duration.zero;

    final src = _toSource(source);
    await track.player.stop();
    await track.player.play(src, volume: targetVolume);
  }

  // ─── Pause ───────────────────────────────────────────────────────────────────

  Future<void> pause(AudioType type) async {
    await _tracks[type]!.player.pause();
  }

  // ─── Resume ──────────────────────────────────────────────────────────────────

  Future<void> resume(AudioType type) async {
    final track = _tracks[type]!;
    if (track.source == null) return;
    await track.player.resume();
  }

  // ─── Restart ─────────────────────────────────────────────────────────────────

  Future<void> restart(AudioType type) async {
    final track = _tracks[type]!;
    if (track.source == null) return;
    track.savedPosition = Duration.zero;
    await track.player.seek(Duration.zero);
    await track.player.resume();
  }

  // ─── Stop ────────────────────────────────────────────────────────────────────

  Future<void> stop(AudioType type) async {
    final track = _tracks[type]!;
    track.savedPosition = Duration.zero;
    await track.player.stop();
  }

  Future<void> stopOthers(AudioType except) async {
    for (final entry in _tracks.entries) {
      if (entry.key != except) await stop(entry.key);
    }
  }

  Future<void> stopAll() async {
    for (final type in _tracks.keys) {
      await stop(type);
    }
  }

  // ─── Volume ──────────────────────────────────────────────────────────────────

  Future<void> setVolume(AudioType type, double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    final track = _tracks[type]!;
    await track.player.setVolume(clamped);
    track.volume.value = clamped;
  }

  // ─── État réactif ────────────────────────────────────────────────────────────

  RxBool isPlayingRx(AudioType type) => _tracks[type]!.isPlaying;
  Rx<Duration> positionRx(AudioType type) => _tracks[type]!.position;
  Rx<Duration> durationRx(AudioType type) => _tracks[type]!.duration;
  RxDouble volumeRx(AudioType type) => _tracks[type]!.volume;
  String? currentSource(AudioType type) => _tracks[type]!.source;
  bool get isAnyPlaying => _tracks.values.any((t) => t.isPlaying.value);

  // ─── Seek ────────────────────────────────────────────────────────────────────

  Future<void> seek(AudioType type, Duration position) async {
    await _tracks[type]!.player.seek(position);
  }

  // ─── Préchargement ───────────────────────────────────────────────────────────

  Future<void> preload(AudioType type, String source) async {
    final track = _tracks[type]!;
    track.source = source;
    await track.player.setSource(_toSource(source));
  }

  // ─── Événement de fin (stream brut, usage interne) ───────────────────────────

  Stream<void> onComplete(AudioType type) =>
      _tracks[type]!.player.onPlayerComplete;

  // ─── Privé ───────────────────────────────────────────────────────────────────

  Future<void> _pauseOthers(AudioType except) async {
    for (final entry in _tracks.entries) {
      if (entry.key != except && entry.value.isPlaying.value) {
        await entry.value.player.pause();
      }
    }
  }

  Source _toSource(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return UrlSource(src);
    }
    return DeviceFileSource(src);
  }

  @override
  void onClose() async {
    _musicCompleteSub?.cancel();
    for (final track in _tracks.values) {
      await track.dispose();
    }
    super.onClose();
  }
}
