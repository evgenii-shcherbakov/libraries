import 'package:rx_state_dart/rx_state_dart.dart';

class _CounterState {
  final Subject<int> _counter$ = Subject(0);

  Observable<int> get value$ {
    return _counter$;
  }

  void inc(int value) {
    _counter$.set(_counter$.get() + value);
  }

  void dec(int value) {
    _counter$.set(_counter$.get() - value);
  }

  void reset() {
    _counter$.set(0);
  }
}

void _subscriber(int value) {
  print('Current value: $value');
}

void main() {
  var state = _CounterState();

  state.value$.subscribe(_subscriber, lazy: false);

  state.inc(42);
  state.dec(21);
  state.reset();

  state.value$.unsubscribe(_subscriber);
}
