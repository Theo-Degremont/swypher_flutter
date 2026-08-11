import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

/// Volume de la topline de référence pendant l'enregistrement.
///
/// Avec écouteurs : plein volume (l'utilisateur entend dans les oreilles, pas de bleeding).
/// Sans écouteurs : très bas pour minimiser le bleeding capté par le micro.
const double kToplineVolumeWithHeadphones    = 1.0;
const double kToplineVolumeWithoutHeadphones = 0.15;

class HeadphoneService extends GetxService {
  /// true si des écouteurs avec micro sont détectés comme input disponible.
  final isHeadphoneConnected = false.obs;

  late final AudioSession _session;

  // ─── Initialisation globale ───────────────────────────────────────────────────

  static Future<HeadphoneService> initialize() async {
    final service = HeadphoneService();
    Get.put(service);
    await service._init();
    return service;
  }

  Future<void> _init() async {
    _session = await AudioSession.instance;
    await _refreshHeadphoneState();

    // Écoute la déconnexion des écouteurs (headphones unplugged / BT disconnect).
    // Le package `record` gère lui-même la session audio lors de l'enregistrement.
    _session.becomingNoisyEventStream.listen((_) {
      isHeadphoneConnected.value = false;
    });
  }

  // ─── Détection des écouteurs ──────────────────────────────────────────────────

  /// Liste les inputs disponibles via le package `record`.
  /// Si plus d'un input est détecté → des écouteurs avec micro sont connectés.
  Future<void> _refreshHeadphoneState() async {
    try {
      final temp = AudioRecorder();
      final devices = await temp.listInputDevices();
      await temp.dispose();
      isHeadphoneConnected.value = devices.length > 1;
    } catch (_) {
      isHeadphoneConnected.value = false;
    }
  }

  /// À appeler juste avant de lancer un enregistrement pour avoir l'état frais.
  Future<void> refresh() => _refreshHeadphoneState();

  // ─── Volume de la topline ────────────────────────────────────────────────────

  /// Retourne le volume approprié pour la topline de référence pendant
  /// l'enregistrement, selon l'état des écouteurs.
  double get toplineVolume => isHeadphoneConnected.value
      ? kToplineVolumeWithHeadphones
      : kToplineVolumeWithoutHeadphones;

  // ─── Sélection du micro intégré ───────────────────────────────────────────────

  /// Tente de trouver et retourner le micro intégré du téléphone parmi les
  /// inputs disponibles, pour l'utiliser en priorité même quand des écouteurs
  /// avec micro sont connectés.
  ///
  /// Retourne [null] si non trouvé — le package `record` utilisera le défaut.
  Future<InputDevice?> findBuiltInMic() async {
    try {
      final temp = AudioRecorder();
      final devices = await temp.listInputDevices();
      await temp.dispose();

      if (devices.isEmpty) return null;
      // Un seul input → forcément le micro intégré.
      if (devices.length == 1) return devices.first;

      // Recherche par ID ou label — patterns courants iOS / Android.
      return devices.firstWhereOrNull((d) {
            final id    = d.id.toLowerCase();
            final label = d.label.toLowerCase();
            return id.contains('builtin')   ||
                   id.contains('built_in')  ||
                   id.contains('built-in')  ||
                   id.contains('internal')  ||
                   label.contains('built-in')    ||
                   label.contains('iphone mic')  ||
                   label.contains('ipad mic')    ||
                   label.contains('intégré')     ||
                   label.contains('internal');
          }) ??
          // Fallback : premier device non-headphone non-bluetooth.
          devices.firstWhereOrNull((d) {
            final label = d.label.toLowerCase();
            return !label.contains('headphone') &&
                   !label.contains('headset')   &&
                   !label.contains('bluetooth') &&
                   !label.contains('airpod')    &&
                   !label.contains('earphone')  &&
                   !label.contains('écouteur');
          });
    } catch (_) {
      return null;
    }
  }
}
