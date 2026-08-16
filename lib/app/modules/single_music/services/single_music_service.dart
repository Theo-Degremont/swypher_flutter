import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';

class SingleMusicService extends GetxService {
  String resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) {
      return audioFile;
    }
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '${ApiConfiguration.baseUrl}$path';
  }

  String? resolveCoverUrl(String? coverImage) {
    if (coverImage == null) return null;
    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) {
      return coverImage;
    }
    final path = coverImage.startsWith('/') ? coverImage : '/$coverImage';
    return '${ApiConfiguration.baseUrl}$path';
  }
}
