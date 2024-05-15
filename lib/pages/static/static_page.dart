import 'dart:html';

import 'package:feather_icons_svg/feather_icons_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/controller/progs_controller.dart';
import 'package:runalyzer_client/controller/static_controller.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/entities/tof_progression.dart';
import 'package:runalyzer_client/pages/static/controller/static_page_controller.dart';
import 'package:runalyzer_client/pages/static/editor/static_modifier_dialog.dart';
import 'package:runalyzer_client/pages/static/runs/runs_overview.dart';
import 'package:runalyzer_client/pages/static/static_overview.dart';
import 'package:runalyzer_client/pages/static/static_runs_overview.dart';
import 'package:runalyzer_client/pages/static/tof_runs_overviews.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:runalyzer_client/utils/widgets/adjustable_container.dart';
import 'package:rx_future/rx_future.dart';

import '../../utils/animations/loading_animation.dart';
import '../../utils/storage.dart';
import '../../utils/widgets/widgets.dart';

class StaticPage extends StatelessWidget {
  final StaticController _staticController = Get.find();
  final StaticPageController _staticPageController =
      Get.put(StaticPageController());

  final AssetImage _commanderIcon = RunalyzerAssets.randomCommander();

  StaticPage({super.key}) {
    document.title = "Overview";
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: ObxValue((staticsFuture) => _staticLoader(staticsFuture, context),
            _staticController.staticsFuture),
      );

  Widget _staticLoader(
      RxFuture<List<Static>> staticsFuture, final BuildContext context) {
    if (staticsFuture.value.isLoading || !staticsFuture.value.hasValue) {
      return const Center(child: LoadingAnimation());
    }

    final String? id = Get.parameters[RunalyzerLinks.STATIC_ID];
    final Static? static = id == null ? null : _staticController.forId(id);
    if (static == null) {
      Future.microtask(() => Get.offAndToNamed(RunalyzerLinks.HOME));
      return Container();
    }

    document.title = "${static.name} Overview";

    return Column(
      children: [
        _header(context, static),
        const SizedBox(height: 15),
        Expanded(child:
            _staticPageController.selectedOverview.ReadOnlyDisplay((idx) {
          if (idx == 0) {
            return ObxValue((runs) => _runsLoader(runs, static, context),
                _staticController.lastRuns(static));
          } else {
            final TofProgController progController = Get.find(tag: static.id);
            final TofProgression prog = progController.progs[idx - 1];
            return ObxValue(
                (runs) => _progRunsLoader(prog, runs, static, context),
                progController.runs(prog));
          }
        })),
      ],
    );
  }

  Widget _progRunsLoader(
      final TofProgression prog,
      final RxFuture<List<TofRun>> runsFuture,
      final Static static,
      final BuildContext context) {
    if (runsFuture.value.value.isEmpty && runsFuture.loading) {
      return const LoadingAnimation();
    }

    final List<TofRun> runs = runsFuture.value.value;
    final List<String> members = static.players;

    if (runs.isEmpty) {
      return _runsEmpty(context, static);
    }

    _staticPageController.selectChart(0, runs.toAnalyses(), members, false);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: context.height, maxWidth: context.width),
        child: ListView(children: [
          HeightAdjustableContainer(
            initHeight: 400,
            minHeight: 350,
            child: TofOverview(static, runs),
          ),
          StaticRunOverview<TofRun>(
              static, runs, runsFuture.loading, runs.toAnalyses(),
              prog: prog,
              additionalItems: [
                ("mechanics", (e) => TofOverview.MechanicsTable(e))
              ])
        ]),
      ),
    );
  }

  Widget _runsLoader(final RxFuture<List<StaticRun>> runsFuture,
      final Static static, final BuildContext context) {
    if (runsFuture.value.value.isEmpty && runsFuture.loading) {
      return const LoadingAnimation();
    }

    final List<StaticRun> runs = runsFuture.value.value;
    final List<String> members = static.players;

    _staticPageController.selectChart(_staticPageController.selectedChart.value,
        runs.map((e) => e.analysis).whereType(), members, true);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: context.height, maxWidth: context.width),
        child: ListView(children: [
          HeightAdjustableContainer(
            initHeight: 400,
            minHeight: 350,
            child: StaticOverview(static, runs),
          ),
          StaticRunOverview(static, runs, runsFuture.loading,
              runs.map((e) => e.analysis).whereType())
        ]),
      ),
    );
  }

  Widget _runsEmpty(final BuildContext context, final Static static) => Center(
        child: Column(
          children: [
            Text("No runs found for this static...",
                style: context.textTheme.headlineLarge),
            OutlinedButton(
                onPressed: () => _staticController.resetRuns(static),
                child: const Text("Try again!"))
          ],
        ),
      );

  Widget _header(final BuildContext context, final Static static) {
    final TofProgController progController = Get.find(tag: static.id);

    return Row(
      children: [
        _accName(static, context),
        ...progController.progs.isEmpty
            ? []
            : [
                progController.progs.ReadOnlyDisplay((progs) =>
                    buttonBar(_staticPageController.selectedOverview.value,
                        buttons: [
                          ButtonMeta("Overview",
                              onPressed: (idx) => _staticPageController
                                  .selectedOverview.value = idx),
                          ...progs.mapIndexed((idx, e) => ButtonMeta(
                              "ToF Prog ${idx + 1}",
                              onPressed: (i) => _staticPageController
                                  .selectedOverview.value = i))
                        ],
                        selectedBg: context.theme.primaryColor))
              ],
        const Spacer(),
        Visibility(
          visible: static.userCanUpload() || static.userCanModify(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              onPressed: () => Get.dialog(StaticModifier(static)),
              icon: const FeatherIcon(FeatherIcons.edit),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accName(Static static, BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          waterMark(color: context.theme.canvasColor.darker(0.02)),
          Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(static.name, style: context.textTheme.headlineMedium),
              Row(
                children: [
                  Column(
                    children: [
                      Text(RunalyzerStorage.accountName ?? "",
                          style: const TextStyle(fontSize: 18.5)),
                    ],
                  ),
                  const SizedBox(width: 5),
                  static.userCanUpload() || static.userCanModify()
                      ? Image(width: 30, height: 30, image: _commanderIcon)
                      : const Text("")
                ],
              ),
            ],
          ))
        ],
      );
}
