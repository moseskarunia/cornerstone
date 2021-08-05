import 'package:example/repositories/people_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements PeopleRepository {}

void registerMocktailFallbacks() {
  registerFallbackValue<Map<dynamic, dynamic>>({});
}
