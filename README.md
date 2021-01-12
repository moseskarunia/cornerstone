# Cornerstone

Set up your app development with a proper architecture without having to write a lot of boilerplate code. Inspired by clean architecture.

# Objectives

Cornerstone have 2 main goals:

## 1. Provides reusable skeleton to help set up clean architecture.

The first time I learned clean architecture and applied it to a real-world project, I felt increased confidence in my app maintainability. Refactor and feature additions are pleasant experience. But it's a pain to set up initially. That's why I create cornerstone. It's a library to help me set up clean architecture in a consistent and less-repetitive way. I hope you can also find it helpful too.

## 2. Provides reusable way to implement common use cases.

### CRUD Operations

Most modern apps revolves around CRUD operations through an API. In common scenarios, mostly it's just:
- Getting one or more X.
- Creating X through a json in the body and getting the created data as the response
- Updating X with a set of parameters.
- Deleting one or more X with some requirements.

Imagine you need to do it for each entities in your app. For me it's super boring to write. Not to mention that it needs to be tested in multiple layers (data source, repository, and use cases).

That's why I plan to write some implementations of cornerstone abstracts for common use cases utilizing dart generics. With generics, we can get consistent behavior for different type of entities.

If you need a more specific use case, you can always write your own implementation.

### Exception Handling

Learning clean architecture from [this](https://resocoder.com/category/tutorials/flutter/tdd-clean-architecture/) tutorial, makes me hate exceptions. Normally, repository is the last layer I want my exceptions to live, so a try catch block should be in the repository functions.

The problem with this approach is each functions in your repository must be wrapped in a try catch block, which subsequently needs to be tested as well. I like to test my apps, doesn't mean that I like to copy-pasted it several times. Multiplies it by... (you know the drill).

In the next update, I plan on writing a helper function to automatically wraps function to directly transforms it into Failure model without having to repeatedly write test for it.

Maybe something like:

```dart
class CallSafely {
  FutureOr<Either<Failure,T>> call<P>({@required T Function(P) f, P param}){
    try {
      return Right(await f(param));
    } on CommonException catch (e) {
      return Left(Failure(name: e.name, e.details));
    } catch (e) {
      return Left(Failure(name:'UNEXPECTED_ERROR', details: e.toString()));
    }
  }
}
```