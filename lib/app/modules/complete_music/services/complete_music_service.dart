import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/models/api_response.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/music_api.dart';

class CompleteMusicService extends GetxService {
  final MusicApi _musicApi = Get.find<MusicApi>();

  Future<ApiResponse<MusicModel>> postMusic({
    required String title,
    required String status,
    PlatformFile? topline,
    PlatformFile? voice,
    File? coverImage,
    double voiceVolume = 0.5,
    double musicVolume = 0.5,
  }) =>
      _musicApi.postMusic(
        title: title,
        status: status,
        topline: topline,
        voice: voice,
        coverImage: coverImage,
        voiceVolume: voiceVolume,
        musicVolume: musicVolume,
      );
}
