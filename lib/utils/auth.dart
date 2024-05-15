import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/utils/storage.dart';

import '../controller/static_controller.dart';
import 'utils.dart';

class AuthService {
  AuthService._();

  Future<String?> validate([String? key]) {
    return key == null
        ? Future(() => "No API key!")
        : doHttpRequest(
                "/api/testKey",
                false,
                headers: {"X-API-KEY": key},
                (status, body) => _handleResponse(key, status, body))
            .catchError((ex) {
            print(ex.toString());
            return Future(() => ex.toString());
          });
  }

  String? _handleResponse(String key, int status, String body) {
    if (status > 200) return body.isEmpty ? "Failed to validate API key" : body;

    final String accName = jsonDecode(body) as String;
    if (accName.isNotEmpty) {
      RunalyzerStorage.apiKey = key;
      RunalyzerStorage.accountName = accName;
    }

    return null;
  }

  bool authenticated() => RunalyzerStorage.apiKey != null;
}

class AuthMiddleware extends GetMiddleware {
  static final AuthMiddleware _instance = AuthMiddleware._();

  AuthMiddleware._();

  factory AuthMiddleware() => _instance;

  final AuthService _authService = Get.put(AuthService._(), permanent: true);

  @override
  RouteSettings? redirect(String? route) {
    if (_authService.authenticated()) {
      Get.put(StaticController(), permanent: true);
      return null;
    }

    return RouteSettings(
        name:
            "${RunalyzerLinks.API_KEY}?return=${Uri.encodeFull(route ?? "")}");
  }
}
