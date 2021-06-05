import 'dart:async';

import 'package:cornerstone/cornerstone.dart';
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
///   const SessionDataSource({required this.client});
///
///   @override
///   FutureOr<Session> readOne({GetParams params}) async {
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
  FutureOr<Type> readOne({required Param param});
}

/// Similar to [SingleGetterDataSource], only returns Either form right away.
abstract class SafeSingleGetterDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> readOne({required Param param});
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
///   const PeopleDataSource({required this.client});
///
///   @override
///   FutureOr<List<Person>> readMany({GetParams params}) async {
///     /// Perform client.get() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
abstract class MultipleGetterDataSource<Type, Param> {
  FutureOr<List<Type>> readMany({required Param param});
}

/// Similar to [MultipleGetterDataSource], only returns Either form right away.
abstract class SafeMultipleGetterDataSource<Type, Param> {
  FutureOr<Either<Failure, List<Type>>> readMany({required Param param});
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
///   const AuthDataSource({required this.client});
///
///   @override
///   FutureOr<Person> read({GetParams params}) async {
///     /// Perform client.post() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
abstract class CreatorDataSource<Type, Param> {
  FutureOr<Type> create({required Param param});
}

/// Similar to [CreatorDataSource], only returns Either form right away.
abstract class SafeCreatorDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> create({required Param param});
}

/// Implement this abstract in your data source if it can perform data update
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class PeopleDataSource implements UpdaterDataSource<Person, Person> {
///   final HttpClient client;
///
///   const PeopleDataSource({required this.client});
///
///   @override
///   FutureOr<Person> read({required Person params}) async {
///     /// Perform client.put() or something using json form of provided
///     /// Person object.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param.
abstract class UpdaterDataSource<Type, Param> {
  FutureOr<Type> update({required Param param});
}

/// Similar to [UpdaterDataSource], only returns Either form right away.
abstract class SafecUpdaterDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> update({required Param param});
}

/// Implement this abstract in your data source if it can perform data deletion.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class SessionDataSource implements DeleterDataSource<Unit, Unit> {
///   final HttpClient client;
///
///   const SessionDataSource({required this.client});
///
///   /// Use unit to represent void
///   @override
///   FutureOr<Unit> delete({Unit params = unit}) async {
///     /// Perform sign out
///   }
/// }
/// ```
///
/// Instead of throwing an exception, you should return Left instead.
///
/// P.S. Signing out means deleting session. Therefore, deleter data source.
abstract class DeleterDataSource<Type, Param> {
  FutureOr<Type> delete({required Param param});
}

/// Similar to [DeleterDataSource], only returns Either form right away.
abstract class SafeDeleterDataSource<Type, Param> {
  FutureOr<Either<Failure, Type>> delete({required Param param});
}
