## [2.0.0-nullsafety.4] - 8 March 2021
- Update: `ConvertToFailure`'s call is now accepts `Object` instead of dynamic. The return is also changed from `Failure<dynamic>` to `Failure<Object>`. This change have 2 goals: To further enforce null-safety and because logically, it makes no sense to call `ConvertToFailure` with null parameter.

## [2.0.0-nullsafety.3] - 6 March 2021
- Update: Abstract classes' parameters are now required. A named param marked with `required` can still have its implementation accept default value instead of required. On the other hand, a non required param cannot be implemented with required. Therefore, for flexibility, all abstract classes' named parameters are now required. See example's people_data_source for more info.

## [2.0.0-nullsafety.2] - 5 March 2021
- Update: Bump hive dependency to 2.0.0.

## [2.0.0-nullsafety.1] - 4 March 2021
- New: Null-safety! To use, update your dart version to >=2.12.0, or use flutter 2.0.0
- Update: [CornerstonePersistentRepositoryMixin] If load is called on empty storage, will return a nicer Failure.

## [1.1.1] - 24 February 2021
- Fix: Properly export `CornerstoneException`.

## [1.1.0] - 24 February 2021
- New: `CornerstoneException`, a common exception model to make repository layer even more decoupled.
- Update: Bump `json_serialization` dependency to `^3.1.1`

## [1.0.0] - 2 February 2021
- **Breaking:** `CornerstonePersistentRepositoryMixin`'s `loadData()` is now removed. You just need to add dependency of `convertToSnapshot` to persistent repository with `CornerstonePersistentRepositoryMixin`. The mixin now handles loading data, and assigning it to `repo.snapshot` (Means less code to write!). The snapshot is now named `snapshot`, and declared in the mixin (you can override it). If you want to use other names for snapshot, you need to override `load`. You can override `snapshot` if you want to assign default value to it (See `auto_persistent_people_repository.dart` in example).
- First stable release of cornerstone! From now on, breaking changes will only introduced with new major version.

## [0.1.2] - 20 January 2021
- Revert: `LocallyPersistentRepository` is now an abstract class again. In dart, you can use an abstract class as a mixin, but you can't have your classes extends from a mixin. You can always implements a mixin, but it will lose some built-in implementation code (In this case, e.g. `storageName`). So by making it an abstract class again, it will give you more flexibility with nothing to give up. Therefore this revert will not breaking anything. _(In case you are wondering, This is not the case with `CornerstonePersistentRepositoryMixin`. If I make it an abstract and extends from `LocallyPersistentRepository`, then it can no longer be used as a mixin.)_
- Documentation: `MultipleGetterPersisitentRepository` should be written as `CornerstonePersistentRepositoryMixin` on `ConvertToSnapshot`'s dartdoc.

## [0.1.1] - 20 January 2021
- **Breaking**: `LocallyPersistentRepository` is now a mixin.
- New: `CornerstonePersistentRepositoryMixin` (was `HivePersistentRepositoryMixin` for a moment in 0.1.0) to easily add persistence functionality to your repos. Made possible using `Hive`.
- New: `Hive` as a dependency for `CornerstonePersistentRepositoryMixin`.
- New: `ConvertExceptionToFailure`. A mockable & reusable exception -> failure converter. This way if you have a lot of functions in a repo, doesn't need to keep testing each function for its error handling.
- New: `CornerstoneSnapshot`. You can use it as base class for your repositories. It have built-in convenience like timestamp.
- New: Example project has been updated to also includes `CornerstonePersistentRepositoryMixin` usage.

## [0.0.2] - 13 January 2021
- More consistency: Call in `UseCase` now accepts `Param param` instead of `Params params`.
- More flexibility: UseCase is now declared as `UseCase<F, Type, Param>`. This way, you can pick any `Failure` entity you want. You can always pass the provided `Failure` for convenience.

## [0.0.1] - 13 January 2021
- Initial release of Cornerstone