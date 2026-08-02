import 'package:get/get.dart';

class HomeController extends GetxController {
  // 0 = Auto, 1 = Prods
  final selectedTab = 0.obs;

  void selectTab(int index) => selectedTab.value = index;
}
