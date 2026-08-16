import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/data/network/auth_api.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final RxString dots = ''.obs;
  final RxString version = ''.obs;

  late final AnimationController shimmerController;

  Timer? _dotsTimer;

  @override
  void onInit() {
    super.onInit();
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _startDotsAnimation();
    _loadVersion();
    _initAndNavigate();
  }

  void _startDotsAnimation() {
    final sequence = ['.', '..', '...', ''];
    int index = 0;
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      dots.value = sequence[index % sequence.length];
      index++;
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version.value = info.version;
  }

  Future<void> _initAndNavigate() async {
    // Attendre au moins 2 secondes pour le splash
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _tryAutoLogin(),
    ]);
    Get.offAllNamed(Routes.MAIN);
  }

  /// Tente de renouveler les tokens si un refresh token est présent.
  /// En cas d'échec (token expiré / révoqué) : vide les tokens.
  /// En cas d'erreur réseau : on laisse les tokens intacts pour réessayer plus tard.
  Future<void> _tryAutoLogin() async {
    final memory = MemoryService.instance;
    final refreshToken = memory.refresh;
    if (refreshToken == null) return;

    try {
      final authApi = Get.find<AuthApi>();
      final response = await authApi.refreshTokens(refreshToken: refreshToken);

      if (response.isSuccess && response.data != null) {
        memory.access = response.data!.tokens.accessToken;
        await memory.setRefresh(response.data!.tokens.refreshToken);
      } else {
        // Token expiré ou révoqué → déconnexion propre
        memory.access = null;
        await memory.setRefresh(null);
      }
    } catch (_) {
      // Erreur réseau : on garde les tokens existants,
      // l'ApiClient gérera le 401 en cas de besoin.
    }
  }

  @override
  void onClose() {
    shimmerController.dispose();
    _dotsTimer?.cancel();
    super.onClose();
  }
}
