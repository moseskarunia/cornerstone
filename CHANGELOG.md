## [0.1.0] - 20 January 2020
- **Breaking Change** `LocallyPersistentRepository` is now a mixin.
- Added `HivePersistentRepositoryMixin`. I find it really repetitive to make this every time, so I put it in the main library.
- Added `Hive` as a dependency for `HivePersistentRepositoryMixin`.
- Added `ConvertExceptionToFailure`. A mockable & reusable exception -> failure converter. This way if you have a lot of functions in a repo, doesn't need to keep testing each function for its error handling.
- Added `CornerstoneSnapshot`. You can use it as base class for your repositories. It have built-in convenience like timestamp.
- Example project has been updated to also includes `HivePersistentRepositoryMixin` usage.

## [0.0.2] - 13 January 2020
- More consistency: Call in `UseCase` now accepts `Param param` instead of `Params params`.
- More flexibility: UseCase is now declared as `UseCase<F, Type, Param>`. This way, you can pick any `Failure` entity you want. You can always pass the provided `Failure` for convenience.

## [0.0.1] - 13 January 2020
- Initial release of Cornerstone