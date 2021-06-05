import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/people_repository.dart';

/// Load PeopleSnapshot locally and returns it.
class LoadPeople extends UseCase<Failure, PeopleSnapshot, Unit> {
  final PeopleRepository repo;

  LoadPeople({required this.repo});
  @override
  FutureOr<Either<Failure, PeopleSnapshot>> call({Unit param = unit}) async {
    return await repo.load();
  }
}
