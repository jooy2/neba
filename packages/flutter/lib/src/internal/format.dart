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

const List<String> _compactUnits = <String>['', 'K', 'M', 'B', 'T'];

/// [value] as an axis writes a number when nobody said how: compacted from ten
/// thousand up, with one digit after the point (`12.4K`, `3.1M`), and with
/// its thousands grouped and at most two digits after the point below that.
/// The React package's `compactNumber`, which is `Intl.NumberFormat`'s
/// `notation: 'compact'` in English.
String nebaFormatCompact(num value) {
  if (!value.isFinite || value.abs() < 10000) {
    return nebaFormatNumber(value, maxFractionDigits: 2);
  }

  int unit = 0;
  double scaled = value.abs().toDouble();

  while (scaled >= 1000 && unit < _compactUnits.length - 1) {
    scaled /= 1000;
    unit += 1;
  }

  // Rounded before the unit is settled, so 999,960 is `1M` rather than
  // `1000K`, as the platform writes it.
  double rounded = (scaled * 10).roundToDouble() / 10;

  if (rounded >= 1000 && unit < _compactUnits.length - 1) {
    rounded = (rounded / 1000 * 10).roundToDouble() / 10;
    unit += 1;
  }

  final String digits = nebaFormatNumber(rounded, maxFractionDigits: 1);

  return '${value < 0 ? '-' : ''}$digits${_compactUnits[unit]}';
}

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// [date] as its month's short name and its day, `Jun 1`: how the React
/// package writes a date on a chart's axis in English when nobody said how.
String nebaFormatMonthDay(DateTime date) {
  return '${_months[date.month - 1]} ${date.day}';
}

/// [date] with its year, `Jun 1, 2026`: how the React package's
/// `Intl.DateTimeFormat` writes a date at `dateStyle: 'medium'` in English,
/// which is what a DataTable cell with nothing to draw it shows.
String nebaFormatDate(DateTime date) {
  return '${nebaFormatMonthDay(date)}, ${date.year}';
}
