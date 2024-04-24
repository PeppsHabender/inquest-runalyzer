import 'package:feather_icons_svg/feather_icons_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:runalyzer_client/controller/static_controller.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:rx_future/rx_future.dart';

class StaticView extends StatelessWidget {
  final StaticController _statics = Get.find();

  StaticView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final RxFuture<List<Static>> staticsFuture = _statics.staticsFuture;

    if(staticsFuture.loading) {
      return const Center(child: SizedBox(width: 50, height: 50,  child: CircularProgressIndicator()));
    }

    final List<Static> statics = staticsFuture.value.value;

    return MasonryGridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: statics.length,
      itemBuilder: (_, idx) {
        final RxBool hovered = false.obs;
        final Static static = statics[idx];

        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () => Get.offAndToNamed(RunalyzerLinks.STATIC, parameters: {RunalyzerLinks.STATIC_ID: static.id}),
          onHover: (h) => hovered.value = h,
          child: Obx(() => AnimatedScale(
            alignment: FractionalOffset.center,
            scale: hovered.value ? 0.9 : 1,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 100),
            child: StaticCard(static),
          )),
        );
      },
    );
  });
}

class StaticCard extends StatelessWidget {
  static final DateFormat FORMAT = DateFormat("dd.MM.yyyy HH:mm");
  
  final StaticController _statics = Get.find();
  final Static _static;

  StaticCard(this._static, {super.key});

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_static.name, style: context.textTheme.headlineMedium),
          const Divider(),
          Obx(() {
            final StaticRun? run = _statics.lastRun(_static);
            return run == null
              ? (_statics.loadingStatics.contains(_static.id)
                ? const Center(child: CircularProgressIndicator())
                : const Text("No runs found for this static..."))
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Latest Run:", style: context.textTheme.bodyLarge),
                  _runView(context, run),
                ],
              );
          })
        ],
      ),
    ),
  );
  
  Widget _runView(final BuildContext context, final StaticRun run) {
    final StaticAnalysis? analysis = run.analysis;
    if(analysis == null || analysis.start == null) return Container();

    return Column(
      children: [
        Row(
          children: [
            const FeatherIcon(FeatherIcons.clock, size: 17),
            const SizedBox(width: 5),
            Text(FORMAT.format(analysis.start!.date.toLocal())),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const FeatherIcon(FeatherIcons.checkCircle, size: 17),
            const SizedBox(width: 5),
            Text(FORMAT.format(analysis.end!.date.toLocal())),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, size: 17),
                const SizedBox(width: 5),
                Text(Duration(seconds: analysis.duration).pretty())
              ],
            ),
            Row(
              children: [
                Text(Duration(seconds: analysis.downtime).pretty()),
                const SizedBox(width: 5),
                const Icon(Icons.timer_off, size: 17),
              ],
            )
          ],
        ),
        const SizedBox(height: 5),
        Text(_quickAnalysis(analysis), style: context.textTheme.bodyMedium?.copyWith(fontSize: 15), textAlign: TextAlign.justify)
      ],
    );
  }

  String _quickAnalysis(StaticAnalysis analysis) {
    final int success = analysis.successful.length;
    final int fails = analysis.wipes.length;

    String quickAnalysis = "Run completed with";
    if(success != 0) quickAnalysis += " $success successful";
    if(success != 0 && fails != 0) quickAnalysis += " and";
    if(fails != 0) quickAnalysis += " $fails failed";

    return "$quickAnalysis encounters, and an average time per boss of "
        "${Duration(milliseconds: (analysis.averageTimePerBoss * 1000).round()).pretty()}.";
  }
}