import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/utilities/hive_persistent_repository_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

class MockConvertToFailure extends Mock implements ConvertToFailure {}

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
        HivePersistentRepositoryMixin<FruitSnapshot> {}

class FruitRepositoryImpl extends FruitRepository {
  @override
  final ConvertToFailure convertToFailure;
  final HiveInterface hive;

  FruitSnapshot data = FruitSnapshot(
    data: [],
    timestamp: DateTime(2020, 10, 10),
  );

  FruitRepositoryImpl({
    @required this.hive,
    @required this.convertToFailure,
  });

  @override
  Map<String, dynamic> get asJson => <String, dynamic>{
        'data': data.data,
        'timestamp': data.timestamp.toUtc().toIso8601String()
      };

  @override
  Future<Either<Failure, FruitSnapshot>> load() => throw UnimplementedError();
}

void main() {
  MockBox box;
  MockConvertToFailure convertToFailure;
  FruitRepositoryImpl repo;
  MockHive hive;

  setUp(() {
    convertToFailure = MockConvertToFailure();
    box = MockBox();
    hive = MockHive();
    repo = FruitRepositoryImpl(hive: hive, convertToFailure: convertToFailure);

    when(hive.openBox(any)).thenAnswer((_) async => box);
  });
  group('HivePersistenceRepositoryMixin', () {
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

    group('loadData', () {
      test(
          'should catch Exception '
          'and return the result of convertToFailure', () async {
        final e = HiveError('TEST_ERROR');
        when(box.toMap()).thenThrow(e);
        when(convertToFailure(any)).thenReturn(Failure(name: 'TEST_ERROR'));

        final result = await repo.loadData();

        expect((result as Left).value, Failure(name: 'TEST_ERROR'));

        verifyInOrder([
          hive.openBox(repo.storageName),
          box.toMap(),
          convertToFailure(e),
        ]);
      });

      test('should return the loaded json', () async {
        when(box.toMap()).thenReturn(<String, dynamic>{'name': 'John Doe'});
        final result = await repo.loadData();
        expect((result as Right).value, <String, dynamic>{'name': 'John Doe'});
      });
    });
  });
}
