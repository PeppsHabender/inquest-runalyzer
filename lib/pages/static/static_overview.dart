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

class StaticOverview extends StatelessWidget {
  final StaticPageController _controller = Get.find();
  final Static _static;
  final List<StaticRun> _staticRuns;

  StaticOverview(this._static, this._staticRuns, {super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> members = _static.players;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ObxValue((s) => _chartSelector(context, s, _staticRuns, members), _controller.selectedTab)
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
            child: ObxValue(_theChart, _controller.chart),
          ),
        ),
      ],
    );
  }

  Widget _chartSelector(
    final BuildContext context,
    final RxInt selected,
    final List<StaticRun> runs,
    final List<String> members
  ) => buttonBar(
    selected.value,
    buttons: [
      ButtonMeta("Time", onPressed: (idx) => _controller.selectChart(idx, runs, members)),
      ButtonMeta("Dps", onPressed: (idx) => _controller.selectChart(idx, runs, members)),
      ButtonMeta("Boons", onPressed: (idx) => _controller.selectChart(idx, runs, members)),
      ButtonMeta("H/Bps", onPressed: (idx) => _controller.selectChart(idx, runs, members))
    ],
    borderColor: context.theme.dividerColor,
    selectedBg: RunalyzerColors.INQUEST_RED.darker(),
  );

  Widget _theChart(final Rx<ChartModel?> chart) {
    if (chart.value == null) {
      return Container();
    }

    return RunalyzerLineChart(
      chart.value!,
      verticalLines: (minX, maxX) => WingmanService.PATCHES
        .where((e) => e.date.millisecondsSinceEpoch > minX && e.date.millisecondsSinceEpoch < maxX)
        .map(_patchLine).toList()
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
      labelResolver: (_) => patch.name
    )
  );
}