import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';

/// Load PeopleSnapshot locally and returns it.
class LoadPeople extends UseCase<Failure, NewPeopleSnapshot, Unit> {
  final AutoPersistentPeopleRepository repo;

  LoadPeople({required this.repo});
  @override
  FutureOr<Either<Failure, NewPeopleSnapshot>> call({Unit param = unit}) async {
    return await repo.load();
  }
}
