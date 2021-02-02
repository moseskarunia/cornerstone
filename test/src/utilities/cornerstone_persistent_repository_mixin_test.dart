import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/utilities/cornerstone_persistent_repository_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

class MockConvertToFailure extends Mock implements ConvertToFailure {}

class MockConvertToSnapshot extends Mock
    implements ConvertToSnapshot<Map<String, dynamic>, FruitSnapshot> {}

class FruitSnapshot extends CornerstoneSnapshot {
  final List<String> data;

  FruitSnapshot({this.data = const [], DateTime timestamp})
      : super(clock: const Clock(), timestamp: timestamp);

  @override
  List<Object> get props => [timestamp, data];
}

class FruitQueryParam extends Equatable {
  final String name;

  const FruitQueryParam({this.name});

  @override
  List<Object> get props => [name];
}

abstract class FruitRepository
    with
        LocallyPersistentRepository<FruitSnapshot>,
        CornerstonePersistentRepositoryMixin<FruitSnapshot> {}

class FruitRepositoryImpl extends FruitRepository {
  @override
  final ConvertToFailure convertToFailure;
  final ConvertToSnapshot<Map<String, dynamic>, FruitSnapshot>
      convertToSnapshot;
  final HiveInterface hive;

  @override
  FruitSnapshot snapshot;

  FruitRepositoryImpl({
    @required this.hive,
    @required this.convertToFailure,
    @required this.convertToSnapshot,
  }) : snapshot = FruitSnapshot(
          data: [],
          timestamp: DateTime.parse('2021-01-10T10:00:00Z').toLocal(),
        );

  @override
  Map<String, dynamic> get asJson => <String, dynamic>{
        'data': snapshot?.data,
        'timestamp': snapshot?.timestamp?.toUtc()?.toIso8601String()
      };
}

void main() {
  final dateFixture = DateTime.parse('2021-01-10T10:00:00Z').toLocal();
  MockBox box;
  MockConvertToFailure convertToFailure;
  MockConvertToSnapshot convertToSnapshot;
  FruitRepositoryImpl repo;
  MockHive hive;

  setUp(() {
    convertToSnapshot = MockConvertToSnapshot();
    convertToFailure = MockConvertToFailure();
    box = MockBox();
    hive = MockHive();
    repo = FruitRepositoryImpl(
      hive: hive,
      convertToFailure: convertToFailure,
      convertToSnapshot: convertToSnapshot,
    );

    when(hive.openBox(any)).thenAnswer((_) async => box);
  });
  group('CornerstonePersistenceRepositoryMixin', () {
    test('storageName should be FruitRepositoryImpl', () {
      expect(repo.storageName, 'FruitRepositoryImpl');
    });

    group('save', () {
      test(
        'should catch Exception '
        'and return the result of convertToFailure',
        () async {
          final e = HiveError('TEST_ERROR');
          when(box.putAll(any)).thenThrow(e);
          when(convertToFailure(any)).thenReturn(Failure(name: 'TEST_ERROR'));

          final result = await repo.save();

          expect((result as Left).value, Failure(name: 'TEST_ERROR'));

          verifyInOrder([
            hive.openBox(repo.storageName),
            box.putAll(repo.asJson),
            convertToFailure(e),
          ]);
        },
      );

      test('should return unit when succeed', () async {
        final result = await repo.save();
        expect((result as Right).value, unit);

        verifyInOrder([
          hive.openBox(repo.storageName),
          box.putAll(repo.asJson),
        ]);
        verifyZeroInteractions(convertToFailure);
      });
    });

    group('clear', () {
      test(
          'should catch Exception '
          'and return the result of convertToFailure', () async {
        final e = HiveError('TEST_ERROR');
        when(box.clear()).thenThrow(e);
        when(convertToFailure(any)).thenReturn(Failure(name: 'TEST_ERROR'));

        final result = await repo.clear();

        expect((result as Left).value, Failure<dynamic>(name: 'TEST_ERROR'));
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.clear(),
          convertToFailure(e),
        ]);
      });

      test('should return unit when succeed', () async {
        final result = await repo.clear();
        expect((result as Right).value, unit);
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.clear(),
          verifyZeroInteractions(convertToFailure),
        ]);
      });
    });

    group('load', () {
      test(
        'should catch Exception '
        'and return the result of convertToFailure',
        () async {
          final e = HiveError('TEST_ERROR');
          when(box.toMap()).thenThrow(e);
          when(convertToFailure(any)).thenReturn(Failure(name: 'TEST_ERROR'));

          final result = await repo.load();

          expect((result as Left).value, Failure(name: 'TEST_ERROR'));

          verifyInOrder([
            hive.openBox(repo.storageName),
            box.toMap(),
            convertToFailure(e),
          ]);
        },
      );

      test('should assign snapshot', () async {
        when(box.toMap()).thenReturn(<String, dynamic>{
          'data': ['Apple'],
          'timestamp': '2021-01-10T10:00:00Z'
        });
        when(convertToSnapshot(any)).thenReturn(FruitSnapshot(
          data: ['Apple'],
          timestamp: dateFixture,
        ));
        final result = await repo.load();
        expect(
          (result as Right).value,
          FruitSnapshot(data: ['Apple'], timestamp: dateFixture),
        );
        expect(
          repo.snapshot,
          FruitSnapshot(
            data: ['Apple'],
            timestamp: dateFixture,
          ),
        );
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.toMap(),
          convertToSnapshot(<String, dynamic>{
            'data': ['Apple'],
            'timestamp': '2021-01-10T10:00:00Z'
          }),
        ]);
      });
    });
  });
}
