import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _rows = <String>['Design', 'Engineering', 'Research', 'Support', 'Finance'];

class AnimateFadeStagger extends StatefulWidget {
  const AnimateFadeStagger({super.key});

  @override
  State<AnimateFadeStagger> createState() => _AnimateFadeStaggerState();
}

class _AnimateFadeStaggerState extends State<AnimateFadeStagger> {
  int _run = 0;

  static Widget _column(List<Widget> children) {
    return NebaFlex(direction: NebaOrientation.vertical, spacing: 2, children: children);
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaButton(
            onPressed: () => setState(() => _run += 1),
            variant: NebaVariant.outline,
            size: NebaSize.sm,
            child: const Text('Play again'),
          ),
          NebaGridContainer(
            key: ValueKey<int>(_run),
            spacing: 6,
            padded: false,
            alignItems: NebaAlignItems.start,
            children: <Widget>[
              NebaGrid(
                span: half,
                child: NebaFlex(
                  direction: NebaOrientation.vertical,
                  spacing: 2,
                  children: <Widget>[
                    const NebaTypography(
                      'stagger: 60 ms',
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                    NebaAnimateFade(
                      stagger: const Duration(milliseconds: 60),
                      layoutBuilder: _column,
                      children: <Widget>[
                        for (final String row in _rows)
                          NebaBox(
                            key: ValueKey<String>(row),
                            size: NebaSize.sm,
                            variant: NebaVariant.outline,
                            child: Text(row),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              NebaGrid(
                span: half,
                child: NebaFlex(
                  direction: NebaOrientation.vertical,
                  spacing: 2,
                  children: <Widget>[
                    const NebaTypography(
                      'stagger: 60 ms · durationStep: 120 ms · reverse',
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                    NebaAnimateFade(
                      stagger: const Duration(milliseconds: 60),
                      durationStep: const Duration(milliseconds: 120),
                      reverse: true,
                      layoutBuilder: _column,
                      children: <Widget>[
                        for (final String row in _rows)
                          NebaBox(
                            key: ValueKey<String>(row),
                            size: NebaSize.sm,
                            variant: NebaVariant.outline,
                            color: NebaColor.secondary,
                            child: Text(row),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
