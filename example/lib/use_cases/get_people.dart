import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/people_repository.dart';

/// Call the server and return PeopleSnapshot.
/// Unit is just a way to represent void in a non void way.
class GetPeople extends UseCase<Failure, PeopleSnapshot, Unit> {
  final PeopleRepository repo;

  GetPeople({required this.repo});

  @override
  FutureOr<Either<Failure, PeopleSnapshot>> call({Unit param = unit}) async {
    return await repo.getPeople();
  }
}
