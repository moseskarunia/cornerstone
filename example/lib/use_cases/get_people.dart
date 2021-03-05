import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/repositories/auto_persistent_people_repository.dart';

/// Call the server and return NewPeopleSnapshot.
/// Unit is just a way to represent void in a non void way.
class GetPeople extends UseCase<Failure, NewPeopleSnapshot, Unit> {
  final AutoPersistentPeopleRepository repo;

  GetPeople({required this.repo});

  @override
  FutureOr<Either<Failure, NewPeopleSnapshot>> call({Unit param = unit}) async {
    return await repo.getPeople();
  }
}
