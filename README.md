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

## 1. Data source




