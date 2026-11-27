import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Five days this month have something on them.
const Set<int> _busy = <int>{4, 11, 12, 19, 26};

class CalendarMarks extends StatelessWidget {
  const CalendarMarks({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = NebaTheme.of(context).roles(NebaColor.primary).accent;

    return NebaCalendar(
      size: NebaSize.lg,
      renderDay: (DateTime date) => _busy.contains(date.day)
          ? Positioned(
              bottom: 4,
              child: ExcludeSemantics(
                child: SizedBox.square(
                  dimension: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
