import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/api_response.dart';
import 'package:swypher_flutter/shared/data/models/music_model.dart';
import 'package:swypher_flutter/shared/data/network/api_client.dart';

class SearchResult {
  final List<MusicModel> musics;

  SearchResult({required this.musics});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final raw = (json['musics'] ?? json['music'] ?? []) as List;
    return SearchResult(
      musics: raw
          .map((e) => MusicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SearchService extends GetxService {
  final ApiClient _client = Get.find<ApiClient>();

  Future<ApiResponse<SearchResult>> search(String query) =>
      _client.get<SearchResult>(
        ApiConfiguration.searchPath,
        query: {'q': query},
        fromData: (data) =>
            SearchResult.fromJson(data as Map<String, dynamic>),
      );
}
