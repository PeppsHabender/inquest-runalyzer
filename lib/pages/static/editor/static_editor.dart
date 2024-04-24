import 'package:feather_icons_svg/feather_icons_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/entities/helper.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/pages/static/controller/static_modifier_controller.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';
import 'package:runalyzer_client/utils/widgets/rx_text_field.dart';

class StaticEditor extends StatelessWidget {
  final StaticModifierController _controller;
  final ScrollController _playerScrollController = ScrollController();

  StaticEditor(this._controller, {super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _metaEditor(),
          const SizedBox(height: 10),
          _timeSlotEditor(),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Players:", style: context.textTheme.titleMedium)
            )
          ),
          const Divider(),
          Expanded(child: _playersEditor(context)),
          _updater(),
        ],
      ),
    ),
  );

  Widget _metaEditor() => Row(
    children: [
      Expanded(
          child: RxTextField(
            label: "Name",
            text: _controller.name,
            erroneous: _controller.nameError,
            validator: (n) => n.isNotEmpty && !RegExp("^ +\$").hasMatch(n),
          )
      ),
      const SizedBox(width: 10),
      DropdownMenu<StaticType>(
          label: const Text("Type"),
          initialSelection: StaticType.values.firstWhere((e) => _controller.type.text == e.name),
          dropdownMenuEntries: StaticType.values.map((e) => DropdownMenuEntry(value: e, label: e.name)).toList()
      )
    ],
  );

  Widget _timeSlotEditor() => Row(
    children: [
      DropdownMenu<DayOfWeek>(
        label: const Text("Day"),
        initialSelection: DayOfWeek.values.firstWhere((e) => _controller.dayOfWeek.text == e.name),
        dropdownMenuEntries: DayOfWeek.values.map((e) => DropdownMenuEntry(value: e, label: e.name)).toList()
      ),
      const Spacer(),
      SizedBox(
        width: 65,
        child: RxTextField(
          label: "Hour",
          text: _controller.hour,
          erroneous: _controller.hourError,
          validator: (h) => int.tryParse(h)?.inRange(min: 0, max: 23) ?? false,
          maxChars: 2,
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 11),
        child: Text(":"),
      ),
      SizedBox(
        width: 65,
        child: RxTextField(
          label: "Minute",
          text: _controller.minute,
          erroneous: _controller.minuteError,
          validator: (m) => int.tryParse(m)?.inRange(min: 0, max: 59) ?? false,
          maxChars: 2,
        ),
      )
    ],
  );

  Widget _playersEditor(final BuildContext context) => Stack(
    children: [
      ObxValue(
        (players) => ListView.builder(
          controller: _playerScrollController,
          itemCount: players.length,
          itemBuilder: (context, idx) => _playerEditor(players[idx], _controller.creator, players.remove)
        ),
        _controller.players
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              backgroundColor: MaterialStateProperty.all(context.theme.cardColor)
            ),
            icon: const FeatherIcon(FeatherIcons.userPlus, size: 25),
            onPressed: () {
              _controller.players.add(CommanderModel.fromString("Player.1234"));
              Future.delayed(
                const Duration(milliseconds: 200),
                () => _playerScrollController.scrollDown(duration: const Duration(milliseconds: 500))
              );
            },
          ),
        ),
      )
    ]
  );

  Widget _updater() => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ObxValue(
          (loading) => loading.value ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 3)) : Container(),
          _controller.loading
        ),
        const SizedBox(width: 10),
        Obx(() => OutlinedButton(
          onPressed: _controller.loading.value || _controller.hasErrors() ? null : _controller.updateStatic,
          child: const Text("Update")
        )),
      ]
  );
}

Widget _playerEditor(final CommanderModel player, final String creator, final void Function(CommanderModel) remove) {
  final RxBool hovered = false.obs;
  final RxBool tapped = false.obs;

  return InkWell(
    onHover: (h) => hovered.value = h,
    onTap: player.name.value == creator ? null : () {
      if(!tapped.value) tapped.value = true;
    },
    child: ListTile(
      dense: true,
      leading: ObxValue(
        (h) => h.value
          ? IconButton(
              icon: const FeatherIcon(FeatherIcons.trash, size: 20),
              onPressed: () => remove(player),
            )
          : const SizedBox(width: 0)
        ,
        hovered
      ),
      title: Obx(() => tapped.value
        ? _playerTextField(tapped, player.name, creator)
        : Text(player.name.text, style: TextStyle(color: player.name.text == creator ? Colors.white38 : null))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _checkBox(player.name.text != creator, player.canUpload, const FeatherIcon(FeatherIcons.upload, size: 25)),
          const SizedBox(width: 10),
          _checkBox(player.name.text != creator, player.canModify, Image(width: 25, height: 52, image: RunalyzerAssets.randomCommander()))
        ],
      ),
    ),
  );
}

Widget _playerTextField(final RxBool tapped, final TextEditingController name, final String creator) {
  final FocusNode focusNode = FocusNode();

  return Focus(
    onFocusChange: (f) {
      if(!f) tapped.value = false;
    },
    child: Align(
      alignment: Alignment.center,
      child: TextField(
        controller: name,
        enabled: name.text != creator,
        decoration: const InputDecoration(isDense: true),
        style: const TextStyle(fontSize: 13),
        textAlignVertical: TextAlignVertical.center,
        focusNode: focusNode..requestFocus(),
      ),
    ),
  );
}

Widget _checkBox(final bool enabled, final RxBool prop, final Widget icon) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    ObxValue(
      (modify) => Checkbox(
        value: modify.value,
        activeColor: enabled ? null : Colors.white38,
        onChanged: !enabled ? null : (v) {
          if(v != null) modify.value = v;
        },
      ),
      prop
    ),
    icon
  ],
);