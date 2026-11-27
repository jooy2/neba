import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A number as a compact English figure, `128K`: Intl's `notation: 'compact'`,
/// which the widgets layer does not have.
String _compact(num value) {
  const List<String> units = <String>['', 'K', 'M', 'B'];
  double scaled = value.toDouble();
  int unit = 0;

  while (scaled.abs() >= 1000 && unit < units.length - 1) {
    scaled /= 1000;
    unit += 1;
  }

  // Two significant figures below a hundred, whole numbers above.
  final String figure = scaled.abs() >= 100 || unit == 0
      ? scaled.round().toString()
      : scaled.toStringAsFixed(scaled.abs() >= 10 ? 0 : 1).replaceFirst(RegExp(r'\.0$'), '');

  return '$figure${units[unit]}';
}

class AnimateCounterHero extends StatelessWidget {
  const AnimateCounterHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaStatistic(
      label: Text('Monthly active'),
      value: NebaAnimateCounter(value: 128400, format: _compact),
    );
  }
}
