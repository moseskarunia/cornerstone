# Cornerstone

![cornerstone](https://github.com/moseskarunia/cornerstone/workflows/cornerstone/badge.svg?branch=master) [![codecov](https://codecov.io/gh/moseskarunia/cornerstone/branch/master/graph/badge.svg?token=5YRJCADULI)](https://codecov.io/gh/moseskarunia/cornerstone) [![pub package](https://img.shields.io/pub/v/cornerstone.svg)](https://pub.dev/packages/cornerstone)

A library written in pure dart to help devs set up dart projects with a proper architecture without having to write a lot of boilerplate code. Inspired by clean architecture.

# Objectives

Cornerstone have 2 main goals:

## 1. Provides reusable skeleton to help set up clean architecture.

The first time I learned clean architecture and applied it to a real-world project, I felt increased confidence in my app maintainability. Refactor and feature additions are pleasant experience. But it's a pain to set up initially. That's why I create cornerstone. It's a library to help me set up clean architecture in a consistent and less-repetitive way. I hope you can also find it helpful too.

## 2. Provides reusable way to implement common use cases

Most modern apps revolves around CRUD operations through an API & Data Persistence. I plan to make some utilities features to quickly adds common features to dart apps.

### CornerstonePersistentRepositoryMixin

A mixin to make your repository persistable locally easily. I use [Hive](https://pub.dev/packages/hive) in order to achieve this. See the dartdoc in the file & implementation example in the example folder for more info and usage example.

# The Architecture

Disclaimer: Even if I would say cornerstone is inspired from Clean Architecture, I wouldn't say that it adheres purely to clean architecture. You can see the complete app I made in the example folder for more details. It's a command line / terminal app written in pure dart.

<img src="https://raw.githubusercontent.com/moseskarunia/cornerstone/master/graphics/architecture.png" alt="Cornerstone Architecture">

In this section, I will focus on explaining this library interpretation. So, I recommend to read [this](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) article for more comprehensive understanding regarding clean architecture.

## Platform (The left most with black background)

Platform is the "outside world". This includes server, database, 3rd party libraries, firebase, and such. It'll be better if you use interface to interacts with platform. This makes it easier to achieve layer independency. If you do, I also recommend you handle platform exceptions and transform them into your app's common exception type. This makes it easier to handle those Exceptions in repository.

I didn't use platform interface in my example project to make it simpler.

Sample platform interface:

```dart
abstract class CleanHttpClient {
  FutureOr<Object> get(String path, {Map<String,dynamic> queryParams = {}});
}

class DioCleanHttpClient extends CleanHttpClient {
  final Dio dio;

  const DioCleanHttpClient({required this.dio});

  FutureOr<Object> get(String path, {Map<String,dynamic> queryParams = {}}) async {
    // TODO: implement get for dio.
  }
}
```

I don't provide the abstract for it (at least yet) because it's easier to implement it yourself to match your need.

## Data Source

Data source acts as the gateway to the "outside world" such as server (through API), database, and other third party libraries. Data source usually interacts with platform libraries, such as `HttpClient`, `Dio`, `Hive`, `SharedPreference` etc.

With that being said, it might be better if you make your data sources interact with platform through a platform interface. So, for example, if you need to switch from `SharedPreference` to `Hive` as your local storage solution, you can easily do so without directly impacts your data sources.

Remember that you need to make an abstract of your data sources to be used as repository dependency.

-----

In Cornerstone, there are 5 kinds of abstract data sources to mix and match.
- `SingleGetterDataSource`
- `MultipleGetterDataSource`
- `CreatorDataSource`
- `UpdaterDataSource`
- `DeleterDataSource`

For example, if you only need your data source to GET and CREATE, you can write it like:

```dart
abstract class PeopleDataSource 
  implements MultipleGetterDataSource<Person, Unit>, CreatorDataSource<Person,Person>{}

class PeopleDataSourceImpl extends PeopleDataSource {
  final Dio client;

  PeopleDataSourceImpl({required this.client});

  @override
  FutureOr<List<Person>> readMany({Unit param = unit}) async {
    // TODO: implement readMany
  }

  @override
  FutureOr<Person> create({required Person param}) {
    // TODO: implement create
  }
}

/// Note: Use `Unit` from dartz to represent void.
```

See docs and example project to learn more.

## Repository

Repository acts as the hub of several data sources. For example if you have more than 1 servers, repository is the place where I would put the logic of the fetching strategy (or data source calling strategy to be more precise).

Another thing it does is exception handling. In your repository, you should catch your exceptions, transform it into Failure model and returns it as `Left` value with [dartz](https://pub.dev/packages/dartz). This makes you don't need to always put try catch block in the subsequent layers.

Like data source, you need to write an abstract first since your use cases will interacts with repository through interface.

### About LocallyPersistentRepository

Some of you might prefer to put local-persistence strategy in the data source. And it's ok since in my older projects, that's also what I did. But, after further considerations, I decided to name cornerstone's local-persistence strategy abstract class as a "Repository" instead of "Data Source". Because for my taste, persisting data can be considered as a "repository thing". Also, with this approach, I think it will make the code easier to read as well since it will produce a clearer separation of concerns like:

- Data source: retrieving data
- Repository: managing retrieved data

In my example project, I implement `LocallyPersistentRepository` as a mixin. This way, you can reuse your local persistence logic, or even not using it at all if you don't want to implement persistence for your repo.

## Use Case

Use case is where your app's business logics and validations live. This layer should be independent regardless database, or presentation logic. The idea is that, use case will only change if your business process changes.

Use case can depend / call another use case. This way, it'll be better to keep 1 use case as single-concerned as possible.

# Knitting them together

There are several way to knit / put those layers together. First, is by using something like `InheritedWidget`. But for me, I prefer to use a service locator library called [Get It](https://pub.dev/packages/get_it).

This is how I did it in my example project:

```dart
void initArchitecture() {
  EquatableConfig.stringify = true;

  Hive.init(Directory.current.path + '/db');

  GetIt.I.registerLazySingleton(() => Dio());
  GetIt.I.registerLazySingleton<PeopleDataSource>(
    () => PeopleDataSourceImpl(client: GetIt.I()),
  );
  GetIt.I.registerLazySingleton<PeopleRepository>(
    () => PeopleRepositoryImpl(dataSource: GetIt.I(), hive: Hive),
  );
  GetIt.I.registerLazySingleton(() => GetPeople(repo: GetIt.I()));
  GetIt.I.registerLazySingleton(() => LoadPeople(repo: GetIt.I()));
  GetIt.I.registerLazySingleton(() => ClearPeopleStorage(repo: GetIt.I()));
}
```

And then, I simply call it from main like:

```dart
void main() async {
  initArchitecture();

  /// Rest of the code
}
```

-----

In a larger project though, it's recommended to split it into several initializator from several files to make it more readable, maybe something like:

```dart
/// Somewhere under lib/platforms
void initPlatforms() {
  EquatableConfig.stringify = true;
  Hive.init(Directory.current.path + '/db');
  GetIt.I.registerLazySingleton(() => Dio());
}

/// Somewhere under lib/data_sources
void initDataSources() {
  GetIt.I.registerLazySingleton<PeopleDataSource>(
    () => PeopleDataSourceImpl(client: GetIt.I()),
  );
}

/// Somewhere under lib/repositories
void initRepositories() {
  GetIt.I.registerLazySingleton<PeopleRepository>(
    () => PeopleRepositoryImpl(dataSource: GetIt.I(), hive: Hive),
  );
}

/// Somewhere under lib/use_cases
void initUseCases() {
  GetIt.I.registerLazySingleton(() => GetPeople(repo: GetIt.I()));
  GetIt.I.registerLazySingleton(() => LoadPeople(repo: GetIt.I()));
  GetIt.I.registerLazySingleton(() => ClearPeopleStorage(repo: GetIt.I()));
}

/// Somewhere under lib
void initArchitecture() {
  initPlatforms();
  initDataSources();
  initRepositories();
  initUseCases();
}
```

# What's next?
- Stream abstracts
- More common use cases implementations

# Support

I will appreciate any star to the github repo as well as like to the pub.dev page of this library. If you want, you can also buy me a cup of coffee by clicking the button below to motivate me creating helpful libraries in the future! Thanks for your support!

<a href="https://www.buymeacoffee.com/moseskarunia" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="50"></a>

I also welcome if anyone want to collaborate with me in this project. The more the merrier!

# Why "Cornerstone"?

> The cornerstone (or foundation stone or setting stone) is the first stone set in the construction of a masonry foundation. All other stones will be set in reference to this stone, thus determining the position of the entire structure. ([Wikipedia](https://en.wikipedia.org/wiki/Cornerstone))