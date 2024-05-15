import 'package:flutter/material.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/widgets/widgets.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: waterMark(
            color: Theme.of(context).canvasColor.darker(0.03),
            text: "404 Not Found",
            fontSize: 140),
      );
}
