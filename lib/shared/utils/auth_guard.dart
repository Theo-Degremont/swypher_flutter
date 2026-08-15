import 'package:get/get.dart';
import 'package:swypher_flutter/app/routes/app_pages.dart';
import 'package:swypher_flutter/shared/services/memory_service.dart';

bool requireAuth() {
  if (MemoryService.instance.access != null) return true;
  Get.toNamed(Routes.LOGIN);
  return false;
}
