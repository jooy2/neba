/// Numbers written as the React package's default `Intl.NumberFormat` writes
/// them in English, for the widgets that print a figure of their own.
///
/// The widgets layer has no `intl` and the package takes no dependency, so a
/// figure in another language's separators, a currency or a unit is the
/// caller's, through a `format` function. What is here is the default: digits
/// grouped by threes with a comma, and at most three after the point.
///
/// The library talking to itself: nothing here is exported.
library;

/// [value] with its thousands grouped and at most [maxFractionDigits] digits
/// after the point, trailing zeros dropped: `1234.5` is `1,234.5`.
String nebaFormatNumber(num value, {int maxFractionDigits = 3}) {
  if (value.isNaN) {
    return 'NaN';
  }

  if (value.isInfinite) {
    return value.isNegative ? '-∞' : '∞';
  }

  final String fixed = value.abs().toStringAsFixed(maxFractionDigits);
  final int point = fixed.indexOf('.');
  final String whole = point < 0 ? fixed : fixed.substring(0, point);
  String fraction = point < 0 ? '' : fixed.substring(point + 1);

  while (fraction.endsWith('0')) {
    fraction = fraction.substring(0, fraction.length - 1);
  }

  final StringBuffer grouped = StringBuffer();

  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      grouped.write(',');
    }

    grouped.write(whole[i]);
  }

  final bool zero = whole == '0' && fraction.isEmpty;
  final String sign = value < 0 && !zero ? '-' : '';

  return fraction.isEmpty ? '$sign$grouped' : '$sign$grouped.$fraction';
}

/// [ratio] as a percentage with at most [maxFractionDigits] digits after the
/// point: `0.1386` is `13.9%`.
String nebaFormatPercent(num ratio, {int maxFractionDigits = 0}) {
  return '${nebaFormatNumber(ratio * 100, maxFractionDigits: maxFractionDigits)}%';
}
