import 'package:json_annotation/json_annotation.dart';
import 'package:runalyzer_client/entities/logs.dart';

part 'static_run.g.dart';

@JsonSerializable()
class MongoDateTime {
  DateTime date;
  String offset;

  MongoDateTime({required this.date, required this.offset});

  factory MongoDateTime.fromJson(Map<String, dynamic> json) => _$MongoDateTimeFromJson(json);

  Map<String, dynamic> toJson() => _$MongoDateTimeToJson(this);
}

@JsonSerializable()
class StaticRun {
  StaticAnalysis? analysis;
  List<String> players = [];

  StaticRun({this.analysis});

  factory StaticRun.fromJson(Map<String, dynamic> json) => _$StaticRunFromJson(json);

  Map<String, dynamic> toJson() => _$StaticRunToJson(this);
}

@JsonSerializable()
class StaticAnalysis {
  int duration = 0;
  int downtime = 0;
  MongoDateTime? start;
  MongoDateTime? end;
  double averageTimePerBoss = 0.0;
  Map<String, double> avgDps = {};
  double compDps = 0.0;
  Map<String, int> cc = {};
  List<BoonStats> playerBoonStatsAvg = [];
  List<BoonStats> subGroupBoonStatsAvg = [];
  List<DefensiveStats> defensiveStats = [];
  List<RunLog> successful = [];
  List<RunLog> wipes = [];

  StaticAnalysis();

  factory StaticAnalysis.fromJson(Map<String, dynamic> json) => _$StaticAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$StaticAnalysisToJson(this);
}

@JsonSerializable()
class RunLog {
  DpsReport? log;
  int groupDps = 0;
  Map<String, int> subgroupDps = {};
  List<OffensiveStats> offensiveStats = [];
  List<DefensiveStats> defensiveStats = [];
  List<BoonStats> playerBoonStats = [];
  List<BoonStats> subGroupBoonStats = [];

  RunLog();

  factory RunLog.fromJson(Map<String, dynamic> json) => _$RunLogFromJson(json);

  Map<String, dynamic> toJson() => _$RunLogToJson(this);
}

@JsonSerializable()
class OffensiveStats {
  String? player;
  int dps = 0;
  int cc = 0;

  OffensiveStats();

  factory OffensiveStats.fromJson(Map<String, dynamic> json) => _$OffensiveStatsFromJson(json);

  Map<String, dynamic> toJson() => _$OffensiveStatsToJson(this);
}

@JsonSerializable()
class DefensiveStats {
  String? player;
  double damageTaken = 0;
  double downstates = 0;
  double deaths = 0;
  double resTime = 0;
  double condiCleanses = 0;
  double boonStrips = 0;
  double? healing;
  double? barrier;

  DefensiveStats();

  factory DefensiveStats.fromJson(Map<String, dynamic> json) => _$DefensiveStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DefensiveStatsToJson(this);
}

@JsonSerializable()
class BoonStats {
  String player;
  final List<String> boons;
  final List<double> uptime;
  @JsonKey(includeIfNull: true, defaultValue: null)
  List<double>? generation;

  BoonStats(
    {
      required this.player,
      required this.boons,
      required this.uptime,
      this.generation
    }
  );

  factory BoonStats.fromJson(Map<String, dynamic> json) => _$BoonStatsFromJson(json);

  Map<String, dynamic> toJson() => _$BoonStatsToJson(this);
}