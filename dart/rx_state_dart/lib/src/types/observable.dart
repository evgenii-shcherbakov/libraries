/// Protected type for use outside state
abstract class Observable<T> {
  T get();
  void subscribe(void Function(T) callback, {bool lazy});
  void unsubscribe(void Function(T) callback);
}
