import 'dart:convert';

import 'package:get/get.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:rx_future/rx_future.dart';

class StaticController extends GetxController {
  final RxFuture<List<Static>> staticsFuture = RxFuture([]);
  final Map<Static, (bool, int, RxFuture<List<StaticRun>>)> staticRuns = {};

  final RxSet<String> loadingStatics = <String>{}.obs;

  StaticController() {
    staticsFuture.observe(
      (_) async => await doHttpRequest("/api/statics", true, (status, body) =>
        status > 200 ? throw Exception() : (jsonDecode(body) as Iterable<dynamic>).whereType<Map<String, dynamic>>().map(Static.fromJson).toList()
      ),
      onSuccess: (ls) => ls.forEach(loadMoreRuns)
    );
  }

  void resetRuns(Static static) {
    staticRuns.update(static, (v) => (true, 0, v.$3));
    loadMoreRuns(static);
  }

  void loadMoreRuns(Static static) {
    staticRuns.putIfAbsent(static, () => (true, 0, RxFuture([])));
    final (bool, int, RxFuture<List<StaticRun>>) future = staticRuns[static]!;

    loadingStatics.add(static.id);
    future.$3.newValue(
      (prev) async {
        if(!future.$1) return prev ?? [];

        return await doHttpRequest("/api/statics/${static.id}/runs", true, queryParams: {"page":future.$2}, (status, body) {
          //print("$status\n$body");
          if(status > 200 || body.isEmpty) {
            return prev ?? [];
          }

          try {
            final Page<StaticRun> found = Page.fromJson(jsonDecode(body), StaticRun.fromJson);
            final List<StaticRun> ls = (prev ?? []);
            ls.addAll(found.items);

            staticRuns[static] = (found.hasMore, future.$2 + 1, future.$3);

            return ls;
          } catch(e) {
            e.printError();
            rethrow;
          }
        });
      },
      finallyDo: () => loadingStatics.remove(static.id)
    );
  }

  Static? forId(final String id) => staticsFuture.value.hasValue
      ? staticsFuture.value.value.firstWhereOrNull((element) => id == element.id) : null;

  StaticRun? lastRun(final Static static) {
    final RxFuture<List<StaticRun>>? future = staticRuns[static]?.$3;
    if(future == null || !future.value.hasValue) {
      return null;
    } else {
      return future.value.value.firstOrNull;
    }
  }

  RxFuture<List<StaticRun>> lastRuns(final Static static) => staticRuns[static]?.$3 ?? RxFuture(<StaticRun>[]);
}