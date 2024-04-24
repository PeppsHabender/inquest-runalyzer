import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';

class PlayerDpsChart extends ChartModelBuilder {
  @override
  ChartModel build(Iterable<StaticRun> runs, Iterable<String> members) {
    ChartModelBuilder.CHART_COLORS.reset();

    final Map<Point<double>, String> tooltips = {};
    final List<FlSpot> compDps = chartData(
        runs,
            (el) => el.analysis!.compDps.roundToDouble(),
        onXY: (x, y, el) => tooltips[Point(x, y)] =
            el.analysis!.compDps.roundToDouble().toString()
    );

    final List<LineChartBar> playerDps = members.map((member) {
      final List<String> tooltips = [];

      return (
        tooltips,
        member,
        chartData(
          runs,
          (el) => el.analysis!.avgDps[member]?.roundToDouble(),
          onXY: (x, y, e) => tooltips.add("${member.characters.takeWhile((c) => c != '.').toString()}: ${e.analysis!.avgDps[member]?.roundToDouble() ?? 0}")
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
        //[LineChartBar(LineChartBarData(spots: compDps, isCurved: true), tooltips: compDpsTts)] +
        playerDps,
        leftTitle: const SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: 2000
        )
    );
  }
}