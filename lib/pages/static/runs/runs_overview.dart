import 'package:feather_icons_svg/feather_icons_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/controller/progs_controller.dart';
import 'package:runalyzer_client/controller/static_controller.dart';
import 'package:runalyzer_client/controller/wingman_service.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/entities/tof_progression.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';
import 'package:runalyzer_client/pages/static/runs/data_table.dart';
import 'package:runalyzer_client/pages/static/runs/runs_controller.dart';
import 'package:runalyzer_client/utils/animations/loading_animation.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:runalyzer_client/utils/widgets/scale_to_width.dart';
import 'package:runalyzer_client/utils/widgets/widgets.dart';

class StaticRunOverview<T> extends StatelessWidget {
  static const List<Color> _WINNING_COLORS = [
    Color(0xFFb5a642),
    Color(0xFFc0c0c0),
    Color(0xFFcd7f32)
  ];

  final Static _static;
  final List<T> items;
  final bool loading;
  final StaticRunController _controller;
  final TofProgression? prog;
  final List<(String, Widget Function(T))> additionalItems;

  StaticRunOverview(
      this._static, this.items, this.loading, Iterable<StaticAnalysis> analyses,
      {this.prog, this.additionalItems = const [], super.key})
      : _controller = StaticRunController(analyses);

  bool _isProg() => prog != null;

  @override
  Widget build(BuildContext context) =>
      ObxValue((s) => _runOverview(context, s), _controller.selected);

  Widget _runOverview(final BuildContext context, final RxInt selected) {
    final List<String> members = _static.players;
    if (_controller.analyses.isEmpty) {
      return Container();
    }

    final StaticAnalysis currentRun = _controller.currentRun();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          " Overview for run on ${RunalyzerConstants.PRETTY_DATE_TIME.format(currentRun.start!.date)}",
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        ObxValue((s) => _runSelector(context, s), _controller.selected),
        const SizedBox(height: 10),
        loading
            ? const Center(child: LoadingAnimation())
            : StaggeredGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                children: [
                  _overviewItem(title: "dps", child: _dpsStats(members)),
                  _overviewItem(
                      title: "boons",
                      child: _boonsStats(
                          "Sub", _controller.getSubBoonStats(), 32)),
                  _overviewItem(
                      title: "boon gen",
                      child: _boonsStats(
                          "Player", _controller.getBoonGenerationStats())),
                  ..._controller.hasHBStats()
                      ? [
                          _overviewItem(
                              title: "support",
                              child: _suppStats(_controller.suppStats()))
                        ]
                      : [],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _overviewItem(
                            title: "hall of shame",
                            child: _defStats(_controller.defStats())),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                          child: _overviewItem(
                              title: "bosses",
                              child: _bossStates(_controller.bossStates())))
                    ],
                  ),
                  ...additionalItems.map((e) => _overviewItem(
                      title: e.$1,
                      child: e.$2(items[_controller.selected.value])))
                ],
              )
      ],
    );
  }

  Widget _overviewItem({required final String title, required Widget child}) =>
      Card(
        elevation: 10,
        surfaceTintColor: Colors.grey.shade700,
        child: Stack(
          children: [
            Positioned.fill(
                child: Center(
                    child: ScaleIfNeeded(
              child: waterMark(
                  text: title, color: RunalyzerColors.INQUEST_RED.darker(.45)),
            ))),
            Row(
              children: [
                Expanded(child: ScaleIfNeeded(child: child)),
              ],
            )
          ],
        ),
      );

  Widget _runSelector(
    final BuildContext context,
    final RxInt selected,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buttonBar(
            selected.value,
            buttons: _controller.analyses
                .map((e) => ButtonMeta(
                    RunalyzerConstants.DATE_FMT.format(e.start!.date),
                    onPressed: (idx) => selected.value = idx))
                .toList(),
            borderColor: context.theme.dividerColor,
            selectedBg: RunalyzerColors.INQUEST_RED.darker(),
          ),
          IconButton(
              onPressed: () => prog != null
                  ? Get.find<TofProgController>(tag: _static.id)
                      .loadMoreRuns(prog!)
                  : Get.find<StaticController>().loadMoreRuns(_static),
              icon: const FeatherIcon(FeatherIcons.download))
        ],
      );

  Widget _dpsStats(final List<String> members) {
    final Map<String, double> avgDps = _controller.currentRun().avgDps;
    members.sort((a, b) =>
        ((avgDps.getOrNull(b) ?? 0) - (avgDps.getOrNull(a) ?? 0)).round());

    final List<String> membersWithDps =
        members.where(avgDps.containsKey).toList();

    return RunalyzerDataTable(
      columns: [
        (comparator: null, title: ""),
        stringColumn("Player"),
        ..._isProg()
            ? []
            : [intColumn("Best Boss"), intColumn("Best Boss Dps")],
        intColumn(_isProg() ? "Dps" : "Average Dps")
      ],
      rows: membersWithDps.mapIndexed((idx, e) {
        final BestBoss? bestBoss =
            _isProg() ? null : _controller.getBestBoss(e);

        return RunalyzerRow(cells: [
          RunalyzerCell(data: null, child: _topThreeIcon(idx + 1)),
          RunalyzerCell(data: e, child: Text(e)),
          ..._isProg()
              ? []
              : [
                  RunalyzerCell(
                      data: bestBoss ?? -1,
                      child: WingmanService.fetchBoss(
                          bestBoss?.bossId ?? -1, (boss) => Text(boss.name),
                          fallback: () => const Text("-"))),
                  RunalyzerCell(
                      data: bestBoss?.dps ?? -1,
                      child: Text("(${bestBoss?.dps ?? -1})",
                          style: const TextStyle(fontSize: 13)))
                ],
          RunalyzerCell(
              data: avgDps[e]!.round(),
              child: Text(avgDps[e]!.round().toString()))
        ]);
      }).toList(),
    );
  }
}

