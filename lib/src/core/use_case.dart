import 'dart:async';

import 'package:dartz/dartz.dart';

/// Use case contains the app's business logic / rules, e.g. validations.
/// It should be independent from any other non-business logic-related
/// functionalities.
///
/// It can be connected with repository, although not every use case needs to
/// depend on the repository.
///
/// If you can live with less static typing, you can use `Map<String,dynamic`
/// as Params.
abstract class UseCase<F, Type, Param> {
  FutureOr<Either<F, Type>> call({Param param});
}
