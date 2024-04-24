import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef SizedWidget = Widget Function(Size);

class Resizable extends StatefulWidget {
  final SizedWidget firstWidget;
  final SizedWidget secondWidget;
  final double initialWidth;
  final double maxWidth;
  final double minWidth;
  const Resizable({
    super.key,
    required this.firstWidget,
    required this.secondWidget,
    this.initialWidth = 250,
    this.maxWidth = 300,
    this.minWidth = 200,
  }) : assert(maxWidth > initialWidth &&
      initialWidth >= minWidth &&
      maxWidth > minWidth);

  @override
  State<Resizable> createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  late double sec2Width = widget.initialWidth;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, cs) => widget.firstWidget(
              Size(cs.maxWidth, cs.maxHeight),
            ),
          ),
        ),
        GestureDetector(
          onPanUpdate: onPanUpdate,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: Container(
              color: Colors.blue,
              width: context.width,
              height: 4,
            ),
          ),
        ),
        SizedBox(
          height: sec2Width,
          width: context.width,
          child: LayoutBuilder(
            builder: (context, cs) => widget.secondWidget(
              Size(cs.maxWidth, cs.maxHeight),
            ),
          ),
        )
      ],
    );
  }

  onPanUpdate(DragUpdateDetails details) {
    var moved = details.delta.dx;

    if (sec2Width <= widget.minWidth) {
      if (moved == 0.0 || moved.isNegative) {
        setState(() {
          sec2Width += -moved;
        });
      }
    } else if (sec2Width >= widget.maxWidth) {
      if (moved == 0.0 || !moved.isNegative) {
        setState(() {
          sec2Width += -moved;
        });
      }
    } else {
      setState(() {
        sec2Width += -moved;
      });
    }
  }
}