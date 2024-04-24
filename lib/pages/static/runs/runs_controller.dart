import 'package:get/get.dart';
import 'package:runalyzer_client/controller/wingman_service.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/entities/logs.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/utils/extensions.dart';

typedef _BossTuple = ({int bossId, int dps, double percent});
typedef BestBoss = ({String boss, int? dps});
typedef SupportStats = ({
  double healing,
  double barrier,
  int condiCleanses,
  int boonStrips,
});
typedef DefStats = ({
  int damageTaken,
  int downstates,
  int deaths
});
typedef BossState = ({String? successUrl, List<String> failUrls});

class StaticRunController extends GetxController {
  final RxInt selected = 0.obs;
  final List<StaticRun> runs;

  StaticRunController(this.runs);

  BestBoss getBestBoss(final String player) {
    final _BossTuple bossTuple =
        currentRun().analysis!.successful.map<_BossTuple>((log) {
      final OffensiveStats? stats =
          log.offensiveStats.firstWhereOrNull((e) => player == e.player);
      final int bossId = log.log!.encounter!.bossId;
      if (stats == null) return (bossId: bossId, dps: 0, percent: 0);

      return (
        bossId: log.log!.encounter!.bossId,
        dps: stats.dps,
        percent: stats.dps.toDouble() / log.groupDps.toDouble()
      );
    }).reduce((curr, e) => curr.percent > e.percent ? curr : e);

    final Boss? boss = WingmanService.fetchBoss(bossTuple.bossId);
    if (boss?.name == null) {
      return (boss: "", dps: null);
    } else {
      return (boss: boss!.name, dps: bossTuple.dps);
    }
  }

  Map<String, Map<String, double>> getBoonGenerationStats() =>
      (currentRun().analysis?.playerBoonStatsAvg.associateBy((stats) => (
            stats.player,
            stats.boons.indexed
                .associateBy((e) => (e.$2, stats.generation![e.$1]))
          ))
        ?..removeWhere((k, _) => !currentRun().players.contains(k))) ??
      {};

  Map<int, Map<String, double>> getSubBoonStats() =>
      (currentRun().analysis?.subGroupBoonStatsAvg.associateBy((stats) => (
            int.parse(stats.player),
            stats.boons.indexed.associateBy((e) => (e.$2, stats.uptime[e.$1]))
          ))) ??
      {};

  bool hasHBStats() =>
      currentRun()
          .analysis
          ?.defensiveStats
          .firstWhereOrNull((e) => e.healing != null || e.barrier != null) !=
      null;

  Map<String, SupportStats> suppStats() => currentRun()
      .analysis!
      .defensiveStats
      .where((e) => e.healing != null || e.barrier != null)
      .associateBy((e) => (
            e.player!,
            (
              healing: e.healing ?? .0,
              barrier: e.barrier ?? .0,
              condiCleanses: e.condiCleanses.round(),
              boonStrips: e.boonStrips.round()
            )
          ))
    ..removeWhere((k, _) => !currentRun().players.contains(k));

  Map<String, DefStats> defStats() => currentRun().analysis!.defensiveStats.associateBy((e) =>
    (e.player!, (damageTaken: e.damageTaken.round(), downstates: e.downstates.round(), deaths: e.deaths.round()))
  )..removeWhere((k, _) => !currentRun().players.contains(k));

  Map<String, BossState> bossStates() {
    final StaticAnalysis analysis = currentRun().analysis!;

    return (analysis.successful + analysis.wipes).map((e) => e.log)
      .whereType<DpsReport>()
      .groupBy((e) => e.encounter?.bossId ?? -1)
      .map((k, v) {
        final String? success = v.firstWhereOrNull((e) => e.encounter?.success ?? false)?.permalink;
        final List<String> fails = v.where((e) => !(e.encounter?.success ?? true)).map((e) => e.permalink).toList();

        return MapEntry(
          WingmanService.fetchBoss(k)?.name ?? k.toString(),
          (successUrl: success, failUrls: fails)
        );
      });
  }

  StaticRun currentRun() => runs[selected.value];
}
