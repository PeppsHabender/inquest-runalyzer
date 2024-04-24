import 'package:get/get.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/static_run.dart';

import '../../entities/logs.dart';

class LogsModel {
  final RxList<DpsReport> recentLogs = <DpsReport>[].obs;
  final RxBool loading = false.obs;
  final RxBool canLoadMore = false.obs;
  final RxBool hasMore = true.obs;
}

class StaticsModel {
  final RxList<Static> statics = <Static>[].obs;
  final RxMap<Static, StaticRun> lastRun = <Static, StaticRun>{}.obs;
  final RxBool loading = false.obs;
}