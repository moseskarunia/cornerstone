import 'package:cornerstone/cornerstone.dart';
import 'package:test/test.dart';

void main() {
  test('Failure props', () {
    final f = Failure<Map<String, dynamic>>(
      name: 'TEST_ERROR',
      details: <String, dynamic>{'message': 'Lorem ipsum'},
    );
    expect(f.props, [
      'TEST_ERROR',
      <String, dynamic>{'message': 'Lorem ipsum'},
    ]);
  });
}
