import 'dart:async';

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
/// Sample implementation:
/// ```dart
/// mixin MyCachableRepoMixin implements DataCacheRepository {
///   /// Your implementation
/// }
///
/// class MyRepo with MyCachableRepoMixin {
///   List<int> myIntegers;
///   DateTime lastUpdated;
///
///   Future<void> save() async {
///     await write(<String,dynamic>{
///       'myIntegers': myIntegers,
///       'lastUpdated' : lastUpdated.toIso8601String(),
///     });
///   }
///
///   Future<void> load() async {
///     final loadedData = await load();
///
///     if(loadedData == null){
///       return;
///     }
///
///     this.myIntegers = loadedData['myIntegers'] ?? [];
///     this.lastUpdated = DateTime.tryParse(loadedData['lastUpdated']);
///   }
///
///    /// Other codes
/// }
/// ```
abstract class LocallyPersistentRepository {
  /// Write the repository fields you want to cache locally. The key should
  /// matches the fieldName of those fields.
  ///
  /// [json]'s value should only contains
  /// [json-valid values](https://www.w3schools.com/js/js_json_datatypes.asp)
  ///
  /// To make dealing with json easier, I recommend
  /// [json_serializable](https://pub.dev/packages/json_serializable)
  Future<void> write(Map<String, dynamic> json);

  /// Load from cache.
  /// To make dealing with json easier, I recommend
  /// [json_serializable](https://pub.dev/packages/json_serializable)
  Future<Map<String, dynamic>> load();

  /// Clear the entire collection of the cache.
  Future<void> clear();

  /// The default storageName of your repository. Think of it like a table or
  /// collection name. By default will use the string of your implementation's
  /// runtimeType.
  String get storageName => '${this.runtimeType.toString()}$id';

  /// If somehow you need more than one repositories with a same type,
  /// you can override [id] to distinguish those.
  String get id => '';
}
