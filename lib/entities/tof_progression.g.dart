// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tof_progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Count _$CountFromJson(Map<String, dynamic> json) => Count(
      json['player'] as String,
      (json['times'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$CountToJson(Count instance) => <String, dynamic>{
      'player': instance.player,
      'times': instance.times,
    };

Mechanic _$MechanicFromJson(Map<String, dynamic> json) => Mechanic(
      json['name'] as String,
      $enumDecode(_$MechanicTypeEnumMap, json['type']),
      (json['counts'] as List<dynamic>)
          .map((e) => Count.fromJson(e as Map<String, dynamic>))
          .toList(),
      fullName: json['fullName'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$MechanicToJson(Mechanic instance) => <String, dynamic>{
      'name': instance.name,
      'type': _$MechanicTypeEnumMap[instance.type]!,
      'fullName': instance.fullName,
      'description': instance.description,
      'counts': instance.counts,
    };

const _$MechanicTypeEnumMap = {
  MechanicType.HITS: 'HITS',
  MechanicType.CATCHES: 'CATCHES',
  MechanicType.STACKS: 'STACKS',
  MechanicType.OTHER: 'OTHER',
};

TofProgression _$TofProgressionFromJson(Map<String, dynamic> json) =>
    TofProgression(
      json['id'] as String,
      staticId: json['staticId'] as String? ?? "",
      runs:
          (json['runs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$TofProgressionToJson(TofProgression instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staticId': instance.staticId,
      'runs': instance.runs,
    };

TofRun _$TofRunFromJson(Map<String, dynamic> json) => TofRun(
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      runLog: json['runLog'] == null
          ? null
          : RunLog.fromJson(json['runLog'] as Map<String, dynamic>),
      time: json['time'] as int?,
      fullFight: json['fullFight'] == null
          ? null
          : TofPhase.fromJson(json['fullFight'] as Map<String, dynamic>),
      phase1: json['phase1'] == null
          ? null
          : TofPhase.fromJson(json['phase1'] as Map<String, dynamic>),
      split1: json['split1'] == null
          ? null
          : TofPhase.fromJson(json['split1'] as Map<String, dynamic>),
      phase2: json['phase2'] == null
          ? null
          : TofPhase.fromJson(json['phase2'] as Map<String, dynamic>),
      split2: json['split2'] == null
          ? null
          : TofPhase.fromJson(json['split2'] as Map<String, dynamic>),
      phase3: json['phase3'] == null
          ? null
          : TofPhase.fromJson(json['phase3'] as Map<String, dynamic>),
      enrage: json['enrage'] == null
          ? null
          : TofPhase.fromJson(json['enrage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TofRunToJson(TofRun instance) => <String, dynamic>{
      'percent': instance.percent,
      'runLog': instance.runLog,
      'time': instance.time,
      'fullFight': instance.fullFight,
      'phase1': instance.phase1,
      'split1': instance.split1,
      'phase2': instance.phase2,
      'split2': instance.split2,
      'phase3': instance.phase3,
      'enrage': instance.enrage,
    };

TofPhase _$TofPhaseFromJson(Map<String, dynamic> json) => TofPhase(
      name: json['name'] as String? ?? "",
      start: json['start'] as int? ?? 0,
      end: json['end'] as int? ?? 0,
      dps: json['dps'] as int? ?? 0,
      empowerment:
          Mechanic.fromJson(json['empowerment'] as Map<String, dynamic>),
      exposed: Mechanic.fromJson(json['exposed'] as Map<String, dynamic>),
      insatiable: Mechanic.fromJson(json['insatiable'] as Map<String, dynamic>),
      crushingRegretHits:
          Mechanic.fromJson(json['crushingRegretHits'] as Map<String, dynamic>),
      crushingRegretCatches: Mechanic.fromJson(
          json['crushingRegretCatches'] as Map<String, dynamic>),
      wailOfDespair:
          Mechanic.fromJson(json['wailOfDespair'] as Map<String, dynamic>),
      poolOfDespair:
          Mechanic.fromJson(json['poolOfDespair'] as Map<String, dynamic>),
      enviousGaze:
          Mechanic.fromJson(json['enviousGaze'] as Map<String, dynamic>),
      maliciousIntent:
          Mechanic.fromJson(json['maliciousIntent'] as Map<String, dynamic>),
      cryOfRage: Mechanic.fromJson(json['cryOfRage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TofPhaseToJson(TofPhase instance) => <String, dynamic>{
      'name': instance.name,
      'start': instance.start,
      'end': instance.end,
      'empowerment': instance.empowerment,
      'exposed': instance.exposed,
      'insatiable': instance.insatiable,
      'crushingRegretHits': instance.crushingRegretHits,
      'crushingRegretCatches': instance.crushingRegretCatches,
      'wailOfDespair': instance.wailOfDespair,
      'poolOfDespair': instance.poolOfDespair,
      'enviousGaze': instance.enviousGaze,
      'maliciousIntent': instance.maliciousIntent,
      'cryOfRage': instance.cryOfRage,
    };
