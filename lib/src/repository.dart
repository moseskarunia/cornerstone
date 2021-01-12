import 'dart:async';

import 'package:cornerstone/src/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Cachable repository to the local storage.
///
/// I don't think it needs a delete by key function, since if the key is the
/// fieldName (which it should), then it cannot have key deleted.
///
/// It's recommended to implement this as a mixin to make it resuable across
/// your repositories.
///
/// To make dealing with json easier, I recommend
/// [json_serializable](https://pub.dev/packages/json_serializable)
///
/// For usage example, check the example project.
/// ```
abstract class LocallyPersistentRepository {
  /// Write the repository fields you want to persist locally. The key should
  /// matches the fieldName of those fields.
  ///
  /// Override [asJson] to provide value for this function.
  @visibleForOverriding
  Future<Either<Failure, Unit>> save();

  /// Read from local storage.
  ///
  /// To make dealing with json easier, I recommend
  /// [json_serializable](https://pub.dev/packages/json_serializable)
  @visibleForOverriding
  Future<Either<Failure, Map<String, dynamic>>> load();

  /// Clear the local storage.
  ///
  /// Unit is dartz way to represents void, since it's not possible to write
  /// `Either<Failure, void>`
  ///
  /// ```dart
  /// Right(unit);
  /// ```
  @visibleForOverriding
  Future<Either<Failure, Unit>> clear();

  /// The default storageName of your repository. Think of it like a table or
  /// collection name. Will use the string of your implementation's
  /// runtimeType.
  ///
  /// If you need to modify this, override [id] instead.
  @nonVirtual
  String get storageName => '${this.runtimeType.toString()}${id ?? ''}';

  /// If somehow you need more than one repositories with a same type,
  /// you can override [id] to distinguish those.
  @visibleForOverriding
  String get id => '';

  /// Repo data as Map<String,dynamic> (json).
  ///
  /// [json]'s value should only contains
  /// [json-valid values](https://www.w3schools.com/js/js_json_datatypes.asp)
  ///
  /// To make dealing with json easier, I recommend
  /// [json_serializable](https://pub.dev/packages/json_serializable)
  ///
  /// Unit is dartz way to represents void, since it's not possible to write
  /// `Either<Failure, void>`
  ///
  /// ```dart
  /// Right(unit);
  /// ```
  ///
  /// To make dealing with json easier, I recommend using
  /// [json_serializable](https://pub.dev/packages/json_serializable)
  @visibleForOverriding
  Map<String, dynamic> get asJson;
}
