import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/utilities/cornerstone_persistent_repository_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'cornerstone_persistent_repository_mixin_test.mocks.dart';

class MockBox extends Mock implements Box {
  @override
  Future<void> putAll(Map entries) async =>
      await super.noSuchMethod(Invocation.method(#putAll, [entries]));

  @override
  Future<int> clear() async =>
      await super.noSuchMethod(Invocation.method(#clear, []), returnValue: 0);

  @override
  Map toMap() => super.noSuchMethod(Invocation.method(#toMap, []),
      returnValue: <String, dynamic>{});
}

class MockConvertToFailure extends Mock implements ConvertToFailure<Object> {
  @override
  Failure<Object> call(Object e) =>
      super.noSuchMethod(Invocation.method(#call, [e]),
          returnValue: Failure<Object>(name: 'err.app.TEST_ERROR', details: e));
}

class MockConvertToSnapshot extends Mock
    implements ConvertToSnapshot<FruitSnapshot> {
  @override
  FruitSnapshot call(Map data) =>
      super.noSuchMethod(Invocation.method(#call, [data]),
          returnValue: FruitSnapshot(timestamp: DateTime(2020, 10, 10)));
}

class FruitSnapshot extends CornerstoneSnapshot {
  final List<String> data;

  FruitSnapshot({this.data = const [], required DateTime timestamp})
      : super(clock: const Clock(), timestamp: timestamp);

  @override
  List<Object?> get props => [timestamp, data];
}

class FruitQueryParam extends Equatable {
  final String name;

  const FruitQueryParam({required this.name});

  @override
  List<Object?> get props => [name];
}

abstract class FruitRepository
    with
        LocallyPersistentRepository<FruitSnapshot>,
        CornerstonePersistentRepositoryMixin<FruitSnapshot> {}

class FruitRepositoryImpl extends FruitRepository {
  @override
  final ConvertToFailure<Object> convertToFailure;
  final ConvertToSnapshot<FruitSnapshot> convertToSnapshot;
  final HiveInterface hive;

  @override
  FruitSnapshot snapshot;

  FruitRepositoryImpl({
    required this.hive,
    required this.convertToFailure,
    required this.convertToSnapshot,
  }) : snapshot = FruitSnapshot(
          data: [],
          timestamp: DateTime.parse('2021-01-10T10:00:00Z').toLocal(),
        );

  @override
  Map<String, dynamic> get asJson => <String, dynamic>{
        'data': snapshot.data,
        'timestamp': snapshot.timestamp.toUtc().toIso8601String()
      };
}

@GenerateMocks([HiveInterface])
void main() {
  final dateFixture = DateTime.parse('2021-01-10T10:00:00Z').toLocal();
  late MockBox box;
  late MockConvertToFailure convertToFailure;
  late ConvertToSnapshot<FruitSnapshot> convertToSnapshot;
  late FruitRepositoryImpl repo;
  late MockHiveInterface hive;

  setUp(() {
    convertToSnapshot = MockConvertToSnapshot();
    convertToFailure = MockConvertToFailure();
    box = MockBox();
    hive = MockHiveInterface();
    repo = FruitRepositoryImpl(
      hive: hive,
      convertToFailure: convertToFailure,
      convertToSnapshot: convertToSnapshot,
    );

    when(hive.openBox(any)).thenAnswer((_) async => box);
    when(box.clear()).thenAnswer((_) async => 0);
  });
  group('CornerstonePersistenceRepositoryMixin', () {
    test('storageName should be FruitRepositoryImpl', () {
      expect(repo.storageName, 'FruitRepositoryImpl');
    });

    group('save', () {
      test(
        'should catch Exception and return the result of convertToFailure',
        () async {
          final e = HiveError('TEST_ERROR');
          when(box.putAll(repo.asJson)).thenThrow(e);
          when(convertToFailure(e)).thenReturn(Failure<Object>(
            name: 'TEST_ERROR',
            details: e,
          ));

          final result = await repo.save();

          expect((result as Left).value,
              Failure<Object>(name: 'TEST_ERROR', details: e));

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
      test('should catch Exception and return the result of convertToFailure',
          () async {
        final e = HiveError('TEST_ERROR');
        when(box.clear()).thenThrow(e);
        when(convertToFailure(e)).thenReturn(Failure<Object>(
          name: 'TEST_ERROR',
          details: e,
        ));

        final result = await repo.clear();

        expect((result as Left).value,
            Failure<Object>(name: 'TEST_ERROR', details: e));
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
          when(convertToFailure(e))
              .thenReturn(Failure<Object>(name: 'TEST_ERROR', details: e));

          final result = await repo.load();

          expect((result as Left).value,
              Failure<Object>(name: 'TEST_ERROR', details: e));

          verifyInOrder([
            hive.openBox(repo.storageName),
            box.toMap(),
            convertToFailure(e),
          ]);
        },
      );

      test(
        'should return err.cornerstone.EMPTY_LOCAL_STORAGE',
        () async {
          when(box.toMap()).thenReturn({});

          final result = await repo.load();

          expect(
            (result as Left).value,
            Failure<Object>(
              name: 'err.cornerstone.EMPTY_LOCAL_STORAGE',
              details: <String, dynamic>{'storageName': 'FruitRepositoryImpl'},
            ),
          );

          verifyInOrder([
            hive.openBox(repo.storageName),
            box.toMap(),
          ]);
        },
      );

      test('should assign snapshot and return the snapshot', () async {
        final mapFixture = <String, dynamic>{
          'data': ['Apple'],
          'timestamp': '2021-01-10T10:00:00Z'
        };
        when(box.toMap()).thenReturn(mapFixture);
        when(convertToSnapshot(mapFixture)).thenReturn(FruitSnapshot(
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
          FruitSnapshot(data: ['Apple'], timestamp: dateFixture),
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
