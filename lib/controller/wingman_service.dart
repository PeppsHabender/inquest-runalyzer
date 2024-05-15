import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:rx_future/rx_future.dart';

class WingmanService {
  static RxFuture<List<Gw2Patch>> PATCHES = RxFuture([])
    ..newValue((prev) async {
      if (prev?.isNotEmpty == true) return prev ?? [];

      return await doHttpRequest(
        "/info/patches",
        false,
        (status, body) => status > 200
            ? []
            : Gw2Patches.fromJson(jsonDecode(body) as Map<String, dynamic>)
                .patches,
      );
    });
  static RxFuture<Map<int, Boss>> BOSSES = RxFuture(<int, Boss>{})
    ..newValue((prev) async {
      if (prev?.isNotEmpty == true) return prev ?? {};

      return await doHttpRequest(
        "/info/bosses",
        false,
        (status, body) => status > 200
            ? <int, Boss>{}
            : BossMap(jsonDecode(body) as Map<String, dynamic>).bossMap,
      );
    });

  WingmanService._();

  static Widget fetchBoss(final int id, Widget Function(Boss boss) child,
          {Widget Function()? fallback}) =>
      ObxValue((bosses) {
        if (bosses.loading || bosses.hasError)
          return fallback?.call() ?? Container();

        final Boss? boss = bosses.result[id] ??
            bosses.result.entries
                .where((e) => e.value.targetIDs.contains(id))
                .firstOrNull
                ?.value;
        return boss == null ? (fallback?.call() ?? Container()) : child(boss);
      }, BOSSES);
}
