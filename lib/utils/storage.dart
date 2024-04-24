import 'dart:html';

final class RunalyzerStorage {
  static const String _API_KEY = "gw2Key";
  static const String _ACC_NAME = "accName";

  static final Storage _storage = window.localStorage;

  RunalyzerStorage._();

  static String? get apiKey => _storage[_API_KEY];
  static set apiKey(String? apiKey) => _storage[_API_KEY] = apiKey ?? "";

  static String? get accountName => _storage[_ACC_NAME];
  static set accountName(String? accountName) => _storage[_ACC_NAME] = accountName ?? "";
}