import 'dart:html';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/utils.dart';

class StaticModifierController extends GetxController {
  late final TextEditingController type;
  late final TextEditingController dayOfWeek;
  late final String creator;

  late final RxString name;
  final RxBool nameError = false.obs;
  late final RxString hour;
  final RxBool hourError = false.obs;
  late final RxString minute;
  final RxBool minuteError = false.obs;

  final RxList<CommanderModel> players = <CommanderModel>[].obs;
  final RxBool loading = false.obs;
  final Rx<String?> errorMsg = null.obs;

  final Static _static;

  StaticModifierController(this._static) {
    type = TextEditingController(text: _static.type.name);
    dayOfWeek = TextEditingController(text: _static.timeSlot!.day.name);

    name = _static.name.obs;
    hour = (_static.timeSlot?.hour ?? 0).toString().obs;
    minute = (_static.timeSlot?.minute ?? 0).toString().obs;

    players.value = _static.players.map((e) {
      final Commander? commander =
          _static.commanders.firstWhereOrNull((el) => e == el.accountName);

      return commander == null
          ? CommanderModel.fromString(e)
          : CommanderModel.fromCommander(commander);
    }).toList();
    players.sort();

    creator = _static.creator;
  }

  bool hasErrors() => nameError.value || hourError.value || minuteError.value;

  void updateStatic() async {
    loading.value = true;
    await doHttpRequest("/api/statics/${_static.id}", true, (status, body) {
      if (status > 200) {
        errorMsg.value = body;
        return;
      }

      window.location.reload();
    }, method: HttpMethod.POST, body: <String, dynamic>{
      "name": name.value,
      "day": dayOfWeek.text,
      "time":
          "${hour.value.toString().padLeft(2, "0")}:${minute.value.toString().padLeft(2, "0")}",
      "type": type.text,
      "players": players.map((e) => e.name.text).toList(),
      "commanders": players.map((e) => e.toJson()).toList()
    });

    loading.value = false;
  }
}

class CommanderModel with Compare<CommanderModel> {
  late final TextEditingController name;
  late final RxBool canUpload, canModify;

  CommanderModel.fromCommander(final Commander commander)
      : name = TextEditingController(text: commander.accountName),
        canUpload = commander.canUpload.obs,
        canModify = commander.canModify.obs;

  CommanderModel.fromString(final String accountName)
      : name = TextEditingController(text: accountName),
        canUpload = false.obs,
        canModify = false.obs;

  Map<String, dynamic> toJson() => {
        "accountName": name.text,
        "canUpload": canUpload.value,
        "canModify": canModify.value
      };

  @override
  int compareTo(final CommanderModel other) {
    int compare =
        canModify.value.not().toInt() - other.canModify.value.not().toInt();
    if (compare != 0) return compare;

    compare =
        canUpload.value.not().toInt() - other.canUpload.value.not().toInt();
    if (compare != 0) return compare;

    return name.text.toLowerCase().compareTo(other.name.text.toLowerCase());
  }
}
