import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:swypher_flutter/shared/data/network/api_client.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';
import 'package:swypher_flutter/shared/services/audio_service.dart';
import 'package:swypher_flutter/shared/services/headphone_service.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

Future<void> configureApp() async {

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await GetStorage.init();
  await MemoryService.instance.ensureInitialized();
  Get.put(MemoryService.instance);
  Get.put(ApiClient());
  Get.put(AuthApi());
  Get.put(MusicApi());
  await AudioService.initialize();
  await HeadphoneService.initialize();

  final supportedLanguages = ['en', 'fr'];

  if (MemoryService.instance.languageCode == null) {
    final deviceLanguage = Get.deviceLocale?.languageCode ?? 'en';
    if (supportedLanguages.contains(deviceLanguage)) {
      MemoryService.instance.languageCode = deviceLanguage;
    } else {
      MemoryService.instance.languageCode = 'en';
    }
  }

  // ─── Sync likes / dislikes en attente ────────────────────────────────────────
  // On n'envoie les calls que si l'utilisateur est connecté
  final memory   = MemoryService.instance;
  final musicApi = Get.find<MusicApi>();

  if (memory.access != null) {
    if (memory.musicLiked.isNotEmpty) {
      final res = await musicApi.postLike(memory.musicLiked);
      if (res.isSuccess) memory.clearLiked();
    }
    if (memory.musicDisliked.isNotEmpty) {
      final res = await musicApi.deleteLike(memory.musicDisliked);
      if (res.isSuccess) memory.clearDisliked();
    }
  }
}