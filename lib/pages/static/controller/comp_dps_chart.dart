import 'package:fl_chart/fl_chart.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';

class CompDpsChart extends ChartModelBuilder {
  @override
  ChartModel build(Iterable<StaticAnalysis> analyses, Iterable<String> members,
      bool _, final bool withDate) {
    ChartModelBuilder.CHART_COLORS.reset();

    final List<String> compDpsTts = [];
    final List<FlSpot> compDps = chartData(
        analyses, (el) => el.compDps.roundToDouble(), withDate,
        onXY: (x, y, el) =>
            compDpsTts.add(el.compDps.roundToDouble().toString()));

    // TODO: implement build
    throw UnimplementedError();
  }
}
