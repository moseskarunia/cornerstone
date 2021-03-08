import 'package:cornerstone/cornerstone.dart';

/// Converts CornerstoneException into Failure with identical name and details.
///
/// Other exceptions will have name err.app.UNEXPECTED_ERROR with detail equals
/// to the exception.
///
/// You can always make your own `ConvertToFailure` if you need custom
/// implementation.
class ConvertCornerstoneExceptionToFailure implements ConvertToFailure<Object> {
  const ConvertCornerstoneExceptionToFailure();
  @override
  Failure<Object> call(Object e) => Failure<Object>(
        name: e is CornerstoneException ? e.name : 'err.app.UNEXPECTED_ERROR',
        details: e,
      );
}
