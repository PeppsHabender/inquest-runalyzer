import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';

class TimesChart extends ChartModelBuilder {
  @override
  ChartModel build(Iterable<StaticRun> runs, Iterable<String> members) {
    ChartModelBuilder.CHART_COLORS.reset();

    final List<String> durationTts = [];
    final List<FlSpot> duration = chartData(
        runs, (el) => el.analysis?.duration.toDouble(),
        onXY: (x, y, el) => durationTts.add(Duration(seconds: el.analysis!.duration).pretty())
    );
    final List<String> downtimeTts = [];
    final List<FlSpot> downtime = chartData(
        runs,
        (el) => el.analysis?.downtime.toDouble(),
        onXY: (x, y, el) => downtimeTts.add(Duration(seconds: el.analysis!.downtime).pretty())
    );

    return chartModel(
      runs,
      [
        LineChartBar("Duration", LineChartBarData(spots: duration, isCurved: true), tooltips: durationTts),
        LineChartBar(
          "Downtime",
          LineChartBarData(
              spots: downtime,
              isCurved: true,
              color: RunalyzerColors.INQUEST_RED
          ),
          tooltips: downtimeTts
        )
      ],
      leftTitle: SideTitles(
        getTitlesWidget: (y, meta) => Text(Duration(seconds: y.round()).pretty()),
        showTitles: true,
        reservedSize: 90,
        interval: 1200
      )
    );
  }
}