import 'package:cornerstone/cornerstone.dart';
import 'package:cornerstone/src/utilities/convert_cornerstone_exception_to_failure.dart';
import 'package:test/test.dart';

void main() {
  test(
    'should convert cornerstone exception into failure with same name',
    () {
      final e = CornerstoneException(name: 'err.app.TEST_ERROR');
      final f = ConvertCornerstoneExceptionToFailure()(e);
      expect(f, Failure<Object?>(name: 'err.app.TEST_ERROR', details: e));
    },
  );

  test(
    'should convert non cornerstone exception into err.app.UNEXPECTED_ERROR',
    () {
      final e = Exception();
      final f = ConvertCornerstoneExceptionToFailure()(e);
      expect(f, Failure<Object?>(name: 'err.app.UNEXPECTED_ERROR', details: e));
    },
  );
}
