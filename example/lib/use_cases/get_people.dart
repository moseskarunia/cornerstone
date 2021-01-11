import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
import 'package:dartz/dartz.dart';
import 'package:example/entities/person.dart';
import 'package:example/repositories/people_repositories.dart';
import 'package:meta/meta.dart';

class GetPeople extends UseCase<List<Person>, Null> {
  final PeopleRepository repo;

  GetPeople({@required this.repo});
  @override
  FutureOr<Either<Failure, List<Person>>> call({Null params}) async {
    return await repo.getPeople();
  }
}
