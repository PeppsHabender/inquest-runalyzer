import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/utils/utils.dart';

class Uploader extends StatelessWidget {
  final TextEditingController _links = TextEditingController();
  final RxBool loading = false.obs;
  final Rx<String> error = "".obs;

  Uploader({super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(() => Column(
          children: [
            Expanded(
              child: TextField(
                enabled: !loading.value,
                controller: _links,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration.collapsed(
                    hintText: "Enter dps report links...",
                    floatingLabelBehavior: FloatingLabelBehavior.always
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(error.value, style: context.textTheme.displayMedium?.copyWith(color: RunalyzerColors.INQUEST_RED)),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: loading.value ? null : () {
                        loading.value = true;
                        doHttpRequest(
                          "/api/process",
                          true,
                          method: HttpMethod.POST,
                          body: _links.text.split("\n"),
                          (status, body) {
                            if(status < 300) _links.text = "";
                            loading.value = false;
                          }
                        );
                      },
                      child: const Text("Upload")
                    ),
                    Visibility(
                        visible: loading.value,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                    )
                  ],
                )
              ],
            )
          ]
      )),
    ),
  );
}