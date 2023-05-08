import '../types/observable.dart';

/// Main entity for manipulate with dynamic data
class Subject<T> extends Observable<T> {
  T _value;

  Subject(this._value);

  final Set<void Function(T)> _subscribers = {};

  /// Method for immediately get current Subject value
  @override
  T get() {
    return _value;
  }

  /// Method for manually change Subject value
  void set(T value) {
    _value = value;
    notifySubscribers();
  }

  /// Method for subscribe on Subject value changes. On every change callback will be executed.
  /// For immediately execute callback after subscription add 'lazy: false' parameter
  @override
  void subscribe(void Function(T) callback, {bool lazy = true}) {
    _subscribers.add(callback);

    if (!lazy) {
      callback(_value);
    }
  }

  /// Method for unsubscribe from Subject
  @override
  void unsubscribe(void Function(T) callback) {
    _subscribers.remove(callback);
  }

  void notifySubscribers() {
    for (var callback in _subscribers) {
      callback(_value);
    }
  }
}
