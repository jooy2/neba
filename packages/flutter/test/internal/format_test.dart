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

  test('compacts a figure from ten thousand up, as an axis writes one', () {
    expect(nebaFormatCompact(9999), '9,999');
    expect(nebaFormatCompact(1234.567), '1,234.57');
    expect(nebaFormatCompact(10000), '10K');
    expect(nebaFormatCompact(12400), '12.4K');
    expect(nebaFormatCompact(-12400), '-12.4K');
    expect(nebaFormatCompact(1250000), '1.3M');
    expect(nebaFormatCompact(999960), '1M');
    expect(nebaFormatCompact(3e9), '3B');
    // From a thousand up, as `notation: 'compact'` writes it on its own.
    expect(nebaFormatCompact(8100, from: 1000, maxFractionDigits: 1), '8.1K');
    expect(nebaFormatCompact(999.5, from: 1000, maxFractionDigits: 1), '999.5');
    expect(nebaFormatCompact(124000, from: 1000, maxFractionDigits: 1), '124K');
  });

  test('writes a date as its month and its day', () {
    expect(nebaFormatMonthDay(DateTime(2026, 6, 1)), 'Jun 1');
    expect(nebaFormatMonthDay(DateTime(2026, 12, 31)), 'Dec 31');
  });
}
