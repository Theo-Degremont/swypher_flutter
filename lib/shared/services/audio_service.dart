import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

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
///
/// Trois types de pistes indépendantes : [AudioType.voice], [AudioType.music],
/// [AudioType.topline]. Chaque piste a son propre player, volume et état réactif.
class AudioService extends GetxService {

  static AudioService get to => Get.find<AudioService>();

  /// Appelé dans [configureApp] pour initialiser le service.
  static Future<AudioService> initialize() async {
    return Get.put(AudioService());
  }

  // ─── Pistes ─────────────────────────────────────────────────────────────────

  late final Map<AudioType, _AudioTrack> _tracks;

  @override
  void onInit() {
    super.onInit();
    _tracks = {
      AudioType.voice:   _AudioTrack(),
      AudioType.music:   _AudioTrack(),
      AudioType.topline: _AudioTrack(),
      AudioType.record:  _AudioTrack(),
    };
  }

  // ─── Play ────────────────────────────────────────────────────────────────────

  /// Lance la lecture d'une [source] (chemin local ou URL) pour le [type] donné.
  ///
  /// [exclusive] : met en pause les autres pistes avant de démarrer.
  /// [volume]    : volume initial (0.0 → 1.0), par défaut la valeur courante.
  Future<void> play(
    AudioType type,
    String source, {
    bool exclusive = false,
    double? volume,
  }) async {
    if (exclusive) await _pauseOthers(type);

    final track = _tracks[type]!;

    // Calcule le volume cible : paramètre explicite ou valeur courante de la piste.
    final targetVolume = volume != null
        ? volume.clamp(0.0, 1.0)
        : track.volume.value;

    if (volume != null) track.volume.value = targetVolume;

    track.source = source;
    track.savedPosition = Duration.zero;

    final src = _toSource(source);
    // Passe le volume directement à play() — plus fiable que setVolume() + play()
    // car audioplayers peut réinitialiser son état interne lors du chargement.
    await track.player.play(src, volume: targetVolume);
  }

  // ─── Pause ───────────────────────────────────────────────────────────────────

  /// Met en pause la piste [type]. La position est automatiquement sauvegardée.
  Future<void> pause(AudioType type) async {
    await _tracks[type]!.player.pause();
  }

  // ─── Resume ──────────────────────────────────────────────────────────────────

  /// Reprend la piste [type] exactement là où elle s'était arrêtée.
  Future<void> resume(AudioType type) async {
    final track = _tracks[type]!;
    if (track.source == null) return;
    await track.player.resume();
  }

  // ─── Restart ─────────────────────────────────────────────────────────────────

  /// Repart depuis le début de la piste [type] sans changer la source.
  Future<void> restart(AudioType type) async {
    final track = _tracks[type]!;
    if (track.source == null) return;
    track.savedPosition = Duration.zero;
    await track.player.seek(Duration.zero);
    await track.player.resume();
  }

  // ─── Stop ────────────────────────────────────────────────────────────────────

  /// Stoppe la piste [type] et réinitialise sa position à zéro.
  Future<void> stop(AudioType type) async {
    final track = _tracks[type]!;
    track.savedPosition = Duration.zero;
    await track.player.stop();
  }

  /// Stoppe toutes les pistes sauf [except].
  Future<void> stopOthers(AudioType except) async {
    for (final entry in _tracks.entries) {
      if (entry.key != except) await stop(entry.key);
    }
  }

  /// Stoppe toutes les pistes.
  Future<void> stopAll() async {
    for (final type in _tracks.keys) {
      await stop(type);
    }
  }

  // ─── Volume ──────────────────────────────────────────────────────────────────

  /// Définit le volume de la piste [type] (0.0 → 1.0).
  Future<void> setVolume(AudioType type, double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    final track = _tracks[type]!;
    await track.player.setVolume(clamped);
    track.volume.value = clamped;
  }

  // ─── État réactif ────────────────────────────────────────────────────────────

  /// Indique si la piste [type] est en cours de lecture.
  RxBool isPlayingRx(AudioType type) => _tracks[type]!.isPlaying;

  /// Position courante de la piste [type].
  Rx<Duration> positionRx(AudioType type) => _tracks[type]!.position;

  /// Durée totale de la piste [type] (disponible après chargement).
  Rx<Duration> durationRx(AudioType type) => _tracks[type]!.duration;

  /// Volume réactif de la piste [type].
  RxDouble volumeRx(AudioType type) => _tracks[type]!.volume;

  /// Source actuellement chargée pour [type], ou null si aucune.
  String? currentSource(AudioType type) => _tracks[type]!.source;

  /// Vrai si au moins une piste est en lecture.
  bool get isAnyPlaying =>
      _tracks.values.any((t) => t.isPlaying.value);

  // ─── Seek ────────────────────────────────────────────────────────────────────

  /// Déplace la lecture de la piste [type] à la position [position].
  Future<void> seek(AudioType type, Duration position) async {
    await _tracks[type]!.player.seek(position);
  }

  // ─── Préchargement ───────────────────────────────────────────────────────────

  /// Charge la source sans démarrer la lecture (utile pour récupérer la durée).
  Future<void> preload(AudioType type, String source) async {
    final track = _tracks[type]!;
    track.source = source;
    await track.player.setSource(_toSource(source));
  }

  // ─── Événement de fin ────────────────────────────────────────────────────────

  /// Stream émis quand la piste [type] se termine naturellement.
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
    for (final track in _tracks.values) {
      await track.dispose();
    }
    super.onClose();
  }
}
