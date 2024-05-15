import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/boon_chart.dart';
import 'package:runalyzer_client/pages/static/controller/healing_barrier_chart.dart';
import 'package:runalyzer_client/pages/static/controller/player_dps_chart.dart';
import 'package:runalyzer_client/pages/static/controller/times_chart.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/random_pool.dart';
import 'package:runalyzer_client/utils/widgets/line_chart.dart';

class StaticPageController extends GetxController {
  static final List<ChartModelBuilder> _CHARTS = [
    TimesChart(),
    PlayerDpsChart(),
    BoonChart(),
    PlayerHBpsChart()
  ];

  final Rx<ChartModel?> chart = Rx(null);
  final RxInt selectedChart = 0.obs;
  final RxInt selectedOverview = 0.obs;

  void selectChart(int chartIdx, final Iterable<StaticAnalysis> analyses,
      final Iterable<String> members, final bool withDate,
      {bool buildWipes = false}) {
    if (chartIdx >= _CHARTS.length) {
      chartIdx = 0;
    }

    selectedChart.value = chartIdx;
    chart.value =
        _CHARTS[chartIdx].build(analyses, members, buildWipes, withDate);
  }

  void selectCustomChart(final int chartIdx, final ChartModel chart) {
    selectedChart.value = chartIdx;
    this.chart.value = chart;
  }
}

abstract class ChartModelBuilder {
  static final PoolRandom<Color> CHART_COLORS = PoolRandom([
    const Color(0xFFFAFAFA),
    const Color(0xFFF06292),
    const Color(0xFFD50000),
    const Color(0xFFAA00FF),
    const Color(0xFF651FFF),
    const Color(0xFF304FFE),
    const Color(0xFF0091EA),
    const Color(0xFF00E5FF),
    const Color(0xFF1DE9B6),
    const Color(0xFF00695C),
    const Color(0xFF00C853),
    const Color(0xFF76FF03),
    const Color(0xFFC6FF00),
    const Color(0xFFFFD600),
    const Color(0xFF8D6E63),
  ]);

  static final DateFormat _MONTH_FMT = DateFormat('MMM');
  static final DateFormat _DATE_FMT = DateFormat("MM/dd/yyyy HH:mm");

  ChartModel build(
      final Iterable<StaticAnalysis> analyses,
      final Iterable<String> members,
      final bool buildWipes,
      final bool withDate);

  @protected
  @nonVirtual
  ChartModel chartModel(final Iterable<StaticAnalysis> analyses,
          final List<LineChartBar> bars,
          {final (double, double)? minMaxY,
          final double tooltipFontSize = 14,
          final SideTitles leftTitle = const SideTitles(showTitles: true),
          final SideTitles? bottomTitle}) =>
      genericChartModel(analyses, (e) => e.start!.date, bars,
          minMaxY: minMaxY,
          tooltipFontSize: tooltipFontSize,
          leftTitle: leftTitle,
          bottomTitle: bottomTitle);

  @protected
  @nonVirtual
  List<FlSpot> chartData(
          final Iterable<StaticAnalysis> analyses,
          final double? Function(StaticAnalysis) yExtractor,
          final bool withDate,
          {final void Function(double, double, StaticAnalysis)? onXY}) =>
      genericChartData(
          analyses,
          (i, e) => withDate
              ? e.start?.date.millisecondsSinceEpoch.toDouble()
              : i.toDouble(),
          yExtractor,
          onXY: onXY);

  static ChartModel genericChartModel<T>(
          final Iterable<T> items,
          final DateTime Function(T) timeExtractor,
          final List<LineChartBar> bars,
          {final (double, double)? minMaxY,
          final double tooltipFontSize = 14,
          final SideTitles? bottomTitle,
          final SideTitles leftTitle =
              const SideTitles(showTitles: true, reservedSize: 50)}) =>
      ChartModel(
          bars: bars
            ..add(LineChartBar(
                RunalyzerLineChart.HIDDEN_ID,
                LineChartBarData(
                  spots: items
                      .map((e) => FlSpot(
                          timeExtractor(e).millisecondsSinceEpoch.toDouble(),
                          0))
                      .toList(),
                  color: Colors.transparent,
                ),
                tooltips: items
                    .map((e) => _DATE_FMT.format(timeExtractor(e)))
                    .toList())),
          bottomTitle: bottomTitle ??
              SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) => Text(_MONTH_FMT.format(
                      DateTime.fromMillisecondsSinceEpoch(val.round())))),
          minMaxY: minMaxY,
          tooltipFontSize: tooltipFontSize,
          leftTitle: leftTitle);

  static List<FlSpot> genericChartData<T>(
          final Iterable<T> analyses,
          final double? Function(int, T) xExtractor,
          final double? Function(T) yExtractor,
          {final void Function(double, double, T)? onXY}) =>
      analyses
          .mapIndexed((idx, e) {
            final double? x = xExtractor(idx, e);
            final double? y = yExtractor(e);

            if (x != null && y != null) onXY?.call(x, y, e);

            return x == null || y == null ? null : FlSpot(x, y);
          })
          .whereType<FlSpot>()
          .toList();
}
