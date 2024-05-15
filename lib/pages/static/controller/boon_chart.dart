import 'package:fl_chart/fl_chart.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';
import 'package:runalyzer_client/utils/extensions.dart';

class BoonChart extends ChartModelBuilder {
  @override
  ChartModel build(Iterable<StaticAnalysis> analyses, Iterable<String> _,
      bool buildWipes, final bool withDate) {
    ChartModelBuilder.CHART_COLORS.reset();

    final Map<StaticAnalysis, Map<String, double>> boonAvg =
        analyses.associateBy((e) =>
            (e, _boonAvg([...buildWipes ? e.wipes : [], ...e.successful])));
    final Set<String> boons = boonAvg.values.expand((e) => e.keys).toSet();

    final List<LineChartBar> boonBars = boons
        .map((boon) {
          final List<String> tooltips = [];
          return (
            tooltips,
            boon,
            chartData(analyses, (e) => boonAvg[e]?[boon], withDate,
                onXY: (x, y, _) =>
                    tooltips.add("$boon: ${y.toStringAsFixed(2)}"))
          );
        })
        .map((e) => LineChartBar(
            e.$2,
            LineChartBarData(
              spots: e.$3,
              isCurved: true,
              color: ChartModelBuilder.CHART_COLORS.next(),
              barWidth: 1.5,
            ),
            drawAverage: false,
            tooltips: e.$1))
        .toList();

    return chartModel(analyses, boonBars,
        tooltipFontSize: 12.5,
        leftTitle: const SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: 25,
        ),
        bottomTitle: withDate ? null : const SideTitles(showTitles: false),
        minMaxY: (0, 100));
  }
}

Map<String, double> _boonAvg(final List<RunLog> logs) =>
    _boonAvgMaps(logs.map((e) => e.playerBoonStats).map((e) {
      final Map<String, double> acc = {};
      for (BoonStats stats in e) {
        stats.boons.indexed.forEach((e) {
          final double uptime = stats.uptime[e.$1];
          acc.update(e.$2, (v) => v + uptime, ifAbsent: () => uptime);
        });
      }

      return acc..updateAll((_, v) => v / e.length);
    }));

Map<String, double> _boonAvgMaps(final Iterable<Map<String, double>> maps) =>
    maps.reduce((acc, e) {
      e.forEach((k, v) {
        if (!acc.containsKey(k)) return;

        acc.update(k, (value) => value + v);
      });
      return acc;
    })
      ..updateAll((_, v) => v / maps.length);
