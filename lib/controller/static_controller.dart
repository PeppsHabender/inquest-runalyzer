import 'dart:convert';

import 'package:get/get.dart';
import 'package:runalyzer_client/controller/progs_controller.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:rx_future/rx_future.dart';

class StaticController extends GetxController {
  final RxFuture<List<Static>> staticsFuture = RxFuture([]);
  final Map<Static, (bool, int, RxFuture<List<StaticRun>>)> _staticRuns = {};

  final RxSet<String> loadingStatics = <String>{}.obs;

  StaticController() {
    staticsFuture.observe(
        (_) async => await doHttpRequest(
            "/api/statics",
            true,
            (status, body) => status > 200
                ? throw Exception()
                : (jsonDecode(body) as Iterable<dynamic>)
                    .whereType<Map<String, dynamic>>()
                    .map(Static.fromJson)
                    .toList()),
        onSuccess: (ls) => ls.forEach((static) {
              loadMoreRuns(static);
              Get.put(TofProgController(static),
                  permanent: true, tag: static.id);
            }));
  }

  void resetRuns(Static static) {
    _staticRuns.update(static, (v) => (true, 0, v.$3));
    loadMoreRuns(static);
  }

  void loadMoreRuns(Static static) {
    final (bool, int, RxFuture<List<StaticRun>>) future =
        _staticRuns.putIfAbsent(static, () => (true, 0, RxFuture([])));

    loadMorePages(future, "/api/statics/${static.id}/runs", StaticRun.fromJson,
        onSuccess: (hasMore, newPage) =>
            _staticRuns[static] = (hasMore, newPage, future.$3),
        finallyDo: () => loadingStatics.remove(static.id),
        sort: (a, b) =>
            b.analysis?.start?.date
                .compareTo(b.analysis?.start?.date ?? DateTime.now()) ??
            -1);
  }

  Static? forId(final String id) => staticsFuture.value.hasValue
      ? staticsFuture.value.value
          .firstWhereOrNull((element) => id == element.id)
      : null;

  StaticRun? lastRun(final Static static) {
    final RxFuture<List<StaticRun>>? future = _staticRuns[static]?.$3;
    if (future == null || !future.value.hasValue) {
      return null;
    } else {
      return future.value.value.firstOrNull;
    }
  }

  RxFuture<List<StaticRun>> lastRuns(final Static static) =>
      _staticRuns[static]?.$3 ?? RxFuture(<StaticRun>[]);
}
