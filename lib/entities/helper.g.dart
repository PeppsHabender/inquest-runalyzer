// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'helper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gw2Patches _$Gw2PatchesFromJson(Map<String, dynamic> json) => Gw2Patches(
      patches: (json['patches'] as List<dynamic>)
          .map((e) => Gw2Patch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$Gw2PatchesToJson(Gw2Patches instance) =>
    <String, dynamic>{
      'patches': instance.patches,
    };

Gw2Patch _$Gw2PatchFromJson(Map<String, dynamic> json) => Gw2Patch(
      from: json['from'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$Gw2PatchToJson(Gw2Patch instance) => <String, dynamic>{
      'from': instance.from,
      'name': instance.name,
    };

Boss _$BossFromJson(Map<String, dynamic> json) => Boss(
      name: json['name'] as String? ?? "",
      targetIDs:
          (json['targetIDs'] as List<dynamic>?)?.map((e) => e as int).toSet() ??
              const {},
      icon: json['icon'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$BossToJson(Boss instance) => <String, dynamic>{
      'name': instance.name,
      'targetIDs': instance.targetIDs.toList(),
      'icon': instance.icon,
      'img': instance.img,
    };
