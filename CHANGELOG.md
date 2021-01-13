## [0.0.2] - 13 January 2020
- More consistency: Call in `UseCase` now accepts `Param param` instead of `Params params`.
- More flexibility: UseCase is now declared as `UseCase<F, Type, Param>`. This way, you can pick any `Failure` entity you want. You can always pass the provided `Failure` for convenience.

## [0.0.1] - 13 January 2020
- Initial release of Cornerstone