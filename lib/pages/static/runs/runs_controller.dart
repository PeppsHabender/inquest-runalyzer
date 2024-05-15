import 'package:get/get.dart';
import 'package:runalyzer_client/controller/wingman_service.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/entities/logs.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/utils/extensions.dart';

typedef BestBoss = ({int bossId, int dps, double percent});
typedef SupportStats = ({
  double healing,
  double barrier,
  int condiCleanses,
  int boonStrips,
});
typedef DefStats = ({int damageTaken, int downstates, int deaths});
typedef BossState = ({String? successUrl, List<String> failUrls});

class StaticRunController extends GetxController {
  final RxInt selected = 0.obs;
  final Iterable<StaticAnalysis> analyses;

  StaticRunController(this.analyses);

  BestBoss getBestBoss(final String player) {
    final BestBoss bossTuple = currentRun().successful.map<BestBoss>((log) {
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

    return bossTuple;
  }

  Map<String, Map<String, double>> getBoonGenerationStats() =>
      currentRun().playerBoonStatsAvg.associateBy((stats) => (
            stats.player,
            stats.boons.indexed
                .associateBy((e) => (e.$2, stats.generation![e.$1]))
          ));
  //?..removeWhere((k, _) => !currentRun().players.contains(k))) ??{};

  Map<int, Map<String, double>> getSubBoonStats() =>
      (currentRun().subGroupBoonStatsAvg.associateBy((stats) => (
            int.parse(stats.player),
            stats.boons.indexed.associateBy((e) => (e.$2, stats.uptime[e.$1]))
          ))) ??
      {};

  bool hasHBStats() =>
      currentRun()
          .defensiveStats
          .firstWhereOrNull((e) => e.healing != null || e.barrier != null) !=
      null;

  Map<String, SupportStats> suppStats() => currentRun()
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
          ));
  //..removeWhere((k, _) => !currentRun().players.contains(k));

  Map<String, DefStats> defStats() =>
      currentRun().defensiveStats.associateBy((e) => (
            e.player!,
            (
              damageTaken: e.damageTaken.round(),
              downstates: e.downstates.round(),
              deaths: e.deaths.round()
            )
          )); //..removeWhere((k, _) => !currentRun().players.contains(k));

  Map<int, BossState> bossStates() {
    final StaticAnalysis analysis = currentRun();

    return (analysis.successful + analysis.wipes)
        .map((e) => e.log)
        .whereType<DpsReport>()
        .groupBy((e) => e.encounter?.bossId ?? -1)
        .map((k, v) {
      final String? success =
          v.firstWhereOrNull((e) => e.encounter?.success ?? false)?.permalink;
      final List<String> fails = v
          .where((e) => !(e.encounter?.success ?? true))
          .map((e) => e.permalink)
          .toList();

      return MapEntry(k, (successUrl: success, failUrls: fails));
    });
  }

  StaticAnalysis currentRun() => analyses.toList()[selected.value];
}
