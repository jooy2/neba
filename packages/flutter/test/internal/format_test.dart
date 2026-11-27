import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/format.dart';

void main() {
  test('groups the thousands and keeps at most three digits after the point', () {
    expect(nebaFormatNumber(48210), '48,210');
    expect(nebaFormatNumber(1234567.891), '1,234,567.891');
    expect(nebaFormatNumber(0.12345), '0.123');
    expect(nebaFormatNumber(12.5), '12.5');
    expect(nebaFormatNumber(100), '100');
    expect(nebaFormatNumber(-1500.25), '-1,500.25');
  });

  test('writes a rounded-away figure as zero, never minus zero', () {
    expect(nebaFormatNumber(-0.0001), '0');
    expect(nebaFormatNumber(0), '0');
  });

  test('writes a ratio as a percentage', () {
    expect(nebaFormatPercent(0.1386, maxFractionDigits: 1), '13.9%');
    expect(nebaFormatPercent(0.75), '75%');
  });
}
