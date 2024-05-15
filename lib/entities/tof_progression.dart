import 'package:json_annotation/json_annotation.dart';
import 'package:runalyzer_client/entities/static_run.dart';

part 'tof_progression.g.dart';

@JsonSerializable()
class Count {
  String player;
  List<int> times;

  Count(this.player, this.times);

  factory Count.fromJson(Map<String, dynamic> json) => _$CountFromJson(json);

  Map<String, dynamic> toJson() => _$CountToJson(this);
}

enum MechanicType {
  @JsonValue("HITS")
  HITS,
  @JsonValue("CATCHES")
  CATCHES,
  @JsonValue("STACKS")
  STACKS,
  @JsonValue("OTHER")
  OTHER,
}

@JsonSerializable()
class Mechanic {
  String name;
  MechanicType type;
  String? fullName;
  String? description;
  List<Count> counts;
  int previousPhaseCounts = 0;

  Mechanic(this.name, this.type, this.counts,
      {this.fullName, this.description});

  factory Mechanic.fromJson(Map<String, dynamic> json) =>
      _$MechanicFromJson(json);

  Map<String, dynamic> toJson() => _$MechanicToJson(this);
}

@JsonSerializable()
class TofProgression {
  String id;
  String staticId;
  List<String> runs;

  TofProgression(this.id, {this.staticId = "", this.runs = const []});

  factory TofProgression.fromJson(Map<String, dynamic> json) =>
      _$TofProgressionFromJson(json);

  Map<String, dynamic> toJson() => _$TofProgressionToJson(this);
}

@JsonSerializable()
class TofRun {
  double percent;
  RunLog? runLog;
  int? time;
  TofPhase? fullFight;
  TofPhase? phase1;
  TofPhase? split1;
  TofPhase? phase2;
  TofPhase? split2;
  TofPhase? phase3;
  TofPhase? enrage;

  TofRun(
      {this.percent = 0.0,
      this.runLog,
      this.time,
      this.fullFight,
      this.phase1,
      this.split1,
      this.phase2,
      this.split2,
      this.phase3,
      this.enrage});

  factory TofRun.fromJson(Map<String, dynamic> json) => _$TofRunFromJson(json);

  Map<String, dynamic> toJson() => _$TofRunToJson(this);
}

@JsonSerializable()
class TofPhase {
  String name;
  int start;
  int end;
  int dps;
  Mechanic empowerment;
  Mechanic exposed;
  Mechanic insatiable;
  Mechanic crushingRegretHits;
  Mechanic crushingRegretCatches;
  Mechanic wailOfDespair;
  Mechanic poolOfDespair;
  Mechanic enviousGaze;
  Mechanic maliciousIntent;
  Mechanic cryOfRage;

  TofPhase(
      {this.name = "",
      this.start = 0,
      this.end = 0,
      this.dps = 0,
      required this.empowerment,
      required this.exposed,
      required this.insatiable,
      required this.crushingRegretHits,
      required this.crushingRegretCatches,
      required this.wailOfDespair,
      required this.poolOfDespair,
      required this.enviousGaze,
      required this.maliciousIntent,
      required this.cryOfRage});

  factory TofPhase.fromJson(Map<String, dynamic> json) =>
      _$TofPhaseFromJson(json);

  Map<String, dynamic> toJson() => _$TofPhaseToJson(this);
}
