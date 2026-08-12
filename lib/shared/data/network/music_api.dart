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

  /// Récupère le feed de musiques (GET /music/feed).
  Future<ApiResponse<List<MusicModel>>> getFeed() => _client.get<List<MusicModel>>(
        ApiConfiguration.musicFeed,
        requiresAuth: true,
        fromData: (data) => (data as List)
            .map((e) => MusicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Récupère une musique du feed (GET /music/feed/one).
  Future<ApiResponse<MusicModel>> getMusicFeedOne() => _client.get<MusicModel>(
        ApiConfiguration.musicFeedOne,
        requiresAuth: true,
        fromData: (data) => MusicModel.fromJson(data as Map<String, dynamic>),
      );

  /// Récupère le feed de toplines (GET /music/topline/feed).
  Future<ApiResponse<List<MusicModel>>> getToplineFeed() => _client.get<List<MusicModel>>(
        ApiConfiguration.toplineFeed,
        requiresAuth: true,
        fromData: (data) => (data as List)
            .map((e) => MusicModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Récupère une topline du feed (GET /music/topline/feed/one).
  Future<ApiResponse<MusicModel>> getToplineFeedOne() => _client.get<MusicModel>(
        ApiConfiguration.toplineFeedOne,
        requiresAuth: true,
        fromData: (data) => MusicModel.fromJson(data as Map<String, dynamic>),
      );

  /// Like une liste de musiques (POST /music/like).
  Future<ApiResponse<void>> postLike(List<String> musicIds) =>
      _client.post<void>(
        ApiConfiguration.musicLike,
        requiresAuth: true,
        body: {'musicIds': musicIds},
      );

  /// Unlike une liste de musiques (DELETE /music/like).
  Future<ApiResponse<void>> deleteLike(List<String> musicIds) =>
      _client.deleteWithBody<void>(
        ApiConfiguration.musicLike,
        requiresAuth: true,
        body: {'musicIds': musicIds},
      );

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
