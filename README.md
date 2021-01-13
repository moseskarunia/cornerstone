# Cornerstone

Set up your app development with a proper architecture without having to write a lot of boilerplate code. Inspired by clean architecture.

# Objectives

Cornerstone have 2 main goals:

## 1. Provides reusable skeleton to help set up clean architecture.

The first time I learned clean architecture and applied it to a real-world project, I felt increased confidence in my app maintainability. Refactor and feature additions are pleasant experience. But it's a pain to set up initially. That's why I create cornerstone. It's a library to help me set up clean architecture in a consistent and less-repetitive way. I hope you can also find it helpful too.

## 2. Provides reusable way to implement common use cases (Coming soon)

Most modern apps revolves around CRUD operations through an API. In common scenarios, mostly it's just:
- Getting one or more X.
- Creating X through a json in the body and getting the created data as the response
- Updating X with a set of parameters.
- Deleting one or more X with some requirements.

Imagine you need to do it for each entities in your app. For me it's super boring to write. Not to mention that it needs to be tested in multiple layers (data source, repository, and use cases).

That's why I plan to write some implementations of cornerstone abstracts for common use cases utilizing dart generics. With generics, we can get consistent behavior for different type of entities.

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
  FutureOr<dynamic> get(String path, {Map<String,dynamic> queryParams});
}

class DioCleanHttpClient extends CleanHttpClient {
  final Dio dio;

  const DioCleanHttpClient({@required this.dio});

  FutureOr<dynamic> get(String path, {Map<String,dynamic> queryParams}) async {
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
  implements MultipleGetterDataSource<Person, Null>, CreatorDataSource<Person,Person>{}

class PeopleDataSourceImpl extends PeopleDataSource {
  final Dio client;

  PeopleDataSourceImpl({@required this.client});

  @override
  FutureOr<List<Person>> readMany({Null param}) async {
    // TODO: implement readMany
  }

  @override
  FutureOr<Person> create({Person param}) {
    // TODO: implement create
  }
}
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