import 'dart:convert';

import 'package:get/get.dart';
import 'package:runalyzer_client/entities/logs.dart';
import 'package:runalyzer_client/pages/home/model.dart';
import 'package:runalyzer_client/utils/utils.dart';

import '../../entities/helper.dart';

class LogsController extends GetxController {
  final LogsModel model = LogsModel();

  int _page = 0;

  void loadMoreLogs() {
    if(!model.hasMore.value || model.loading.value) return;

    model.loading.value = true;

    doHttpRequest("/api/logs", true, _addNewLogs, queryParams: {"page":_page.toString()});
  }

  void _addNewLogs(int status, String body) {
    model.loading.value = false;
    if(status > 200) return;

    final Page<DpsReport> page = Page<DpsReport>.fromJson(jsonDecode(body) as Map<String, dynamic>, DpsReport.fromJson);
    model.recentLogs.value = page.items..addAll(model.recentLogs);
    model.hasMore.value = page.hasMore;

    _page++;
  }
}