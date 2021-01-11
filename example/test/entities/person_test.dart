import 'package:example/entities/person.dart';
import 'package:test/test.dart';

void main() {
  group('Person', () {
    test('props', () {
      final p = Person(id: 123, name: 'John Doe', email: 'johndoe@test.com');
      expect(p.props, [123, 'John Doe', 'johndoe@test.com']);
    });

    test('toJson', () {
      expect(
        Person(id: 123, name: 'John Doe', email: 'johndoe@test.com').toJson(),
        <String, dynamic>{
          'id': 123,
          'name': 'John Doe',
          'email': 'johndoe@test.com',
        },
      );
    });

    test('fromJson', () {
      expect(
        Person.fromJson(<String, dynamic>{
          'id': 123,
          'name': 'John Doe',
          'email': 'johndoe@test.com',
        }),
        Person(id: 123, name: 'John Doe', email: 'johndoe@test.com'),
      );
    });
  });
}
