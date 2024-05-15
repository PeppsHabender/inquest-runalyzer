import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:runalyzer_client/utils/extensions.dart';
import 'package:runalyzer_client/utils/random_pool.dart';
import 'package:runalyzer_client/utils/storage.dart';
import 'package:rx_future/rx_future.dart';
import 'package:runalyzer_client/entities/helper.dart' as helpers;

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
    final String colorStr = RandomColor.getColor(
        Options(format: Format.hex, luminosity: luminosity));
    final int colorHex = int.parse(colorStr.substring(1), radix: 16);

    return Color(colorHex).withAlpha(255);
  }
}

class RunalyzerAssets {
  static final List<String> _TAG_COLORS = [
    "BLUE",
    "GREEN",
    "LBLUE",
    "ORANGE",
    "PINK",
    "PURPLE",
    "RED",
    "WHITE",
    "YELLOW"
  ];

  static final PoolRandom<String> _RANDOM_TAGS = PoolRandom(_TAG_COLORS);

  RunalyzerAssets._();

  static AssetImage randomCommander() =>
      AssetImage("icons/${_RANDOM_TAGS.next()}_TAG.png");

  static AssetImage commanderIcon(String color) =>
      AssetImage("icons/${color.toUpperCase()}_TAG.png");
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
  GET,
  POST;
}

Future<T> doHttpRequest<T>(
    String endpoint, bool withApiKey, ResponseHandler<T> handler,
    {String host = kDebugMode ? "localhost:8080" : "service.peppshabender.de",
    HttpMethod method = HttpMethod.GET,
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, String> headers = const {}}) async {
  final Map<String, String> newHeaders = Map.of(headers);
  if (withApiKey) newHeaders["X-API-KEY"] = RunalyzerStorage.apiKey ?? "";
  if (method == HttpMethod.POST)
    newHeaders["Content-Type"] = "application/json";

  final Uri uri =
      (kDebugMode ? Uri.http(host, endpoint) : Uri.https(host, endpoint))
          .replace(
              queryParameters:
                  queryParams?.map((k, v) => MapEntry(k, v.toString())));

  if (method == HttpMethod.GET) {
    return http
        .get(uri, headers: newHeaders)
        .then((value) => handler(value.statusCode, value.body));
  } else {
    return http
        .post(
      uri,
      headers: newHeaders,
      body: body == null ? null : jsonEncode(body),
    )
        .then((value) {
      return handler(value.statusCode, value.body);
    });
  }
}

void loadMorePages<T>((bool, int, RxFuture<List<T>>) pageFuture,
        String endpoint, T Function(Map<String, dynamic> json) creator,
        {void Function(bool hasMore, int newPage)? onSuccess,
        void Function()? finallyDo,
        int Function(T, T)? sort}) =>
    pageFuture.$3.newValue((prev) async {
      if (!pageFuture.$1) return prev ?? [];

      return await doHttpRequest(endpoint, true,
          queryParams: {"page": pageFuture.$2}, (status, body) {
        try {
          final helpers.Page<T> found =
              helpers.Page.fromJson(jsonDecode(body), creator);
          final List<T> ls = (prev ?? []);
          ls.addAll(found.items);

          if (sort != null) {
            ls.sort(sort);
          }

          if (onSuccess != null) {
            onSuccess(found.hasMore, pageFuture.$2 + 1);
          }

          return ls;
        } catch (e) {
          e.printError();
          rethrow;
        }
      });
    }, finallyDo: finallyDo);

(double, double)? getWidgetHeight(final GlobalKey key) {
  final RenderBox? renderObject =
      key.currentContext?.findRenderObject() as RenderBox?;

  return renderObject == null
      ? null
      : (renderObject.size.width, renderObject.size.height);
}

mixin Compare<T> implements Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >=(T other) => compareTo(other) >= 0;
  bool operator <(T other) => compareTo(other) < 0;
  bool operator >(T other) => compareTo(other) > 0;
}
