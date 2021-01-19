import 'package:clock/clock.dart';
import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/utilities/multiple_getter_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockConvertExceptionToFailure extends Mock
    implements ConvertExceptionToFailure {}

class MockDataSource extends Mock
    implements MultipleGetterDataSource<String, FruitQueryParam> {}

class FruitSnapshot extends CornerstoneSnapshot {
  final List<String> data;

  FruitSnapshot({this.data = const []})
      : super(clock: const Clock(), timestamp: DateTime(2020, 10, 10));

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
    with MultipleGetterRepository<String, FruitSnapshot, FruitQueryParam> {}

class FruitRepositoryImpl extends FruitRepository {
  @override
  final ConvertExceptionToFailure convertExceptionToFailure;

  @override
  final MultipleGetterDataSource<String, FruitQueryParam>
      multipleGetterDataSource;

  FruitRepositoryImpl({
    @required this.multipleGetterDataSource,
    @required this.convertExceptionToFailure,
  });

  @override
  Future<FruitSnapshot> safelyGetMultiple({FruitQueryParam param}) async {
    return FruitSnapshot(
      data: await multipleGetterDataSource.readMany(param: param),
    );
  }
}

void main() {
  MockConvertExceptionToFailure convertExceptionToFailure;
  MockDataSource dataSource;
  FruitRepositoryImpl repo;

  setUp(() {
    convertExceptionToFailure = MockConvertExceptionToFailure();
    dataSource = MockDataSource();
    repo = FruitRepositoryImpl(
      convertExceptionToFailure: convertExceptionToFailure,
      multipleGetterDataSource: dataSource,
    );
  });
  group('getMultiple', () {
    test('should return Left Failure if data source throws Exception',
        () async {
      final exceptionFixture = Exception();
      when(dataSource.readMany(param: anyNamed('param')))
          .thenThrow(exceptionFixture);
      when(convertExceptionToFailure(any))
          .thenReturn(Failure(name: 'TEST_ERROR'));

      final result = await repo.getMultiple(
        param: FruitQueryParam(name: 'abc'),
      );

      expect((result as Left).value, Failure(name: 'TEST_ERROR'));
      verifyInOrder([
        dataSource.readMany(param: FruitQueryParam(name: 'abc')),
        convertExceptionToFailure(exceptionFixture),
      ]);
    });
    test('should return Right data if data source returns result', () async {
      when(dataSource.readMany(param: anyNamed('param')))
          .thenAnswer((_) async => ['Apple', 'Orange']);

      final result = await repo.getMultiple(
        param: FruitQueryParam(name: 'abc'),
      );

      expect(
        (result as Right).value,
        FruitSnapshot(data: ['Apple', 'Orange']),
      );
      verify(
        dataSource.readMany(param: FruitQueryParam(name: 'abc')),
      );
      verifyZeroInteractions(convertExceptionToFailure);
    });
  });
}
