import 'package:cornerstone/src/core/cornerstone_exception.dart';
import 'package:test/test.dart';

void main() {
  test('CornerstoneException props', () {
    final f = CornerstoneException<Map<String, dynamic>>(
      name: 'TEST_ERROR',
      details: <String, dynamic>{'message': 'Lorem ipsum'},
    );
    expect(f.props, [
      'TEST_ERROR',
      <String, dynamic>{'message': 'Lorem ipsum'},
    ]);
  });
}
