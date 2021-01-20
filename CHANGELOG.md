## [0.1.2] - 20 January 2020
- Revert: `LocallyPersistentRepository` is now an abstract class again. In dart, you can use an abstract class as a mixin, but you can't have your classes extends from a mixin. You can always implements a mixin, but it will lose some built-in implementation code (In this case, e.g. `storageName`). So by making it an abstract class again, it will give you more flexibility with nothing to give up. Therefore this revert will not breaking anything. _(In case you are wondering, This is not the case with `CornerstonePersistentRepositoryMixin`. If I make it an abstract and extends from `LocallyPersistentRepository`, then it can no longer be used as a mixin.)_
- Documentation: `MultipleGetterPersisitentRepository` should be written as `CornerstonePersistentRepositoryMixin` on `ConvertToSnapshot`'s dartdoc.

## [0.1.1] - 20 January 2020
- **Breaking**: `LocallyPersistentRepository` is now a mixin.
- New: `CornerstonePersistentRepositoryMixin` (was `HivePersistentRepositoryMixin` for a moment in 0.1.0). I find it really repetitive to make this every time, so I put it in the main library.
- New: `Hive` as a dependency for `CornerstonePersistentRepositoryMixin`.
- New: `ConvertExceptionToFailure`. A mockable & reusable exception -> failure converter. This way if you have a lot of functions in a repo, doesn't need to keep testing each function for its error handling.
- New: `CornerstoneSnapshot`. You can use it as base class for your repositories. It have built-in convenience like timestamp.
- New: Example project has been updated to also includes `CornerstonePersistentRepositoryMixin` usage.

## [0.0.2] - 13 January 2020
- More consistency: Call in `UseCase` now accepts `Param param` instead of `Params params`.
- More flexibility: UseCase is now declared as `UseCase<F, Type, Param>`. This way, you can pick any `Failure` entity you want. You can always pass the provided `Failure` for convenience.

## [0.0.1] - 13 January 2020
- Initial release of Cornerstone