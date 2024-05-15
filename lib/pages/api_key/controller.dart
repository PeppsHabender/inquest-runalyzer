import 'package:get/get.dart';
import 'package:runalyzer_client/utils/storage.dart';

import '../../utils/auth.dart';
import '../../utils/utils.dart';

class ApiKeyController extends GetxController {
  final AuthService _authService = Get.find();

  final RxString apiKey = "".obs;
  final RxBool loading = false.obs;
  final Rx<String?> errMessage = (null as String?).obs;

  ApiKeyController() {
    if (RunalyzerStorage.apiKey != null) _return();
  }

  bool canLoad() => apiKey.value.isNotEmpty && !loading.value;

  void tryAuthenticating() {
    loading.value = true;
    _authService.validate(apiKey.value).then((value) {
      loading.value = false;

      if (value == null) {
        _return();
      } else {
        _reset(value);
      }
    });
  }

  void _reset([final String? msg]) {
    loading.value = false;
    apiKey.value = "";
    errMessage.value = msg;
  }

  void _return() =>
      Get.offAllNamed(Get.parameters["return"] ?? RunalyzerLinks.HOME);
}
