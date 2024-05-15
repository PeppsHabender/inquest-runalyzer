import 'dart:js';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/utils/animations/loading_animation.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';

Widget waterMark(
        {Color color = RunalyzerColors.INQUEST_RED,
        double fontSize = 100,
        String text = "[INQ]"}) =>
    Text(
      text,
      style:
          TextStyle(fontFamily: "Megatron", fontSize: fontSize, color: color),
    );

Widget visibleLoading(RxBool loading) => ObxValue(
    (l) => Visibility(
          visible: l.value,
          child: const LoadingAnimation(),
        ),
    loading);

class Hyperlink extends StatelessWidget {
  final Rx<TextStyle> _style;
  final String? _text;
  final String _link;

  Hyperlink(this._link,
      {super.key, String? text, TextStyle style = const TextStyle()})
      : _text = text,
        _style = style.obs;

  @override
  Widget build(BuildContext _) => InkWell(
        hoverColor: Colors.transparent,
        onTap: () {
          context.callMethod("open", [_link]);
          _style.value = _style.value
              .copyWith(color: RunalyzerColors.INQUEST_RED.darker());
        },
        onHover: (h) {
          _style.value = _style.value.copyWith(
              decoration: h ? TextDecoration.underline : TextDecoration.none);
        },
        child: Obx(() => Text(_text ?? _link, style: _style.value)),
      );
}

Widget buttonBar(
  final int selected, {
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  final List<ButtonMeta> buttons = const [],
  final Color selectedBg = Colors.cyan,
  final Color borderColor = Colors.white,
}) =>
    Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(50)),
        border: Border.all(color: borderColor).withoutLeft(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: buttons.indexed
                .map((e) => IntrinsicWidth(
                      child: InkWell(
                        onTap: e.$1 == selected
                            ? null
                            : () => e.$2.onPressed?.call(e.$1),
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            color: e.$1 == selected ? selectedBg : null,
                            child: Text(e.$2.text,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );

class ButtonMeta {
  final String text;
  final void Function(int idx)? onPressed;

  const ButtonMeta(this.text, {this.onPressed});
}

extension RxExtensions<T> on Rx<T> {
  Widget ReadOnlyDisplay(Widget Function(T) builder, {Key? key}) =>
      ObxValue((v) => builder(v.value), this);

  Widget Display(Widget Function(T, void Function(T) write) builder,
          {Key? key}) =>
      ObxValue((v) => builder(v.value, (newV) => value = newV), this);
}

extension RxListExtensions<T> on RxList<T> {
  Widget ReadOnlyDisplay(Widget Function(List<T>) builder, {Key? key}) =>
      ObxValue((v) => builder(v), this);

  Widget Display(
          Widget Function(List<T>, void Function(T) add,
                  void Function(T) remove, void Function(RxList<T>) write)
              builder,
          {Key? key}) =>
      ObxValue(
          (value) =>
              builder(value, (v) => add(v), (v) => remove(v), (v) => value = v),
          this);
}
