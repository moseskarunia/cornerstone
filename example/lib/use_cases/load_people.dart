import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:meta/meta.dart';

/// Load PeopleSnapshot locally and returns it.
class LoadPeople extends UseCase<PeopleSnapshot, Null> {
  final PeopleRepository repo;

  LoadPeople({@required this.repo});
  @override
  FutureOr<Either<Failure, PeopleSnapshot>> call({Null params}) async {
    return await repo.load();
  }
}
