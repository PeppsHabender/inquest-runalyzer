import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';

class RxTextField extends StatelessWidget {
  final String label;
  final String errorText;
  final int? maxChars;

  final RxString text;
  final RxBool erroneous;
  final bool Function(String) validator;

  late final TextEditingController _controller;

  final RxBool? enabled;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlignVertical? textAlignVertical;
  final FocusNode? focusNode;

  RxTextField({
    super.key,
    this.label = "",
    this.errorText = "",
    this.maxChars,
    RxString? text,
    RxBool? erroneous,
    this.enabled,
    this.decoration,
    this.style,
    this.textAlignVertical,
    this.focusNode,
    bool Function(String)? validator
  }) : text = text ?? "".obs,
        erroneous = erroneous ?? validator?.call(text?.value ?? "").notObs() ?? false.obs,
        validator = validator ?? ((_) => true)
  {
    _controller = TextEditingController(text: this.text.value);
  }

  @override
  Widget build(final BuildContext context) => Obx(() => TextField(
    controller: _controller,
    onChanged: (text) {
      this.text.value = text;
      erroneous.value = !validator(text);
    },
    decoration: InputDecoration(
      label: Text(label),
      errorText: erroneous.value ? "" : null,
      errorStyle: const TextStyle(height: 0),
      errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: RunalyzerColors.INQUEST_RED)),
      border: const OutlineInputBorder()
    ),
    inputFormatters: [LengthLimitingTextInputFormatter(maxChars)],
  ));
}