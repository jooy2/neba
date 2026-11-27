import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Midnight today, so a span never carries the time the screen was built.
DateTime _today() {
  final DateTime now = DateTime.now();

  return DateTime(now.year, now.month, now.day);
}

NebaDateRange _daysBack(int count) {
  final DateTime end = _today();

  return NebaDateRange(start: DateTime(end.year, end.month, end.day - count + 1), end: end);
}

NebaDateRange _thisMonth() {
  final DateTime now = _today();

  return NebaDateRange(start: DateTime(now.year, now.month), end: now);
}

class DateRangePickerPresets extends StatelessWidget {
  const DateRangePickerPresets({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaDateRangePicker(
      label: const Text('Report period'),
      startPlaceholder: const Text('From'),
      endPlaceholder: const Text('To'),
      // Worked out when pressed, not when built: a span counted from today
      // is wrong for anyone who leaves the screen open overnight.
      presets: <NebaDateRangePreset>[
        NebaDateRangePreset.computed(label: const Text('Last 7 days'), value: () => _daysBack(7)),
        NebaDateRangePreset.computed(label: const Text('Last 30 days'), value: () => _daysBack(30)),
        const NebaDateRangePreset.computed(label: Text('This month'), value: _thisMonth),
      ],
    );
  }
}
