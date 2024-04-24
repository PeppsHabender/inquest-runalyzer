import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:runalyzer_client/utils/utils.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _AnimatedDot(delay: 0),
      SizedBox(width: 10),
      _AnimatedDot(delay: 200),
      SizedBox(width: 10),
      _AnimatedDot(delay: 300),
    ],
  );
}

class _AnimatedDot extends StatefulWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  _AnimatedDotState createState() => _AnimatedDotState();
}

final _scaleSequence = TweenSequence<double>(
  <TweenSequenceItem<double>>[
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 1, end: 1.3).chain(CurveTween(curve: Curves.easeIn)),
      weight: 50.0,
    ),
    TweenSequenceItem<double>(
      tween: ConstantTween<double>(1.3),
      weight: 20.0,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 1.3, end: 1).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30.0,
    ),
  ],
);

final _colorSequence = TweenSequence<Color?>(
  [
    TweenSequenceItem(
      tween: ColorTween(begin: const Color(0xff1C1B1F), end: RunalyzerColors.INQUEST_RED).chain(CurveTween(curve: Curves.easeIn)),
      weight: 50.0,
    ),
    TweenSequenceItem(
      tween: ConstantTween(RunalyzerColors.INQUEST_RED),
      weight: 20.0,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: RunalyzerColors.INQUEST_RED, end: const Color(0xff1C1B1F)).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30.0
    ),
  ],
);

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scale;
  late Animation<Color?> _color;

  _AnimatedDotState();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {setState(() {

    });});

    _scale = _scaleSequence.animate(_controller);
    _color = _colorSequence.animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), _controller.repeat);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20 * 1.3,
      height: 20 * 1.3,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _color.value,
          ),
          width: 20 * _scale.value,
          height: 20 * _scale.value,
        ),
      ),
    );
  }
}