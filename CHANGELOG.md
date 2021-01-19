## [0.1.0] - 19 January 2020
- Add `MultipleGetterRepository` to make it easier to implement common getter functionality of a repository.
- Add `ConvertExceptionToFailure`. A mockable & reusable exception -> failure converter. This way if you have a lot of functions in a repo, doesn't need to keep testing each function for its error handling.
- Add `CornerstoneSnapshot`. You can use it as base class for your repositories. It have built-in convenience like timestamp.

## [0.0.2] - 13 January 2020
- More consistency: Call in `UseCase` now accepts `Param param` instead of `Params params`.
- More flexibility: UseCase is now declared as `UseCase<F, Type, Param>`. This way, you can pick any `Failure` entity you want. You can always pass the provided `Failure` for convenience.

## [0.0.1] - 13 January 2020
- Initial release of Cornerstone