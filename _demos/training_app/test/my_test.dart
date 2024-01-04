import 'package:flutter_test/flutter_test.dart';

void main() {
  test('record equals', () {
    var recordA = (a: 1, b: 'test', 'test2');

    var recordB = (a: 1, b: 'test', 'test2');

    var map = <Record, String>{
      recordA: 'has a value',
    };

    expect(map[recordB], equals('has a value'));
  });
}
