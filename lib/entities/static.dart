import 'package:json_annotation/json_annotation.dart';
import 'package:runalyzer_client/entities/helper.dart';

part 'static.g.dart';

@JsonSerializable()
class Static {
  final String id;
  final String name;
  final String creator;
  final StaticTimeSlot? timeSlot;
  final StaticType type;
  final List<String> players;
  final List<Commander> commanders;

  Static(
      {required this.id,
      required this.name,
      required this.creator,
      required this.timeSlot,
      required this.type,
      this.players = const [],
      this.commanders = const []});

  factory Static.fromJson(Map<String, dynamic> json) => _$StaticFromJson(json);
}

@JsonSerializable()
class StaticTimeSlot {
  DayOfWeek day;
  int hour;
  int minute;
  String zoneStr;

  StaticTimeSlot(
      {required this.day,
      required this.hour,
      required this.minute,
      required this.zoneStr});

  factory StaticTimeSlot.fromJson(Map<String, dynamic> json) =>
      _$StaticTimeSlotFromJson(json);
}

@JsonSerializable()
class Commander {
  final String accountName;
  final bool canUpload;
  final bool canModify;

  Commander({
    required this.accountName,
    required this.canUpload,
    required this.canModify,
  });

  factory Commander.fromJson(Map<String, dynamic> json) =>
      _$CommanderFromJson(json);
}

enum StaticType {
  @JsonValue("RAIDS")
  RAIDS,
  @JsonValue("STRIKES")
  STRIKES,
  @JsonValue("FRACTALS")
  FRACTALS,
}
