import 'package:rx_state_dart/rx_state_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Subject tests', () {
    int counter = 0;
    final subject = Subject(0);

    subscriber(int value) {
      counter = value;
    }

    test('Subject.subscribe() test', () {
      subject.subscribe(subscriber);

      subject.set(42);
      expect(counter, 42);

      subject.unsubscribe(subscriber);
    });

    test('Subject.subscribe() with lazy parameter test', () {
      subject.set(11);
      subject.subscribe(subscriber, lazy: false);

      expect(counter, 11);
      subject.set(42);
      expect(counter, 42);

      subject.unsubscribe(subscriber);
    });
  });
}
