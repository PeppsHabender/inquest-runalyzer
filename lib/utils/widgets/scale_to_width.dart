import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ScaleIfNeeded extends StatelessWidget {
  final Widget _child;
  final Key _childKey = UniqueKey();

  final Rx<Size?> _size = (null as Size?).obs;

  ScaleIfNeeded({required Widget child, super.key}) : _child = child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constr) => Obx(() => _theWidget(constr)));
  }

  Widget _theWidget(final BoxConstraints constraints) {
    final Size? size = _size.value;

    if (size == null) {
      return _unconstrainedRender();
    }

    if (size.width <= constraints.maxWidth &&
        size.height <= constraints.maxHeight) {
      return _child;
    }

    return FittedBox(fit: BoxFit.scaleDown, child: _child);
  }

  Widget _unconstrainedRender() => UnconstrainedBox(
        child: Offstage(
          child: _MeasureSize(
              key: _childKey, onChange: (s) => _size.value = s, child: _child),
        ),
      );
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  Size _currSize = Size.zero;
  final void Function(Size) _onChange;

  _MeasureSizeRenderObject(this._onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size? newSize = child?.size;
    if (newSize == null || _currSize == newSize) return;

    _currSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChange(newSize));
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final void Function(Size) _onChange;

  const _MeasureSize({
    required Key key,
    required void Function(Size) onChange,
    required Widget child,
  })  : _onChange = onChange,
        super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(_onChange);
  }
}
