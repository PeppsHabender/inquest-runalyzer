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
import 'package:runalyzer_client/utils/random_pool.dart';
import 'package:runalyzer_client/utils/widgets/line_chart.dart';

class StaticPageController extends GetxController {
  static final List<ChartModelBuilder> _CHARTS = [
    TimesChart(), PlayerDpsChart(), BoonChart(), PlayerHBpsChart()
  ];

  final Rx<ChartModel?> chart = Rx(null);
  final RxInt selectedTab = 0.obs;

  void selectChart(final int chartIdx, final Iterable<StaticRun> runs,
      final Iterable<String> members) {
    selectedTab.value = chartIdx;
    chart.value = _CHARTS[chartIdx].build(runs, members);
  }
}

abstract class ChartModelBuilder {
  @protected
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

  final DateFormat _MONTH_FMT = DateFormat('MMM');
  final DateFormat _DATE_FMT = DateFormat("MM/dd/yyyy HH:mm");

  ChartModel build(final Iterable<StaticRun> runs, final Iterable<String> members);

  @protected
  @nonVirtual
  ChartModel chartModel(
      final Iterable<StaticRun> runs,
      final List<LineChartBar> bars,
      {
        final (double, double)? minMaxY,
        final double tooltipFontSize = 14,
        final SideTitles leftTitle = const SideTitles(showTitles: true)
      }
      ) => ChartModel(
      bars: bars..add(LineChartBar(
        RunalyzerLineChart.HIDDEN_ID,
        LineChartBarData(
          spots: runs.map((e) => FlSpot(e.analysis!.start!.date.millisecondsSinceEpoch.toDouble(), 0)).toList(),
          color: Colors.transparent,
        ),
        tooltips: runs.map((e) => _DATE_FMT.format(e.analysis!.start!.date)).toList()
      )),
      bottomTitle: SideTitles(
        showTitles: true,
        getTitlesWidget: (val, meta) => Text(_MONTH_FMT.format(DateTime.fromMillisecondsSinceEpoch(val.round())))
      ),
      minMaxY: minMaxY,
      tooltipFontSize: tooltipFontSize,
      leftTitle: leftTitle
  );

  @protected
  @nonVirtual
  List<FlSpot> chartData<T>(
      final Iterable<StaticRun> runs,
      final double? Function(StaticRun) yExtractor,
      {
        final void Function(double, double, StaticRun)? onXY
      }
      ) => runs.map((e) {
    final double x = e.analysis!.start!.date.millisecondsSinceEpoch.toDouble();
    final double? y = yExtractor(e);

    if(y != null) onXY?.call(x, y, e);

    return y == null ? null : FlSpot(x, y);
  }).whereType<FlSpot>().toList();
}