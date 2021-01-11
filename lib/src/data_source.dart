import 'dart:async';

import 'package:cornerstone/src/failure.dart';
import 'package:dartz/dartz.dart';

/// Implement this abstract in your data source if it can fetch some data.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class GetParams {
///   final String token;
/// }
///
/// class SessionDataSource implements
///   SingleGetterDataSource<Session, GetParams> {
///
///   final HttpClient client;
///
///   const SessionDataSource({@required this.client});
///
///   @override
///   FutureOr<Either<Failure,Session>> readOne({GetParams params}) async {
///     /// Perform client.get() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
///
/// Instead of throwing an exception, you should return Left instead.
abstract class SingleGetterDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> readOne({Param param});
}

/// Implement this abstract in your data source if it can fetch some data.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class GetParams {
///   final String name;
/// }
///
/// class PeopleDataSource implements
///   MultipleGetterDataSource<Person, GetParams> {
///
///   final HttpClient client;
///
///   const PeopleDataSource({@required this.client});
///
///   @override
///   FutureOr<Either<Failure,List<Session>>> readMany({GetParams params}) async {
///     /// Perform client.get() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
///
/// Instead of throwing an exception, you should return Left instead.
abstract class MultipleGetterDataSource<Type, Param> {
  FutureOr<Either<Failure, List<Type>>> readMany({Param param});
}

/// Implement this abstract in your data source if it can perform data creation.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class SignInParams {
///   final String email, password;
/// }
///
/// class AuthDataSource implements CreatorDataSource<Session, SignInParams> {
///   final HttpClient client;
///
///   const AuthDataSource({@required this.client});
///
///   @override
///   FutureOr<Either<Failure,Person>> read({GetParams params}) async {
///     /// Perform client.post() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
///
/// Instead of throwing an exception, you should return Left instead.
abstract class CreatorDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> create({Param param});
}

/// Implement this abstract in your data source if it can perform data update
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class PeopleDataSource implements UpdaterDataSource<Person, Person> {
///   final HttpClient client;
///
///   const PeopleDataSource({@required this.client});
///
///   @override
///   Future<Either<Failure, Session>> read({Person params}) async {
///     /// Perform client.put() or something using json form of provided
///     /// Person object.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
///
/// Instead of throwing an exception, you should return Left instead.
abstract class UpdaterDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> update({Param param});
}

/// Implement this abstract in your data source if it can perform data deletion.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class SessionDataSource implements DeleterDataSource<Unit, Null> {
///   final HttpClient client;
///
///   const SessionDataSource({@required this.client});
///
///   @override
///   FutureOr<Either<Failure, Unit>> delete({Null params}) async {
///     /// Perform sign out
///   }
/// }
/// ```
///
/// Instead of throwing an exception, you should return Left instead.
///
/// P.S. Signing out means deleting session. Therefore, deleter data source.
/// P.S.S. Unit is how we represents void in dartz.
abstract class DeleterDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> delete({Param param});
}
