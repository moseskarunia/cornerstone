import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:test/test.dart';

class DummySnapshot extends CornerstoneSnapshot {
  final List<String> fruits;

  DummySnapshot({this.fruits = const [], Clock clock, DateTime timestamp})
      : super(timestamp: timestamp, clock: clock);

  @override
  List<Object> get props => [timestamp, fruits];
}

void main() {
  test('should throw AssertionError if clock null', () {
    expectLater(
      () => DummySnapshot(
        fruits: ['Apple', 'Orange'],
        timestamp: DateTime(2020, 10, 10),
      ),
      throwsA(isA<AssertionError>()),
    );
  });
  test('should throw AssertionError if timestamp null', () {
    expectLater(
      () => DummySnapshot(fruits: ['Apple', 'Orange'], clock: Clock()),
      throwsA(isA<AssertionError>()),
    );
  });
  test('age', () {
    final snap = DummySnapshot(
      fruits: ['Apple', 'Orange'],
      clock: Clock.fixed(DateTime(2020, 10, 10, 9, 30, 30)),
      timestamp: DateTime(2020, 10, 11, 10, 40, 10),
    );

    expect(
      snap.age,
      DateTime(2020, 10, 11, 10, 40, 10).difference(
        DateTime(2020, 10, 10, 9, 30, 30),
      ),
    );
  });

  test('dateTimeToString', () {
    expect(dateTimeToString(DateTime(2020, 10, 10)),
        DateTime(2020, 10, 10).toUtc().toIso8601String());
  });
  test('dateTimeFromString', () {
    expect(dateTimeFromString('2020-10-10T00:00:00Z'),
        DateTime(2020, 10, 10).toLocal());
  });
}
