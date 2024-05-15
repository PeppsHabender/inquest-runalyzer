import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';
import 'package:runalyzer_client/pages/static/static_overview.dart';

class StaticOverview extends StaticOverviewBase {
  StaticOverview(final Static static, final List<StaticRun> runs, {super.key})
      : super(static, runs.map((e) => e.analysis).whereType());

  @override
  bool buildWithDate() => true;
}
