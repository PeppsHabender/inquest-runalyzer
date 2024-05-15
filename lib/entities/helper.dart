import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'helper.g.dart';

typedef Constructor<T> = T Function(Map<String, dynamic>);

class Page<T> {
  bool hasMore;
  List<T> items;

  Page.fromJson(Map<String, dynamic> json, Constructor<T> converter)
      : hasMore = json["hasMore"],
        items = (json["items"] as Iterable<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(converter)
            .toList();
}

enum DayOfWeek {
  @JsonValue("MONDAY")
  MONDAY,
  @JsonValue("TUESDAY")
  TUESDAY,
  @JsonValue("WEDNESDAY")
  WEDNESDAY,
  @JsonValue("THURSDAY")
  THURSDAY,
  @JsonValue("FRIDAY")
  FRIDAY,
  @JsonValue("SATURDAY")
  SATURDAY,
  @JsonValue("SUNDAY")
  SUNDAY
}

@JsonSerializable()
class Gw2Patches {
  final List<Gw2Patch> patches;

  Gw2Patches({required this.patches});

  factory Gw2Patches.fromJson(Map<String, dynamic> json) =>
      _$Gw2PatchesFromJson(json);
}

@JsonSerializable()
class Gw2Patch {
  final String from;
  final String name;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final DateTime date;

  Gw2Patch({required this.from, required this.name}) {
    date = DateFormat("yyyy-MM-dd").parse(from);
  }

  factory Gw2Patch.fromJson(Map<String, dynamic> json) =>
      _$Gw2PatchFromJson(json);
}

class BossMap {
  final Map<int, Boss> bossMap = {};

  BossMap(final Map<String, dynamic> json) {
    json.forEach((k, v) =>
        bossMap[int.parse(k)] = Boss.fromJson(v as Map<String, dynamic>));
  }
}

@JsonSerializable()
class Boss {
  final String name;
  final Set<int> targetIDs;

  @JsonKey(includeIfNull: true, defaultValue: null)
  final String? icon;
  @JsonKey(includeIfNull: true, defaultValue: null)
  final String? img;

  Boss({
    this.name = "",
    this.targetIDs = const {},
    this.icon,
    this.img,
  });

  factory Boss.fromJson(Map<String, dynamic> json) => _$BossFromJson(json);
}
