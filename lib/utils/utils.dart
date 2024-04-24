import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:runalyzer_client/utils/random_pool.dart';
import 'package:runalyzer_client/utils/storage.dart';

class RunalyzerLinks {
  RunalyzerLinks._();

  static const String HOME = "/home";
  static const String API_KEY = "/apiKey";
  static const String STATIC = "/static";

  static const String STATIC_ID = "id";
}

class RunalyzerColors {
  RunalyzerColors._();
  
  static const Color INQUEST_RED = Color(0xFFED2939);

  static Color randomColor({Luminosity luminosity = Luminosity.light}) {
    final String colorStr = RandomColor.getColor(Options(format: Format.hex, luminosity: luminosity));
    final int colorHex = int.parse(colorStr.substring(1), radix: 16);

    return Color(colorHex).withAlpha(255);
  }
}

class RunalyzerAssets {
  static final List<String> _TAG_COLORS = [
    "BLUE", "GREEN", "LBLUE", "ORANGE",
    "PINK", "PURPLE", "RED", "WHITE", "YELLOW"
  ];

  static final PoolRandom<String> _RANDOM_TAGS = PoolRandom(_TAG_COLORS);

  RunalyzerAssets._();

  static AssetImage randomCommander() =>
      AssetImage("icons/${_RANDOM_TAGS.next()}_TAG.png");
  
  static AssetImage commanderIcon(String color) => AssetImage("icons/${color.toUpperCase()}_TAG.png");
}

class RunalyzerConstants {
  static final DateFormat MONTH_FMT = DateFormat('MMM');
  static final DateFormat DATE_FMT = DateFormat("MM/dd/yyyy");
  static final DateFormat TIME_FMT = DateFormat("HH:mm");
  static final DateFormat DATE_TIME_FMT = DateFormat("MM/dd/yyyy HH:mm");
  static final DateFormat PRETTY_DATE_TIME = DateFormat("dd. MMM yyyy HH:mm");

  RunalyzerConstants._();
}

typedef ResponseHandler<T> = T Function(int status, String body);

enum HttpMethod {
  GET, POST;
}

Future<T> doHttpRequest<T>(
  String endpoint,
  bool withApiKey,
  ResponseHandler<T> handler,
  {
    String host = "18.206.88.17:80",
    HttpMethod method = HttpMethod.GET,
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, String> headers = const {}
  }
) async {
  final Map<String, String> newHeaders = Map.of(headers);
  if(withApiKey) newHeaders["X-API-KEY"] = RunalyzerStorage.apiKey ?? "";
  if(method == HttpMethod.POST) newHeaders["Content-Type"] = "application/json";

  final Uri uri = Uri.http(host, endpoint).replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())));

  if(method == HttpMethod.GET) {
    return http.get(uri, headers: newHeaders).then((value) => handler(value.statusCode, value.body));
  } else {
    return http.post(
      uri,
      headers: newHeaders,
      body: body == null ? null : jsonEncode(body),
    ).then((value) {
      return handler(value.statusCode, value.body);
    });
  }
}

(double, double)? getWidgetHeight(final GlobalKey key) {
    final RenderBox? renderObject = key.currentContext?.findRenderObject() as RenderBox?;

    return renderObject == null ? null : (renderObject.size.width, renderObject.size.height);
}

mixin Compare<T> implements Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >=(T other) => compareTo(other) >= 0;
  bool operator <(T other) => compareTo(other) < 0;
  bool operator >(T other) => compareTo(other) > 0;
}