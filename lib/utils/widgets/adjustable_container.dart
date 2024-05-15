import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeightAdjustableContainer extends StatelessWidget {
  final double minHeight;

  final RxDouble initHeight;
  final RxDouble height;
  final Widget child;

  HeightAdjustableContainer(
      {required double initHeight,
      required this.child,
      double? minHeight,
      super.key})
      : height = initHeight.obs,
        initHeight = initHeight.obs,
        minHeight = minHeight ?? initHeight;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ObxValue(
              (h) => SizedBox(height: max(h.value, minHeight), child: child),
              height),
          GestureDetector(
              onVerticalDragEnd: (details) => initHeight.value = height.value,
              onVerticalDragUpdate: (details) =>
                  height.value = initHeight.value + details.localPosition.dy,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeRow,
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 8),
                      child: Container(height: 2, color: Colors.white38),
                    )),
                    const MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Icon(Icons.height_outlined, size: 25)),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 15, left: 8),
                      child: Container(height: 2, color: Colors.white38),
                    )),
                  ],
                ),
              )),
        ],
      );
}
