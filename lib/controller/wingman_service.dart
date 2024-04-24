import 'dart:convert';

import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/utils/utils.dart';

class WingmanService {
  static const String _WINGMAN_ENDPOINT = "https://gw2wingman.nevermindcreations.de";

  static List<Gw2Patch> _PATCHES = [];
  static Map<int, Boss> _BOSSES = {};

  WingmanService._();

  static List<Gw2Patch> get PATCHES {
    if (_PATCHES.isEmpty) {
      doHttpRequest(
        "/info/patches",
        false,
        (status, body) => _PATCHES = status > 200 ? [] : Gw2Patches.fromJson(jsonDecode(body) as Map<String, dynamic>).patches,
      );
    }

    return _PATCHES;
  }

  static Map<int, Boss> get BOSSES {
    if (_BOSSES.isEmpty) {
      doHttpRequest(
        "/info/bosses",
        false,
        (status, body) => _BOSSES = status > 200 ? <int, Boss>{} : BossMap(jsonDecode(body) as Map<String, dynamic>).bossMap,
      );
    }

    return _BOSSES;
  }

  static Boss? fetchBoss(final int id) => BOSSES[id] ?? BOSSES.entries
    .where((e) => e.value.targetIDs.contains(id))
    .firstOrNull?.value;
}