import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';

/// Clears local storage of people
class ClearPeopleStorage extends UseCase<Failure, Unit, Unit> {
  final AutoPersistentPeopleRepository repo;

  ClearPeopleStorage({required this.repo});
  @override
  FutureOr<Either<Failure, Unit>> call({Unit param = unit}) async {
    return await repo.clear();
  }
}
