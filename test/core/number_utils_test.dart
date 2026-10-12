import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/core/utils/number_utils.dart';

void main() {
  test('parseNumber понимает разные форматы', () {
    expect(parseNumber('2,5'), 2.5);
    expect(parseNumber('2.5'), 2.5);
    expect(parseNumber('300 000'), 300000);
    expect(parseNumber('300 000'), 300000);
    expect(parseNumber('1,000,000'), 1000000);
    expect(parseNumber('1.000.000'), 1000000);
    expect(parseNumber('1.000.000,5'), 1000000.5);
    expect(parseNumber('1,000.25'), 1000.25);
    expect(parseNumber('-50'), -50);
    expect(parseNumber('abc'), isNull);
    expect(parseNumber(''), isNull);
  });

  test('formatInput без разделителей тысяч', () {
    expect(formatInput(300000), '300000');
    expect(formatInput(2.5), '2.5');
    expect(parseNumber(formatInput(1000000)), 1000000);
  });
}
