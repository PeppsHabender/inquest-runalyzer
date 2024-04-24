import 'dart:math';

class PoolRandom<T> {
  final Random _random = Random();
  final List<T> _initialPool;
  final int _reset;

  late final List<T> _currPool;

  PoolRandom(this._initialPool, [this._reset = 0]) {
    _currPool = List.of(_initialPool);
  }

  T next() {
    if(_currPool.length <= _reset) _currPool.addAll(_initialPool);

    final int idx = _random.nextInt(_currPool.length);
    return _currPool.removeAt(idx);
  }

  void reset() => _currPool..clear()..addAll(_initialPool);
}