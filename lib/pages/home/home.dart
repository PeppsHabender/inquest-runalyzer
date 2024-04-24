import 'dart:html';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/entities/logs.dart';
import 'package:runalyzer_client/pages/home/controller.dart';
import 'package:runalyzer_client/pages/home/statics.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/storage.dart';
import 'package:runalyzer_client/utils/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  final LogsController _logsController = Get.put(LogsController());

  HomePage({super.key}) {
    document.title = "Dashboard";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _accName(context),
              const Flex(direction: Axis.horizontal)
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecentLogView(),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                child: StaticView(),
              )
            ],
          )
        ],
      ),
      floatingActionButton: visibleLoading(_logsController.model.loading),
    );
  }

  Widget _accName(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      waterMark(color: Theme.of(context).canvasColor.darker(0.02)),
      Center(child: Text(RunalyzerStorage.accountName ?? "", style: const TextStyle(fontSize: 18.5)))
    ],
  );
}

class RecentLogView extends StatelessWidget {
  final LogsController _controller = Get.find();

  RecentLogView({super.key}) {
    _controller.loadMoreLogs();
  }

  @override
  Widget build(BuildContext _) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your latest logs:", style: TextStyle(fontSize: 17)),
        const Divider(),
        Obx(() => ListView.separated(
          separatorBuilder: (_, idx) => const SizedBox(height: 5),
          shrinkWrap: true,
          itemCount: _controller.model.recentLogs.length,
          itemBuilder: (_, idx) {
            final DpsReport log = _controller.model.recentLogs[idx];
            return Align(alignment: Alignment.centerLeft, child: Hyperlink(log.permalink));
          },
        )),
        Center(
          child: Obx(() => Visibility(
            visible: _controller.model.hasMore.value,
            child: OutlinedButton(
              onPressed: _controller.model.loading.value ? null : _controller.loadMoreLogs,
              child: const Text("Load More"),
            ),
          )),
        )
      ],
    ),
  );
}