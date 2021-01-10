import 'dart:async';

/// Implement this abstract in your data source if it can fetch some data.
/// Note that 1 class can **implements** from multiple abstracts.
///
/// ```dart
/// class GetParams {
///   final String token;
/// }
///
/// class SessionDataSource implements GetterDataSource<Session, GetParams> {
///   final HttpClient client;
///
///   const SessionDataSource({@required this.client});
///
///   @override
///   Future<Session> read({GetParams params}) async {
///     /// Perform client.get() or something.
///   }
/// }
/// ```
///
/// If you can live with less type safety, you can simply use
/// `Map<String,dynamic>` as P
abstract class GetterDataSource<T, P> {
  FutureOr<T> read({P params});
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
/// `Map<String,dynamic>` as P
abstract class CreatorDataSource<T, P> {
  FutureOr<T> create({P params});
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
abstract class UpdaterDataSource<T, P> {
  FutureOr<T> update({P params});
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
abstract class DeleterDataSource<T, P> {
  FutureOr<T> delete({P params});
}
