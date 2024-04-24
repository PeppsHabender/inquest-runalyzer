// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'static_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MongoDateTime _$MongoDateTimeFromJson(Map<String, dynamic> json) =>
    MongoDateTime(
      date: DateTime.parse(json['date'] as String),
      offset: json['offset'] as String,
    );

Map<String, dynamic> _$MongoDateTimeToJson(MongoDateTime instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'offset': instance.offset,
    };

StaticRun _$StaticRunFromJson(Map<String, dynamic> json) => StaticRun(
      analysis: json['analysis'] == null
          ? null
          : StaticAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
    )..players =
        (json['players'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$StaticRunToJson(StaticRun instance) => <String, dynamic>{
      'analysis': instance.analysis,
      'players': instance.players,
    };

StaticAnalysis _$StaticAnalysisFromJson(Map<String, dynamic> json) =>
    StaticAnalysis()
      ..duration = json['duration'] as int
      ..downtime = json['downtime'] as int
      ..start = json['start'] == null
          ? null
          : MongoDateTime.fromJson(json['start'] as Map<String, dynamic>)
      ..end = json['end'] == null
          ? null
          : MongoDateTime.fromJson(json['end'] as Map<String, dynamic>)
      ..averageTimePerBoss = (json['averageTimePerBoss'] as num).toDouble()
      ..avgDps = (json['avgDps'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      )
      ..compDps = (json['compDps'] as num).toDouble()
      ..cc = Map<String, int>.from(json['cc'] as Map)
      ..playerBoonStatsAvg = (json['playerBoonStatsAvg'] as List<dynamic>)
          .map((e) => BoonStats.fromJson(e as Map<String, dynamic>))
          .toList()
      ..subGroupBoonStatsAvg = (json['subGroupBoonStatsAvg'] as List<dynamic>)
          .map((e) => BoonStats.fromJson(e as Map<String, dynamic>))
          .toList()
      ..defensiveStats = (json['defensiveStats'] as List<dynamic>)
          .map((e) => DefensiveStats.fromJson(e as Map<String, dynamic>))
          .toList()
      ..successful = (json['successful'] as List<dynamic>)
          .map((e) => RunLog.fromJson(e as Map<String, dynamic>))
          .toList()
      ..wipes = (json['wipes'] as List<dynamic>)
          .map((e) => RunLog.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$StaticAnalysisToJson(StaticAnalysis instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'downtime': instance.downtime,
      'start': instance.start,
      'end': instance.end,
      'averageTimePerBoss': instance.averageTimePerBoss,
      'avgDps': instance.avgDps,
      'compDps': instance.compDps,
      'cc': instance.cc,
      'playerBoonStatsAvg': instance.playerBoonStatsAvg,
      'subGroupBoonStatsAvg': instance.subGroupBoonStatsAvg,
      'defensiveStats': instance.defensiveStats,
      'successful': instance.successful,
      'wipes': instance.wipes,
    };

RunLog _$RunLogFromJson(Map<String, dynamic> json) => RunLog()
  ..log = json['log'] == null
      ? null
      : DpsReport.fromJson(json['log'] as Map<String, dynamic>)
  ..groupDps = json['groupDps'] as int
  ..subgroupDps = Map<String, int>.from(json['subgroupDps'] as Map)
  ..offensiveStats = (json['offensiveStats'] as List<dynamic>)
      .map((e) => OffensiveStats.fromJson(e as Map<String, dynamic>))
      .toList()
  ..defensiveStats = (json['defensiveStats'] as List<dynamic>)
      .map((e) => DefensiveStats.fromJson(e as Map<String, dynamic>))
      .toList()
  ..playerBoonStats = (json['playerBoonStats'] as List<dynamic>)
      .map((e) => BoonStats.fromJson(e as Map<String, dynamic>))
      .toList()
  ..subGroupBoonStats = (json['subGroupBoonStats'] as List<dynamic>)
      .map((e) => BoonStats.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$RunLogToJson(RunLog instance) => <String, dynamic>{
      'log': instance.log,
      'groupDps': instance.groupDps,
      'subgroupDps': instance.subgroupDps,
      'offensiveStats': instance.offensiveStats,
      'defensiveStats': instance.defensiveStats,
      'playerBoonStats': instance.playerBoonStats,
      'subGroupBoonStats': instance.subGroupBoonStats,
    };

OffensiveStats _$OffensiveStatsFromJson(Map<String, dynamic> json) =>
    OffensiveStats()
      ..player = json['player'] as String?
      ..dps = json['dps'] as int
      ..cc = json['cc'] as int;

Map<String, dynamic> _$OffensiveStatsToJson(OffensiveStats instance) =>
    <String, dynamic>{
      'player': instance.player,
      'dps': instance.dps,
      'cc': instance.cc,
    };

DefensiveStats _$DefensiveStatsFromJson(Map<String, dynamic> json) {
  return DefensiveStats()
      ..player = json['player'] as String?
      ..damageTaken = (json['damageTaken'] as num).toDouble()
      ..downstates = (json['downstates'] as num).toDouble()
      ..deaths = (json['deaths'] as num).toDouble()
      ..resTime = (json['resTime'] as num).toDouble()
      ..condiCleanses = (json['condiCleanses'] as num).toDouble()
      ..boonStrips = (json['boonStrips'] as num).toDouble()
      ..healing = (json['healing'] as num?)?.toDouble()
      ..barrier = (json['barrier'] as num?)?.toDouble();
}

Map<String, dynamic> _$DefensiveStatsToJson(DefensiveStats instance) =>
    <String, dynamic>{
      'player': instance.player,
      'damageTaken': instance.damageTaken,
      'downstates': instance.downstates,
      'death': instance.deaths,
      'resTime': instance.resTime,
      'condiCleanses': instance.condiCleanses,
      'boonStrips': instance.boonStrips,
      'healing': instance.healing,
      'barrier': instance.barrier,
    };

BoonStats _$BoonStatsFromJson(Map<String, dynamic> json) => BoonStats(
      player: json['player'] as String,
      boons: (json['boons'] as List<dynamic>).map((e) => e as String).toList(),
      uptime: (json['uptime'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      generation: (json['generation'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$BoonStatsToJson(BoonStats instance) => <String, dynamic>{
      'player': instance.player,
      'boons': instance.boons,
      'uptime': instance.uptime,
      'generation': instance.generation,
    };
