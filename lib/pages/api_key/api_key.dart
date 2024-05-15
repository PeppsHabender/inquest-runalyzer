import 'dart:html';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/pages/api_key/controller.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:runalyzer_client/utils/widgets/rx_text_field.dart';
import 'package:runalyzer_client/utils/widgets/widgets.dart';

class ApiKeyPage extends StatelessWidget {
  final ApiKeyController _controller = Get.put(ApiKeyController());

  ApiKeyPage({super.key}) {
    document.title = "Api Key";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          waterMark(
              color: Theme.of(context).canvasColor.darker(0.02), fontSize: 150),
          Center(
            child: SizedBox(
              width: 600,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _cardHeader(),
                      const SizedBox(
                        height: 20,
                      ),
                      RxTextField(
                        text: _controller.apiKey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: _TryKeyButton()),
                      _ErrorMessage()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: visibleLoading(_controller.loading),
    );
  }

  Widget _cardHeader() => const Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          "Add your Gw2 Api Key to continue...",
          style: TextStyle(fontSize: 20),
        ),
      );
}

class _TryKeyButton extends StatelessWidget {
  final ApiKeyController _controller = Get.find();

  @override
  Widget build(BuildContext _) => Obx(
        () => OutlinedButton(
            onPressed:
                _controller.canLoad() ? _controller.tryAuthenticating : null,
            child: const Text("Add API Key")),
      );
}

class _ErrorMessage extends StatelessWidget {
  final ApiKeyController _controller = Get.find();

  @override
  Widget build(BuildContext context) => ObxValue(
      (message) => Visibility(
          visible: message.value != null,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  message.value ?? "",
                  style: const TextStyle(color: RunalyzerColors.INQUEST_RED),
                ),
              ),
            ],
          )),
      _controller.errMessage);
}
