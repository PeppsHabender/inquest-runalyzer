// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DpsReport _$DpsReportFromJson(Map<String, dynamic> json) => DpsReport(
      id: json['id'] as String,
      permalink: json['permalink'] as String,
      userToken: json['userToken'] as String,
      uploadTime: json['uploadTime'] as int,
      encounterTime: json['encounterTime'] as int,
      encounter: json['encounter'] == null
          ? null
          : Encounter.fromJson(json['encounter'] as Map<String, dynamic>),
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
    )..error = json['error'] as String?;

Map<String, dynamic> _$DpsReportToJson(DpsReport instance) => <String, dynamic>{
      'id': instance.id,
      'permalink': instance.permalink,
      'userToken': instance.userToken,
      'uploadTime': instance.uploadTime,
      'encounterTime': instance.encounterTime,
      'error': instance.error,
      'encounter': instance.encounter,
      'members': instance.members,
    };

Encounter _$EncounterFromJson(Map<String, dynamic> json) => Encounter(
      success: json['success'] as bool,
      duration: json['duration'] as int,
      compDps: json['compDps'] as int,
      numberOfPlayers: json['numberOfPlayers'] as int,
      numberOfGroups: json['numberOfGroups'] as int,
      bossId: json['bossId'] as int,
      jsonAvailable: json['jsonAvailable'] as bool,
    );

Map<String, dynamic> _$EncounterToJson(Encounter instance) => <String, dynamic>{
      'success': instance.success,
      'duration': instance.duration,
      'compDps': instance.compDps,
      'numberOfPlayers': instance.numberOfPlayers,
      'numberOfGroups': instance.numberOfGroups,
      'bossId': instance.bossId,
      'jsonAvailable': instance.jsonAvailable,
    };
