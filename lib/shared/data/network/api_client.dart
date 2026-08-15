import 'dart:convert';

import 'package:get/get.dart';
import 'package:swypher_flutter/shared/data/config/api_configuration.dart';
import 'package:swypher_flutter/shared/data/models/api_response.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class ApiClient extends GetxService {
  final MemoryService _memory = Get.find<MemoryService>();
  final GetConnect _http = GetConnect(timeout: const Duration(seconds: 30));

  bool _isRefreshing = false;

  // ─── Headers ────────────────────────────────────────────────────────────────

  Map<String, String> get _baseHeaders => {
        'x-api-key': ApiConfiguration.apiKey,
        'Content-Type': 'application/json',
      };

  Map<String, String> get _authHeaders => {
        ..._baseHeaders,
        if (_memory.access != null)
          'Authorization': 'Bearer ${_memory.access}',
      };

  // ─── Language helpers ────────────────────────────────────────────────────────

  /// Ajoute la langue dans le body d'une requête POST/PATCH.
  Map<String, dynamic> _withLang(Map<String, dynamic> body) => {
        'language': _memory.languageCode ?? 'fr',
        ...body,
      };

  /// Ajoute la langue comme query param pour les requêtes GET.
  Map<String, String> _langQuery([Map<String, String>? extra]) => {
        'lang': _memory.languageCode ?? 'fr',
        ...?extra,
      };

  // ─── Core request ────────────────────────────────────────────────────────────

  Future<ApiResponse<T>> _execute<T>({
    required String method,
    required String path,
    bool requiresAuth = false,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    T Function(dynamic)? fromData,
    bool isRetry = false,
  }) async {
    try {
      final url = '${ApiConfiguration.apiUrl}$path';
      final headers = requiresAuth ? _authHeaders : _baseHeaders;

      Response response;
      switch (method) {
        case 'GET':
          response = await _http.get(url, headers: headers, query: query);
        case 'POST':
          response = await _http.post(url, body, headers: headers, query: query);
        case 'PATCH':
          response = await _http.patch(url, body, headers: headers, query: query);
        case 'DELETE':
          if (body != null) {
            response = await _http.request(url, 'DELETE', body: body, headers: headers, query: query);
          } else {
            response = await _http.delete(url, headers: headers, query: query);
          }
        default:
          return ApiResponse.unexpected();
      }

      // Token expiré → tentative de refresh automatique (une seule fois)
      if (response.statusCode == 401 && requiresAuth && !isRetry) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          return _execute(
            method: method,
            path: path,
            requiresAuth: requiresAuth,
            body: body,
            query: query,
            fromData: fromData,
            isRetry: true,
          );
        }
      }

      return _parse(response, fromData);
    } catch (_) {
      return ApiResponse.networkError();
    }
  }

  // ─── Parsing ─────────────────────────────────────────────────────────────────

  ApiResponse<T> _parse<T>(Response response, T Function(dynamic)? fromData) {
    try {
      final body = response.body;

      // GetConnect decode automatiquement le JSON si Content-Type: application/json.
      // Si ce n'est pas le cas (erreur réseau, timeout), body peut être null.
      if (body == null) return ApiResponse.networkError();

      Map<String, dynamic> json;
      if (body is Map<String, dynamic>) {
        json = body;
      } else if (body is String) {
        json = jsonDecode(body) as Map<String, dynamic>;
      } else {
        return ApiResponse.unexpected();
      }

      return ApiResponse.fromJson(json, fromData);
    } catch (_) {
      return ApiResponse.unexpected();
    }
  }

  // ─── Token refresh ───────────────────────────────────────────────────────────

  Future<bool> _tryRefresh() async {
    if (_isRefreshing) return false;
    final token = _memory.refresh;
    if (token == null) return false;

    _isRefreshing = true;
    try {
      final response = await _http.post(
        '${ApiConfiguration.apiUrl}${ApiConfiguration.refreshPath}',
        {'refreshToken': token, 'language': _memory.languageCode ?? 'fr'},
        headers: _baseHeaders,
      );

      if (response.statusCode == 200 && response.body is Map) {
        final json = response.body as Map<String, dynamic>;
        final tokens = json['data']?['tokens'];
        if (tokens is Map<String, dynamic>) {
          _memory.access = tokens['accessToken'] as String?;
          _memory.refresh = tokens['refreshToken'] as String?;
          return true;
        }
      }
      // Refresh échoué → on vide les tokens
      _memory.access = null;
      _memory.refresh = null;
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ─── API publique ─────────────────────────────────────────────────────────────

  Future<ApiResponse<T>> get<T>(
    String path, {
    bool requiresAuth = false,
    Map<String, String>? query,
    T Function(dynamic)? fromData,
  }) =>
      _execute(
        method: 'GET',
        path: path,
        requiresAuth: requiresAuth,
        query: _langQuery(query),
        fromData: fromData,
      );

  Future<ApiResponse<T>> post<T>(
    String path, {
    bool requiresAuth = false,
    Map<String, dynamic> body = const {},
    T Function(dynamic)? fromData,
  }) =>
      _execute(
        method: 'POST',
        path: path,
        requiresAuth: requiresAuth,
        body: _withLang(body),
        fromData: fromData,
      );

  Future<ApiResponse<T>> patch<T>(
    String path, {
    bool requiresAuth = true,
    Map<String, dynamic> body = const {},
    T Function(dynamic)? fromData,
  }) =>
      _execute(
        method: 'PATCH',
        path: path,
        requiresAuth: requiresAuth,
        body: _withLang(body),
        fromData: fromData,
      );

  Future<ApiResponse<T>> delete<T>(
    String path, {
    bool requiresAuth = true,
    Map<String, String>? query,
    T Function(dynamic)? fromData,
  }) =>
      _execute(
        method: 'DELETE',
        path: path,
        requiresAuth: requiresAuth,
        query: _langQuery(query),
        fromData: fromData,
      );

  Future<ApiResponse<T>> deleteWithBody<T>(
    String path, {
    bool requiresAuth = true,
    Map<String, dynamic> body = const {},
    T Function(dynamic)? fromData,
  }) =>
      _execute(
        method: 'DELETE',
        path: path,
        requiresAuth: requiresAuth,
        body: _withLang(body),
        fromData: fromData,
      );

  // ─── Multipart (pas de Content-Type dans les headers — GetConnect le gère) ──

  Map<String, String> get _baseMultipartHeaders => {
        'x-api-key': ApiConfiguration.apiKey,
      };

  Map<String, String> get _authMultipartHeaders => {
        ..._baseMultipartHeaders,
        if (_memory.access != null)
          'Authorization': 'Bearer ${_memory.access}',
      };

  Future<ApiResponse<T>> patchMultipart<T>(
    String path, {
    bool requiresAuth = true,
    required FormData formData,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final url = '${ApiConfiguration.apiUrl}$path';
      final headers =
          requiresAuth ? _authMultipartHeaders : _baseMultipartHeaders;
      final response = await _http.patch(url, formData, headers: headers);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          final retryResponse = await _http.patch(
            url,
            formData,
            headers: _authMultipartHeaders,
          );
          return _parse(retryResponse, fromData);
        }
      }

      return _parse(response, fromData);
    } catch (_) {
      return ApiResponse.networkError();
    }
  }

  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    bool requiresAuth = true,
    required FormData formData,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final url = '${ApiConfiguration.apiUrl}$path';
      final headers =
          requiresAuth ? _authMultipartHeaders : _baseMultipartHeaders;
      final response = await _http.post(url, formData, headers: headers);

      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          final retryResponse = await _http.post(
            url,
            formData,
            headers: _authMultipartHeaders,
          );
          return _parse(retryResponse, fromData);
        }
      }

      return _parse(response, fromData);
    } catch (_) {
      return ApiResponse.networkError();
    }
  }
}
