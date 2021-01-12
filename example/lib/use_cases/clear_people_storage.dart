import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:meta/meta.dart';

/// Clears local storage of people
class ClearPeopleStorage extends UseCase<Unit, Null> {
  final PeopleRepository repo;

  ClearPeopleStorage({@required this.repo});
  @override
  FutureOr<Either<Failure, Unit>> call({Null params}) async {
    return await repo.clear();
  }
}
