import 'package:json_annotation/json_annotation.dart';

part 'logs.g.dart';

@JsonSerializable()
class DpsReport {
  String id;
  String permalink;
  String userToken;
  int uploadTime;
  int encounterTime;
  String? error;
  Encounter? encounter;
  List<String> members;

  DpsReport({
    required this.id,
    required this.permalink,
    required this.userToken,
    required this.uploadTime,
    required this.encounterTime,
    required this.encounter,
    required this.members,
  });

  factory DpsReport.fromJson(Map<String, dynamic> json) => _$DpsReportFromJson(json);
}

@JsonSerializable()
class Encounter {
  bool success;
  int duration;
  int compDps;
  int numberOfPlayers;
  int numberOfGroups;
  int bossId;
  bool jsonAvailable;

  Encounter({
    required this.success,
    required this.duration,
    required this.compDps,
    required this.numberOfPlayers,
    required this.numberOfGroups,
    required this.bossId,
    required this.jsonAvailable,
  });

  factory Encounter.fromJson(Map<String, dynamic> json) => _$EncounterFromJson(json);
}

