import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/hive_persistence_repository_mixin.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MyRepo extends LocallyPersistentRepository
    with HivePersistenceRepositoryMixin {
  final HiveInterface hive;

  List<String> fruits = ['Apple', 'Orange', 'Banana'];

  MyRepo({@required this.hive});

  @override
  Map<String, dynamic> get asJson => {'fruits': fruits};

  @override
  Future<Either<Failure, Unit>> load() {
    throw UnimplementedError();
  }
}

class MockHive extends Mock implements HiveInterface {}

class MockBox extends Mock implements Box {}

void main() {
  MockBox box;
  MyRepo repo;
  MockHive hive;

  setUp(() {
    box = MockBox();
    hive = MockHive();
    repo = MyRepo(hive: hive);

    when(hive.openBox(any)).thenAnswer((_) async => box);
  });
  group('HivePersistenceRepositoryMixin', () {
    test('storageName should be MyRepo', () {
      expect(repo.storageName, 'MyRepo');
    });

    group('save', () {
      tearDown(() {
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.putAll(repo.asJson),
        ]);
      });
      group('should catch', () {
        test('HiveError and converts it into Failure', () async {
          when(box.putAll(any)).thenThrow(HiveError('TEST_ERROR'));

          final result = await repo.save();

          expect((result as Left).value, Failure(name: 'TEST_ERROR'));
        });
        test('other Exception and converts it into Failure', () async {
          when(box.putAll(any)).thenThrow(Exception());

          final result = await repo.save();

          expect(
            (result as Left).value,
            Failure<dynamic>(
              name: 'UNEXPECTED_ERROR',
              details: Exception().toString(),
            ),
          );
        });
      });

      test('should return unit when succeed', () async {
        final result = await repo.save();
        expect((result as Right).value, unit);
      });
    });

    group('clear', () {
      tearDown(() {
        verifyInOrder([
          hive.openBox(repo.storageName),
          box.clear(),
        ]);
      });
      group('should catch', () {
        test('HiveError and converts it into Failure', () async {
          when(box.clear()).thenThrow(HiveError('TEST_ERROR'));

          final result = await repo.clear();

          expect((result as Left).value, Failure(name: 'TEST_ERROR'));
        });
        test('other Exception and converts it into Failure', () async {
          when(box.clear()).thenThrow(Exception());

          final result = await repo.clear();

          expect(
            (result as Left).value,
            Failure<dynamic>(
              name: 'UNEXPECTED_ERROR',
              details: Exception().toString(),
            ),
          );
        });
      });

      test('should return unit when succeed', () async {
        final result = await repo.clear();
        expect((result as Right).value, unit);
      });
    });
  });
}
