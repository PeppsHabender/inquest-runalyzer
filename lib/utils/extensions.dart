import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:runalyzer_client/entities/static.dart';
import 'package:runalyzer_client/entities/tof_progression.dart';
import 'package:runalyzer_client/utils/storage.dart';
import 'package:rx_future/rx_future.dart';

extension MapExtensions<T, U> on Map<T, U> {
  U? getOrNull(T key) => containsKey(key) ? this[key] : null;
}

extension IterableExtensions<T> on Iterable<T> {
  Map<A, B> associateBy<A, B>((A, B) Function(T e) associator) =>
      Map.fromEntries(map(associator).map((e) => MapEntry(e.$1, e.$2)));

  Map<A, List<T>> groupBy<A>(A Function(T) keyExtractor) => fold(<A, List<T>>{},
      (map, e) => map..putIfAbsent(keyExtractor(e), () => <T>[]).add(e));

  Map<A, List<B>> groupByWith<A, B>(
          A Function(T) keyExtractor, B Function(T) valueExtractor) =>
      fold(
          <A, List<B>>{},
          (map, e) => map
            ..putIfAbsent(keyExtractor(e), () => <B>[]).add(valueExtractor(e)));

  Iterable<A> mapIndexed<A>(A Function(int idx, T e) mapper) =>
      indexed.map((e) => mapper(e.$1, e.$2));

  T? reduceOrNull(T Function(T value, T element) combine) =>
      isEmpty ? null : reduce(combine);
}

extension ColorExensions on Color {
  Color darker([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighter([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

extension DurationExtensions on Duration {
  String pretty() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    final String mins = twoDigits(inMinutes.remainder(60));
    final String secs = twoDigits(inSeconds.remainder(60));

    String pretty = "";
    if (inHours != 0) pretty += "${inHours}h ";
    if (mins != "00") pretty += "${mins}min ";
    if (secs != "00") pretty += "${secs}s";

    return pretty.trim();
  }
}

extension RxFutureExtensions<T> on RxFuture<T> {
  Future<void> newValue(
    Future<T> Function(T?) callback, {
    void Function(T)? onSuccess,
    void Function(Object)? onError,
    void Function()? onMultipleCalls,
    void Function()? onCancel,
    void Function()? finallyDo,
    MultipleCallsBehavior multipleCallsBehavior =
        MultipleCallsBehavior.abortNew,
  }) =>
      observe(callback, onSuccess: (t) {
        onSuccess?.call(t);
        finallyDo?.call();
      }, onError: (t) {
        onError?.call(t);
        finallyDo?.call();
      }, onCancel: () {
        onCancel?.call();
        finallyDo?.call();
      });
}

extension BorderExtensions on Border {
  Border withoutLeft() => Border(top: top, right: right, bottom: bottom);
}

extension StaticExtensions on Static {
  bool userCanUpload() => commanders
      .any((e) => e.accountName == RunalyzerStorage.accountName && e.canUpload);
  bool userCanModify() => commanders
      .any((e) => e.accountName == RunalyzerStorage.accountName && e.canModify);
}

extension BoolExtensions on bool {
  bool not() => !this;

  RxBool notObs() => (!this).obs;

  int toInt() => this ? 1 : 0;
}

extension IntExtensions on int {
  bool inRange({int? min, int? max}) =>
      this >= (min ?? double.negativeInfinity) &&
      this <= (max ?? double.infinity);
}

extension GetExtensions on GetInterface {
  void reloadPage() {
    final Map<String, String> params = {};
    parameters.forEach((k, v) {
      if (v != null) params[k] = v;
    });

    offAndToNamed(currentRoute,
        arguments: arguments, parameters: params.isEmpty ? null : params);
  }
}

extension ScrollControllerExtensions on ScrollController {
  void scrollDown(
      {final Duration duration = const Duration(seconds: 1),
      final Curve curve = Curves.fastOutSlowIn}) {
    animateTo(
      position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }
}

extension TofRunExtensions on TofRun {
  int countFullFight(
          Mechanic Function(TofPhase) extractor, final String player) =>
      fullFight == null ? 0 : _countMechanic(player, extractor(fullFight!));

  int _countMechanic(final String player, final Mechanic mechanic) =>
      mechanic.counts
          .firstWhereOrNull((e) => e.player == player)
          ?.times
          .length ??
      0;
}
