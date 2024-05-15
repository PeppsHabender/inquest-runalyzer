import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/pages/static/chart_model.dart';
import 'package:runalyzer_client/utils/extensions.dart';

class RunalyzerLineChart extends StatelessWidget {
  static const String HIDDEN_ID = "%HIDDEN%";

  final ChartModel _model;
  final List<VerticalLine> Function(double, double)? _verticalLines;

  final RxSet<String> _unselected = RxSet();

  RunalyzerLineChart(this._model,
      {List<VerticalLine> Function(double, double)? verticalLines, super.key})
      : _verticalLines = verticalLines;

  @override
  Widget build(BuildContext context) {
    return ObxValue((unselected) {
      if (unselected.contains(HIDDEN_ID)) unselected.remove(HIDDEN_ID);

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _selectionBoxes(_model, unselected)),
              _selectAllButtons(_model, unselected)
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
              child:
                  _theLineChart(context, _model, unselected, _verticalLines)),
        ],
      );
    }, _unselected);
  }
}

Widget _selectionBoxes(final ChartModel model, final Set<String> unselected) =>
    Wrap(
      direction: Axis.horizontal,
      children: model.bars
          .where((e) => e.id != RunalyzerLineChart.HIDDEN_ID)
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: !unselected.contains(e.id),
                    onChanged: (_) => unselected.contains(e.id)
                        ? unselected.remove(e.id)
                        : unselected.add(e.id),
                    activeColor: e.data.color,
                    side: BorderSide(
                        color: e.data.color ?? Colors.white, width: 1.5),
                  ),
                  Text(e.id),
                  const SizedBox(width: 15)
                ],
              ))
          .toList(),
    );

Widget _selectAllButtons(
        final ChartModel model, final Set<String> unselected) =>
    Row(
      children: [
        IconButton(
            onPressed: () => unselected.clear(),
            icon: const Icon(Icons.select_all_outlined)),
        IconButton(
            onPressed: () => unselected.addAll(model.bars.map((e) => e.id)),
            icon: const Icon(Icons.deselect_outlined))
      ],
    );

Widget _theLineChart(
  final BuildContext context,
  final ChartModel model,
  final Set<String> unselected,
  final List<VerticalLine> Function(double, double)? verticalLines,
) {
  final minMaxXMinMaxY = model.minXMaxXminYMaxY();
  final double deltaX = (minMaxXMinMaxY.$2 - minMaxXMinMaxY.$1) / 20;
  final double deltaY = (minMaxXMinMaxY.$4 - minMaxXMinMaxY.$3) / 20;

  double maxY = minMaxXMinMaxY.$4 + deltaY;
  double minY = minMaxXMinMaxY.$3 - deltaY;
  final double? yInt = model.leftTitle.interval;
  if (yInt != null) maxY = maxY + (yInt - (maxY % yInt));
  if (yInt != null) minY = max(minY - (minY % yInt), 0);

  return LineChart(
    LineChartData(
        minX: minMaxXMinMaxY.$1 - deltaX,
        maxX: minMaxXMinMaxY.$2 + deltaX,
        minY: model.minMaxY?.$1 ?? minY,
        maxY: model.minMaxY?.$2 ?? maxY,
        lineBarsData: model.bars
            .where((e) => !unselected.contains(e.id))
            .map((el) => el.data)
            .toList(),
        extraLinesData: ExtraLinesData(
            extraLinesOnTop: false,
            horizontalLines: model.bars
                .where((e) => e.drawAverage && !unselected.contains(e.id))
                .where((e) => e.averageY != null)
                .map((e) => HorizontalLine(
                    y: e.averageY!,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    color: e.data.color?.withAlpha(160)))
                .toList(),
            verticalLines:
                verticalLines?.call(minMaxXMinMaxY.$1, minMaxXMinMaxY.$2) ??
                    []),
        titlesData: _titles(model),
        borderData: FlBorderData(border: Border.all(style: BorderStyle.none)),
        lineTouchData: _touchData(context, model, unselected),
        gridData: FlGridData(
            show: true,
            verticalInterval: model.bottomTitle.interval,
            horizontalInterval: model.leftTitle.interval)),
    duration: Duration.zero,
  );
}

FlTitlesData _titles(final ChartModel model) => FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
          sideTitles: model.bottomTitle.copyWith(
              getTitlesWidget: (x, meta) => x == meta.min || x == meta.max
                  ? const Text("")
                  : model.bottomTitle.getTitlesWidget(x, meta))),
      leftTitles: AxisTitles(sideTitles: model.leftTitle),
    );

LineTouchData _touchData(final BuildContext context, final ChartModel model,
        final Set<String> unselected) =>
    LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            maxContentWidth: 200,
            getTooltipColor: (_) => context.theme.canvasColor.darker(),
            getTooltipItems: (ls) {
              return ls.indexed.map((e) {
                final LineChartBar bar = model.bars
                    .where((e) => !unselected.contains(e.id))
                    .toList()[e.$2.barIndex];
                if (bar.tooltips == null) {
                  return null;
                }

                final String? tooltip = e.$2.spotIndex < bar.tooltips!.length
                    ? bar.tooltips![e.$2.spotIndex]
                    : null;
                if (tooltip == null) {
                  return null;
                }

                return LineTooltipItem(
                    tooltip,
                    TextStyle(
                      color: bar.id == RunalyzerLineChart.HIDDEN_ID
                          ? Colors.white
                          : e.$2.bar.gradient?.colors.first ??
                              e.$2.bar.color ??
                              Colors.blueGrey,
                      fontWeight: bar.id == RunalyzerLineChart.HIDDEN_ID
                          ? FontWeight.bold
                          : null,
                      fontSize: model.tooltipFontSize,
                    ));
              }).toList();
            }));
