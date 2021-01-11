import 'dart:async';

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
///   Future<Session> readOne({GetParams params}) async {
///     /// Perform client.get() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param
abstract class SingleGetterDataSource<Type, Param> {
  FutureOr<Type> readOne({Param param});
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
///   Future<List<Session>> readMany({GetParams params}) async {
///     /// Perform client.get() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param
abstract class MultipleGetterDataSource<Type, Param> {
  FutureOr<List<Type>> readMany({Param param});
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
///   Future<Person> read({GetParams params}) async {
///     /// Perform client.post() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as Param
abstract class CreatorDataSource<Type, Param> {
  FutureOr<Type> create({Param param});
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
///   Future<Session> read({Person params}) async {
///     /// Perform client.put() or something using json form of provided
///     /// Person object.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as P
abstract class UpdaterDataSource<Type, Param> {
  FutureOr<Type> update({Param param});
}

/// Implement this abstract in your data source if it can perform data deletion.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class SessionDataSource implements DeleterDataSource<void, Null> {
///   final HttpClient client;
///
///   const SessionDataSource({@required this.client});
///
///   @override
///   Future<void> delete({Null params}) async {
///     /// Perform sign out
///   }
/// }
/// ```
///
/// P.S. Signing out means deleting session. Therefore, deleter data source.
abstract class DeleterDataSource<Type, Param> {
  FutureOr<Type> delete({Param param});
}
