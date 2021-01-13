import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/people_repository.dart';
import 'package:meta/meta.dart';

/// Call the server and return PeopleSnapshot
class GetPeople extends UseCase<PeopleSnapshot, Null> {
  final PeopleRepository repo;

  GetPeople({@required this.repo});
  @override
  FutureOr<Either<Failure, PeopleSnapshot>> call({Null params}) async {
    return await repo.getPeople();
  }
}
