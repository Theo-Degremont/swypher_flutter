class ApiFieldError {
  final String? field;
  final String message;

  ApiFieldError({this.field, required this.message});

  factory ApiFieldError.fromJson(Map<String, dynamic> json) => ApiFieldError(
        field: json['field'] as String?,
        message: json['message'] as String? ?? '',
      );
}

class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String? message;
  final T? data;
  final List<ApiFieldError>? errors;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  bool get isSuccess => success;

  /// Premier message d'erreur global (hors champ).
  String? get errorMessage {
    if (!success && message != null) return message;
    if (errors != null && errors!.isNotEmpty) {
      final global = errors!.where((e) => e.field == null);
      if (global.isNotEmpty) return global.first.message;
      return errors!.first.message;
    }
    return null;
  }

  /// Message d'erreur pour un champ précis.
  String? fieldError(String field) {
    return errors
        ?.where((e) => e.field == field)
        .map((e) => e.message)
        .firstOrNull;
  }

  /// Toutes les erreurs par champ sous forme de Map.
  Map<String, String> get fieldErrors {
    final map = <String, String>{};
    for (final e in errors ?? []) {
      if (e.field != null) map[e.field!] = e.message;
    }
    return map;
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    final rawErrors = json['errors'];
    List<ApiFieldError>? parsedErrors;
    if (rawErrors is List) {
      parsedErrors = rawErrors
          .whereType<Map<String, dynamic>>()
          .map(ApiFieldError.fromJson)
          .toList();
    }

    T? parsedData;
    if (fromData != null && json['data'] != null) {
      parsedData = fromData(json['data']);
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String?,
      data: parsedData,
      errors: parsedErrors,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  /// Réponse d'erreur réseau (pas de réponse du serveur).
  factory ApiResponse.networkError() => ApiResponse<T>(
        success: false,
        statusCode: 0,
        message: 'Erreur réseau. Vérifiez votre connexion.',
      );

  /// Réponse d'erreur inattendue (parsing raté, etc.).
  factory ApiResponse.unexpected() => ApiResponse<T>(
        success: false,
        statusCode: -1,
        message: 'Une erreur inattendue est survenue.',
      );
}