Widget _bossName(final int id) =>
    WingmanService.fetchBoss(id, (boss) => Text(boss.name));

Widget _boonsStats(
    final String firstCol, final Map<dynamic, Map<String, double>> boonStats,
    [final double? leadingWidth]) {
  final List<String> boons =
      boonStats.values.expand((e) => e.keys).toSet().toList();

  return RunalyzerDataTable(
    columns: [stringColumn(firstCol), ...boons.map(doubleColumn)],
    rows: boonStats.entries
        .map((e) => RunalyzerRow(cells: [
              RunalyzerCell(
                  data: firstCol,
                  child: SizedBox(
                      width: leadingWidth, child: Text(e.key.toString()))),
              ...e.value.entries.map((e) => RunalyzerCell(
                  data: e.value, child: Text(e.value.toStringAsFixed(2))))
            ]))
        .toList(),
  );
}

Widget _suppStats(final Map<String, SupportStats> suppStats) =>
    RunalyzerDataTable(
        columns: [
          stringColumn("Player"),
          doubleColumn("Healing"),
          doubleColumn("Barrier"),
          intColumn("Condi Cleanse"),
          intColumn("Boonstrips")
        ],
        rows: suppStats.entries
            .map((e) => RunalyzerRow(cells: [
                  RunalyzerCell(data: e.key, child: Text(e.key)),
                  RunalyzerCell(
                      data: e.value.healing,
                      child: Text(e.value.healing.toStringAsFixed(2))),
                  RunalyzerCell(
                      data: e.value.barrier,
                      child: Text(e.value.barrier.toStringAsFixed(2))),
                  RunalyzerCell(
                      data: e.value.condiCleanses,
                      child: Text(e.value.condiCleanses.toString())),
                  RunalyzerCell(
                      data: e.value.boonStrips,
                      child: Text(e.value.boonStrips.toString()))
                ]))
            .toList());

Widget _defStats(final Map<String, DefStats> defStats) => RunalyzerDataTable(
        columns: [
          stringColumn("Player"),
          intColumn("Avg Damage Taken"),
          intColumn("Downstates"),
          intColumn("Deaths")
        ],
        rows: defStats.entries
            .map((e) => RunalyzerRow(cells: [
                  RunalyzerCell(data: e.key, child: Text(e.key)),
                  RunalyzerCell(
                      data: e.value.damageTaken,
                      child: Text("${e.value.damageTaken}")),
                  RunalyzerCell(
                      data: e.value.downstates,
                      child: Text(e.value.downstates.toString())),
                  RunalyzerCell(
                      data: e.value.deaths,
                      child: Text(e.value.deaths.toString())),
                ]))
            .toList());

Widget _bossStates(final Map<int, BossState> bossStates) => RunalyzerDataTable(
    columns: [intColumn("Boss"), intColumn("Success"), intColumn("Fails")],
    rows: bossStates.entries
        .map((e) => RunalyzerRow(cells: [
              RunalyzerCell(data: e.key, child: _bossName(e.key)),
              RunalyzerCell(
                  data: e.value.successUrl == null ? 0 : 1,
                  child: e.value.successUrl == null
                      ? const Icon(Icons.close)
                      : Hyperlink(e.value.successUrl!,
                          text: e.value.successUrl!.substring(
                              e.value.successUrl!.lastIndexOf("/") + 1))),
              RunalyzerCell(
                  data: e.value.failUrls.length,
                  child: e.value.failUrls.isEmpty
                      ? const Text("-")
                      : SingleChildScrollView(
                          child: Column(
                            children: e.value.failUrls
                                .map((e) => Hyperlink(e,
                                    text: e.substring(e.lastIndexOf("/") + 1)))
                                .toList(),
                          ),
                        ))
            ]))
        .toList());

Widget _topThreeIcon(final int place) {
  if (place > 3) return Container();

  final double size = 20 + ((4 - place) * 3);
  final Color color = StaticRunOverview._WINNING_COLORS[place - 1];

  return Padding(
    padding: const EdgeInsets.all(5),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      alignment: Alignment.center,
      width: size,
      height: size,
      child: Text(place.toString(),
          style: TextStyle(
              color: color,
              fontSize: 15 - ((3 - place) * 0.5),
              fontWeight: FontWeight.bold)),
    ),
  );
}
