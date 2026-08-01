import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryService extends GetxService {
  late final RxBool hasTruffleObs = RxBool(false);


  static final MemoryService _mInstance = MemoryService._();
  static MemoryService get instance => _mInstance;

  late SharedPreferences _prefs;
  late GetStorage _storage;

  MemoryService._();

  Future<void> initialize() async {
    await GetStorage.init('sifflard');
    _storage = GetStorage('sifflard');

    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> ensureInitialized() async {
    if (!GetStorage().hasData('sifflard')) {
      await initialize();
    }
  }

  String? get access {
    final value = _prefs.getString('access');
    return value;
  }

  set access(String? value) {
    if (value == null) {
      _prefs.remove('access');
    } else {
      _prefs.setString('access', value);
    }
  }

  String? get refresh {
    final value = _prefs.getString('refresh');
    return value;
  }

  set refresh(String? value) {
    if (value == null) {
      _prefs.remove('refresh');
    } else {
      _prefs.setString('refresh', value);
    }
  }

  String? get languageCode => _storage.read('languageCode');
  set languageCode(String? value) => _storage.write('languageCode', value);

}