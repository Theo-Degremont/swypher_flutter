import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/api_response.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/api_client.dart';

class MusicApi extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  /// Crée une nouvelle musique (multipart/form-data).
  Future<ApiResponse<MusicModel>> postMusic({
    required String title,
    String status = 'draft',
    PlatformFile? topline,
    PlatformFile? voice,
    File? coverImage,
    double voiceVolume = 0.5,
    double musicVolume = 0.5,
  }) async {
    final fields = <String, dynamic>{
      'title': title,
      'status': status,
      'requestLanguage': 'fr',
      'voiceVolume': voiceVolume.toStringAsFixed(2),
      'musicVolume': musicVolume.toStringAsFixed(2),
    };

    if (topline?.path != null) {
      final bytes = await File(topline!.path!).readAsBytes();
      fields['topline'] = MultipartFile(
        bytes,
        filename: topline.name,
        contentType: _audioMimeType(topline.extension),
      );
    }

    if (voice?.path != null) {
      final bytes = await File(voice!.path!).readAsBytes();
      fields['voice'] = MultipartFile(
        bytes,
        filename: voice.name,
        contentType: _audioMimeType(voice.extension),
      );
    }

    if (coverImage != null) {
      final bytes = await coverImage.readAsBytes();
      final ext = coverImage.path.split('.').last.toLowerCase();
      fields['coverImage'] = MultipartFile(
        bytes,
        filename: coverImage.path.split('/').last,
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
      );
    }

    return _client.postMultipart<MusicModel>(
      ApiConfiguration.musicPath,
      formData: FormData(fields),
      fromData: (data) => MusicModel.fromJson(data as Map<String, dynamic>),
    );
  }

  String _audioMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'flac':
        return 'audio/flac';
      case 'ogg':
        return 'audio/ogg';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      default:
        return 'audio/mpeg';
    }
  }
}
