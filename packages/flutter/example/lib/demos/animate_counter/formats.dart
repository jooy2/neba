import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Dollars with their thousands grouped and no cents: `$48,250`.
String _dollars(num value) {
  final String digits = value.round().abs().toString();
  final StringBuffer grouped = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      grouped.write(',');
    }

    grouped.write(digits[index]);
  }

  return '${value < 0 ? '-' : ''}\$$grouped';
}

/// A share as a percentage with at most one digit after the point: `18.4%`.
String _percent(num value) {
  return '${(value * 100).toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '')}%';
}

class AnimateCounterFormats extends StatefulWidget {
  const AnimateCounterFormats({super.key});

  @override
  State<AnimateCounterFormats> createState() => _AnimateCounterFormatsState();
}

class _AnimateCounterFormatsState extends State<AnimateCounterFormats> {
  int _run = 1;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaButton(
            onPressed: () => setState(() => _run += 1),
            variant: NebaVariant.outline,
            size: NebaSize.sm,
            child: const Text('Count again'),
          ),
        ),
        NebaGridContainer(
          spacing: 3,
          padded: false,
          children: <Widget>[
            NebaGrid(
              span: third,
              child: NebaStatistic(
                label: const Text('Revenue'),
                value: NebaAnimateCounter(
                  trigger: NebaAnimateTrigger.manual,
                  play: _run,
                  value: 48250,
                  format: _dollars,
                ),
              ),
            ),
            NebaGrid(
              span: third,
              child: NebaStatistic(
                label: const Text('Conversion'),
                value: NebaAnimateCounter(
                  trigger: NebaAnimateTrigger.manual,
                  play: _run,
                  value: 0.184,
                  format: _percent,
                ),
              ),
            ),
            NebaGrid(
              span: third,
              child: NebaStatistic(
                label: const Text('Tickets closed'),
                value: NebaAnimateCounter(
                  trigger: NebaAnimateTrigger.manual,
                  play: _run,
                  value: 1943,
                  duration: const Duration(milliseconds: 2000),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
