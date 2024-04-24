import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

class ChartModel {
  final List<LineChartBar> bars;
  final SideTitles leftTitle;
  final SideTitles bottomTitle;
  final double tooltipFontSize;
  final (double, double)? minMaxY;

  const ChartModel({
    this.bars = const [],
    this.leftTitle = const SideTitles(),
    this.bottomTitle = const SideTitles(),
    this.tooltipFontSize = 14,
    this.minMaxY
  });

  (double, double, double, double) minXMaxXminYMaxY() {
    final Iterable<LineChartBarData> unzipped = bars.map((el) => el.data);
    final (double, double) minMaxX = _combineMinMax(unzipped.map((el) => _findMinMax(el.spots, (s) => s.x)));
    final (double, double) minMaxY = this.minMaxY ?? _combineMinMax(unzipped.map((el) => _findMinMax(el.spots, (s) => s.y)));

    return (minMaxX.$1, minMaxX.$2, minMaxY.$1, minMaxY.$2);
  }
}

class LineChartBar {
  final String id;
  final LineChartBarData data;
  final List<String>? tooltips;

  late final double? averageY;
  final bool drawAverage;

  LineChartBar(this.id, this.data, {this.tooltips, this.drawAverage = true}) {
    if(data.spots.isEmpty) {
      averageY = null;
      return;
    }

    averageY = data.spots.map((e) => e.y).reduce((a, b) => a + b) / data.spots.length;
  }
}

(double, double) _combineMinMax(Iterable<(double, double)> ls) => ls.reduce((acc, curr) => (min(acc.$1, curr.$1), max(acc.$2, curr.$2)));

(double, double) _findMinMax(Iterable<FlSpot> ls, double Function(FlSpot) extractor) => ls.fold(
  (double.infinity, double.negativeInfinity),
  (minMax, curr) {
    final double currVal = extractor(curr);
    return (min(minMax.$1, currVal), max(minMax.$2, currVal));
  }
);