import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/controller/wingman_service.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:runalyzer_client/utils/widgets/line_chart.dart';
import 'package:runalyzer_client/utils/widgets/widgets.dart';

import 'chart_model.dart';

abstract class StaticOverviewBase extends StatelessWidget {
  final StaticPageController _controller = Get.find();
  final Static _static;
  final Iterable<StaticAnalysis> _analyses;

  StaticOverviewBase(this._static, this._analyses, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> members = _static.players;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: _controller.selectedChart.ReadOnlyDisplay(
                (s) => _chartSelector(context, s, _analyses, members))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
            child: _controller.chart.ReadOnlyDisplay((chart) =>
                WingmanService.PATCHES.ReadOnlyDisplay((patches) =>
                    _theChart(chart, patches.hasValue ? patches.value : []))),
          ),
        ),
      ],
    );
  }

  Widget _chartSelector(
          final BuildContext context,
          final int selected,
          final Iterable<StaticAnalysis> analyses,
          final List<String> members) =>
      buttonBar(
        selected,
        buttons: [
          ButtonMeta("Time",
              onPressed: (idx) => _controller.selectChart(
                  idx, analyses, members, buildWithDate(),
                  buildWipes:
                      Get.find<StaticPageController>().selectedOverview.value >
                          0)),
          ButtonMeta("Dps",
              onPressed: (idx) => _controller.selectChart(
                  idx, analyses, members, buildWithDate(),
                  buildWipes:
                      Get.find<StaticPageController>().selectedOverview.value >
                          0)),
          ButtonMeta("Boons",
              onPressed: (idx) => _controller.selectChart(
                  idx, analyses, members, buildWithDate(),
                  buildWipes:
                      Get.find<StaticPageController>().selectedOverview.value >
                          0)),
          ButtonMeta("H/Bps",
              onPressed: (idx) => _controller.selectChart(
                  idx, analyses, members, buildWithDate(),
                  buildWipes:
                      Get.find<StaticPageController>().selectedOverview.value >
                          0)),
          ...additionalCharts().map((e) => ButtonMeta(e.$1,
              onPressed: (idx) => _controller.selectCustomChart(idx, e.$2())))
        ],
        borderColor: context.theme.dividerColor,
        selectedBg: RunalyzerColors.INQUEST_RED.darker(),
      );

  bool buildWithDate();

  Iterable<(String, ChartModel Function())> additionalCharts() => [];

  Widget _theChart(final ChartModel? chart, final List<Gw2Patch> patches) {
    if (chart == null) {
      return Container();
    }

    return RunalyzerLineChart(
      chart,
      verticalLines: (minX, maxX) => patches
          .where((e) =>
              e.date.millisecondsSinceEpoch > minX &&
              e.date.millisecondsSinceEpoch < maxX)
          .map(_patchLine)
          .toList(),
    );
  }

  VerticalLine _patchLine(final Gw2Patch patch) => VerticalLine(
      x: patch.date.millisecondsSinceEpoch.toDouble(),
      color: Colors.white,
      strokeWidth: 0.7,
      label: VerticalLineLabel(
          show: true,
          direction: LabelDirection.vertical,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
          labelResolver: (_) => patch.name));
}
