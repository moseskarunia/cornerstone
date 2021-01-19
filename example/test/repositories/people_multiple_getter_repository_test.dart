import 'package:cornerstone/cornerstone.dart';
import 'package:dio/dio.dart';
import 'package:example/repositories/people_multiple_getter_repository.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';

void main() {
  group('ConvertPeopleExceptionToFailure', () {
    ConvertPeopleExceptionToFailure convert;

    setUp(() {
      convert = ConvertPeopleExceptionToFailure();
    });
    test('should return Failure FAILED_TO_RETRIEVE_DATA', () {
      expect(
        convert(DioError(error: 'lorem ipsum')),
        Failure<dynamic>(
          name: 'FAILED_TO_RETRIEVE_DATA',
          details: DioError(error: 'lorem ipsum').toString(),
        ),
      );
    });
    test('should return Failure equal to HiveError message', () {
      expect(convert(HiveError('lorem ipsum')), Failure(name: 'lorem ipsum'));
    });
    test('should return Failure UNEXPECTED_ERROR with details', () {
      expect(
        convert(Exception()),
        Failure<dynamic>(
            name: 'UNEXPECTED_ERROR', details: Exception().toString()),
      );
    });
    test('should return Failure UNEXPECTED_ERROR without details', () {
      expect(convert('a'), Failure(name: 'UNEXPECTED_ERROR'));
    });
  });
}
