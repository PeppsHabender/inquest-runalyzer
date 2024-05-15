import 'dart:convert';

import 'package:get/get.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/entities/tof_progression.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:rx_future/rx_future.dart';

class TofProgController extends GetxController {
  final RxList<TofProgression> progs = <TofProgression>[].obs;
  final Map<String, (bool, int, RxFuture<List<TofRun>>)> _tofRuns = {};

  TofProgController(Static static) {
    _loadTofProgs(static);
  }

  void _loadTofProgs(Static static) {
    doHttpRequest("/api/prog/tof", true, (status, body) {
      if (status >= 400) return;

      final Iterable<TofProgression> progressions =
          (jsonDecode(body) as Iterable<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(TofProgression.fromJson);
      progressions.forEach(loadMoreRuns);

      progs.addAll(progressions);
    }, queryParams: {"static_id": static.id});
  }

  RxFuture<List<TofRun>> runs(final TofProgression prog) =>
      _tofRuns[prog.id]!.$3;

  void loadMoreRuns(final TofProgression prog) {
    _tofRuns.putIfAbsent(prog.id, () => (true, 0, RxFuture([])));
    final (bool, int, RxFuture<List<TofRun>>) future = _tofRuns[prog.id]!;

    future.$3.newValue((prev) async {
      if (!future.$1) return prev ?? [];

      return await doHttpRequest("/api/prog/tof/${prog.id}", true,
          queryParams: {"page": future.$2}, (status, body) {
        //print("$status\n$body");
        if (status > 200 || body.isEmpty) {
          return prev ?? [];
        }

        try {
          final Page<TofRun> found =
              Page.fromJson(jsonDecode(body), TofRun.fromJson);
          final List<TofRun> ls = (prev ?? []);

          ls.addAll(found.items);
          ls.sort((a, b) => (b.time ?? 0) - (a.time ?? 0));

          _tofRuns[prog.id] = (found.hasMore, future.$2 + 1, future.$3);

          return ls;
        } catch (e) {
          e.printError();
          rethrow;
        }
      });
    });
  }
}

extension TofRunExtensions on List<TofRun> {
  static final String _TIME_ZONE_NAME = DateTime.now().timeZoneName;

  Iterable<StaticAnalysis> toAnalyses() => map(
      (e) => e.runLog).whereType<RunLog>().map((e) => StaticAnalysis()
    ..duration = e.log?.encounter?.duration ?? 0
    ..downtime = 0
    ..start = MongoDateTime(
        date: DateTime.fromMillisecondsSinceEpoch(e.log!.encounterTime * 1000),
        offset: _TIME_ZONE_NAME)
    ..end = MongoDateTime(
        date: DateTime.fromMillisecondsSinceEpoch(
            e.log!.encounterTime * 1000 + e.log!.encounter!.duration * 1000),
        offset: _TIME_ZONE_NAME)
    ..averageTimePerBoss = e.log?.encounter?.duration.toDouble() ?? 0
    ..avgDps =
        e.offensiveStats.associateBy((e) => (e.player ?? "", e.dps.toDouble()))
    ..compDps = e.groupDps.toDouble()
    ..cc = e.offensiveStats.associateBy((e) => (e.player ?? "", e.cc))
    ..playerBoonStatsAvg = e.playerBoonStats
    ..subGroupBoonStatsAvg = e.subGroupBoonStats
    ..defensiveStats = e.defensiveStats
    ..successful = e.log!.encounter!.success ? [e] : []
    ..wipes = e.log!.encounter!.success ? [] : [e]);
}
