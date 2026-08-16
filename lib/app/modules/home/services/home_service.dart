import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';

class HomeService extends GetxService {
  final MusicApi _musicApi = Get.find<MusicApi>();

  Future<List<MusicModel>> fetchMusicFeed() async {
    final response = await _musicApi.getFeed();
    if (response.isSuccess) return response.data ?? [];
    return [];
  }

  Future<List<MusicModel>> fetchToplineFeed() async {
    final response = await _musicApi.getToplineFeed();
    if (response.isSuccess) return response.data ?? [];
    return [];
  }

  Future<MusicModel?> fetchMusicOne() async {
    final response = await _musicApi.getMusicFeedOne();
    if (response.isSuccess) return response.data;
    return null;
  }

  Future<MusicModel?> fetchToplineOne() async {
    final response = await _musicApi.getToplineFeedOne();
    if (response.isSuccess) return response.data;
    return null;
  }

  String resolveUrl(String audioFile) {
    if (audioFile.startsWith('http://') || audioFile.startsWith('https://')) return audioFile;
    final path = audioFile.startsWith('/') ? audioFile : '/$audioFile';
    return '${ApiConfiguration.baseUrl}$path';
  }

  String? resolveCoverUrl(String? coverImage) {
    if (coverImage == null) return null;
    if (coverImage.startsWith('http://') || coverImage.startsWith('https://')) return coverImage;
    final path = coverImage.startsWith('/') ? coverImage : '/$coverImage';
    return '${ApiConfiguration.baseUrl}$path';
  }
}
