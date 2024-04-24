import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';

class PlayerHBpsChart extends ChartModelBuilder {
  @override
  ChartModel build(Iterable<StaticRun> runs, Iterable<String> members) {
    ChartModelBuilder.CHART_COLORS.reset();

    final List<LineChartBar> playerHB = members.map((member) {
      final List<String> tooltips = [];

      return (
      tooltips,
      member,
      chartData(
          runs,
          (el) {
            final (double?, double?) hb = healingBarrier(el, member);

            return hb.$1 == null ? hb.$2 : (hb.$1! + (hb.$2  ?? .0));
          },
          onXY: (x, y, e) {
            final (double?, double?) hb = healingBarrier(e, member);
            var tooltip = member.characters.takeWhile((c) => c != '.').toString();
            if(hb.$1 != null) {
              tooltip += " H: ${hb.$1}";
            }

            if(hb.$1 != null) {
              tooltip += " B: ${hb.$2}";
            }

            tooltips.add(tooltip);
          }
      )
      );
    }).map((e) =>
        LineChartBar(
            e.$2,
            LineChartBarData(
              spots: e.$3,
              isCurved: true,
              color: ChartModelBuilder.CHART_COLORS.next(),
            ),
            tooltips: e.$1
        )
    ).toList();

    return chartModel(
        runs,
        playerHB,
        leftTitle: const SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 500
        )
    );
  }
}

(double?, double?) healingBarrier(final StaticRun run, final String member) {
  final DefensiveStats? defStats = run.analysis!.defensiveStats.firstWhereOrNull((e) => e.player == member);

  return (defStats?.healing?.roundToDouble(), defStats?.barrier?.roundToDouble());
}