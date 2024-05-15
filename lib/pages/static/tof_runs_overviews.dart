import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/controller/progs_controller.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/entities/tof_progression.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';
import 'package:runalyzer_client/pages/static/runs/data_table.dart';
import 'package:runalyzer_client/pages/static/static_overview.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';

class TofOverview extends StaticOverviewBase {
  final List<TofRun> runs;

  TofOverview(final Static static, this.runs, {super.key})
      : super(static, runs.toAnalyses()) {
    _addEmpowered(runs);
  }

  @override
  Iterable<(String, ChartModel Function())> additionalCharts() => [
        (
          "Empowered",
          () => buildPhasesChart(runs, (r) {
                final double? count = r?.empowerment.counts
                    .where((e) => e.player == "Cerus")
                    .map((e) => e.times.length)
                    .reduceOrNull((a, b) => a + b)
                    ?.toDouble();

                if (count == null) return null;

                return count + r!.empowerment.previousPhaseCounts;
              }, interval: 10)
        ),
        (
          "Group Dps",
          () =>
              buildPhasesChart(runs, (r) => r?.dps.toDouble(), interval: 20000)
        )
      ];

  void _addEmpowered(List<TofRun> runs) => runs.forEach((e) {
        _addEmpoweredPhase(e.phase1, e.phase2);
        _addEmpoweredPhase(e.phase2, e.phase3);
        _addEmpoweredPhase(e.phase3, e.enrage);
      });

  void _addEmpoweredPhase(TofPhase? prevPhase, TofPhase? nextPhase) {
    if (prevPhase != null &&
        nextPhase != null &&
        nextPhase.empowerment.previousPhaseCounts == 0) {
      nextPhase.empowerment.previousPhaseCounts +=
          prevPhase.empowerment.counts.length;
    }
  }

  static Widget MechanicsTable(final TofRun runLog) {
    List<String> players = runLog.runLog?.log?.members ?? [];

    return RunalyzerDataTable(
        columns: [
          stringColumn("Player"),
          intColumn("Got Green"),
          intColumn("Hit by Green"),
          intColumn("Hit by Slam"),
          intColumn("Collections"),
          intColumn("Hit by Wall"),
          intColumn("Got Shadow"),
          intColumn("Spread AOE Impact"),
          intColumn("Spread AOE"),
        ],
        rows: players.map((player) {
          final int crushingRegretCatches =
              runLog.countFullFight((p) => p.crushingRegretCatches, player);
          final int crushingRegretHits =
              runLog.countFullFight((p) => p.crushingRegretHits, player);
          final int cryOfRage =
              runLog.countFullFight((p) => p.cryOfRage, player);
          final int insatiable =
              runLog.countFullFight((p) => p.insatiable, player);
          final int enviousGaze =
              runLog.countFullFight((p) => p.enviousGaze, player);
          final int maliciousIntent =
              runLog.countFullFight((p) => p.maliciousIntent, player);
          final int wailOfDespair =
              runLog.countFullFight((p) => p.wailOfDespair, player);
          final int poolOfDespair =
              runLog.countFullFight((p) => p.poolOfDespair, player);

          return RunalyzerRow(cells: [
            RunalyzerCell(data: player, child: Text(player)),
            RunalyzerCell(
                data: crushingRegretCatches,
                child: Text(crushingRegretCatches.toString())),
            RunalyzerCell(
                data: crushingRegretHits,
                child: Text(crushingRegretHits.toString())),
            RunalyzerCell(data: cryOfRage, child: Text(cryOfRage.toString())),
            RunalyzerCell(data: insatiable, child: Text(insatiable.toString())),
            RunalyzerCell(
                data: enviousGaze, child: Text(enviousGaze.toString())),
            RunalyzerCell(
                data: maliciousIntent, child: Text(maliciousIntent.toString())),
            RunalyzerCell(
                data: wailOfDespair, child: Text(wailOfDespair.toString())),
            RunalyzerCell(
                data: poolOfDespair, child: Text(poolOfDespair.toString()))
          ]);
        }).toList());
  }

  @override
  bool buildWithDate() => false;
}

ChartModel buildPhasesChart(
    final List<TofRun> runs, double? Function(TofPhase?) yExtractor,
    {double? interval}) {
  runs.sort((a, b) => (a.time ?? 0) - (b.time ?? 0));

  final List<String> fullfightTTs = [];
  final List<FlSpot> fullfight = ChartModelBuilder.genericChartData(
      runs, (i, r) => i.toDouble(), (r) => yExtractor(r.fullFight),
      onXY: (x, y, el) => fullfightTTs.add("Full-Fight: ${y.toString()}"));

  final List<String> phase1TTs = [];
  final List<FlSpot> phase1 = ChartModelBuilder.genericChartData(
      runs, (i, r) => i.toDouble(), (r) => yExtractor(r.phase1),
      onXY: (x, y, el) => phase1TTs.add("Phase 1: ${y.toString()}"));

  final List<String> phase2TTs = [];
  final List<FlSpot> phase2 = ChartModelBuilder.genericChartData(
      runs, (i, r) => i.toDouble(), (r) => yExtractor(r.phase2),
      onXY: (x, y, el) => phase2TTs.add("Phase 2: ${y.toString()}"));

  final List<String> phase3TTs = [];
  final List<FlSpot> phase3 = ChartModelBuilder.genericChartData(
      runs, (i, r) => i.toDouble(), (r) => yExtractor(r.phase3),
      onXY: (x, y, el) => phase3TTs.add("Phase 3: ${y.toString()}"));

  return ChartModelBuilder.genericChartModel(
      runs,
      (e) => DateTime.fromMillisecondsSinceEpoch(e.time! * 1000),
      [
        LineChartBar(
            "Full-Fight",
            LineChartBarData(
                spots: fullfight,
                color: ChartModelBuilder.CHART_COLORS.next(),
                isCurved: true),
            tooltips: fullfightTTs),
        LineChartBar(
            "Phase 1",
            LineChartBarData(
                spots: phase1,
                color: ChartModelBuilder.CHART_COLORS.next(),
                isCurved: true),
            tooltips: phase1TTs),
        LineChartBar(
            "Phase 2",
            LineChartBarData(
                spots: phase2,
                color: ChartModelBuilder.CHART_COLORS.next(),
                isCurved: true),
            tooltips: phase2TTs),
        LineChartBar(
            "Phase 3",
            LineChartBarData(
                spots: phase3,
                color: ChartModelBuilder.CHART_COLORS.next(),
                isCurved: true),
            tooltips: phase3TTs),
        //_bossPercent(runs)
      ],
      bottomTitle: const SideTitles(showTitles: false),
      leftTitle:
          SideTitles(showTitles: true, reservedSize: 50, interval: interval));
}
