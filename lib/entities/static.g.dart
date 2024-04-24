// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'static.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Static _$StaticFromJson(Map<String, dynamic> json) => Static(
      id: json['id'] as String,
      name: json['name'] as String,
      creator: json['creator'] as String,
      timeSlot: json['timeSlot'] == null
          ? null
          : StaticTimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>),
      type: $enumDecode(_$StaticTypeEnumMap, json['type']),
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      commanders: (json['commanders'] as List<dynamic>?)
              ?.map((e) => Commander.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StaticToJson(Static instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'creator': instance.creator,
      'timeSlot': instance.timeSlot,
      'type': _$StaticTypeEnumMap[instance.type]!,
      'players': instance.players,
      'commanders': instance.commanders,
    };

const _$StaticTypeEnumMap = {
  StaticType.RAIDS: 'RAIDS',
  StaticType.STRIKES: 'STRIKES',
  StaticType.FRACTALS: 'FRACTALS',
};

StaticTimeSlot _$StaticTimeSlotFromJson(Map<String, dynamic> json) =>
    StaticTimeSlot(
      day: $enumDecode(_$DayOfWeekEnumMap, json['day']),
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      zoneStr: json['zoneStr'] as String,
    );

Map<String, dynamic> _$StaticTimeSlotToJson(StaticTimeSlot instance) =>
    <String, dynamic>{
      'day': _$DayOfWeekEnumMap[instance.day]!,
      'hour': instance.hour,
      'minute': instance.minute,
      'zoneStr': instance.zoneStr,
    };

const _$DayOfWeekEnumMap = {
  DayOfWeek.MONDAY: 'MONDAY',
  DayOfWeek.TUESDAY: 'TUESDAY',
  DayOfWeek.WEDNESDAY: 'WEDNESDAY',
  DayOfWeek.THURSDAY: 'THURSDAY',
  DayOfWeek.FRIDAY: 'FRIDAY',
  DayOfWeek.SATURDAY: 'SATURDAY',
  DayOfWeek.SUNDAY: 'SUNDAY',
};

Commander _$CommanderFromJson(Map<String, dynamic> json) => Commander(
      accountName: json['accountName'] as String,
      canUpload: json['canUpload'] as bool,
      canModify: json['canModify'] as bool,
    );

Map<String, dynamic> _$CommanderToJson(Commander instance) => <String, dynamic>{
      'accountName': instance.accountName,
      'canUpload': instance.canUpload,
      'canModify': instance.canModify,
    };
