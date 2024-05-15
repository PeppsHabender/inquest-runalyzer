import 'package:feather_icons_svg/feather_icons_svg.dart';
import 'package:flutter/material.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/pages/static/controller/static_modifier_controller.dart';
import 'package:runalyzer_client/pages/static/editor/log_uploader.dart';
import 'package:runalyzer_client/pages/static/editor/static_editor.dart';
import 'package:runalyzer_client/utils/extensions.dart';

class StaticModifier extends StatelessWidget {
  late final bool _showUploader;
  late final bool _showModifier;
  late final StaticModifierController _modifierController;

  StaticModifier(Static static, {super.key}) {
    _showUploader = static.userCanUpload();
    _showModifier = static.userCanModify();
    _modifierController = StaticModifierController(static);
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = [];
    final List<Widget> tabViews = [];

    if (_showUploader) {
      tabs.add(const Tab(icon: FeatherIcon(FeatherIcons.upload)));
      tabViews.add(Uploader());
    }

    if (_showModifier) {
      tabs.add(const Tab(icon: FeatherIcon(FeatherIcons.edit)));
      tabViews.add(StaticEditor(_modifierController));
    }

    return DefaultTabController(
      length: 2,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 500,
              child: TabBar(tabs: tabs),
            ),
            SizedBox(
              width: 500,
              height: 500,
              child: TabBarView(children: tabViews),
            )
          ],
        ),
      ),
    );
  }
}
