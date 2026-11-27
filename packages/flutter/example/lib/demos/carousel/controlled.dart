import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _steps = <String>[
  'Connect a repository',
  'Pick a branch',
  'Choose a region',
  'Deploy',
];

/// `value` and `onValueChange` are the usual controlled pair, so a carousel
/// can be driven by something else on the page: here, a wizard's own step
/// buttons.
class CarouselControlled extends StatefulWidget {
  const CarouselControlled({super.key});

  @override
  State<CarouselControlled> createState() => _CarouselControlledState();
}

class _CarouselControlledState extends State<CarouselControlled> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaCarousel(
          semanticLabel: 'Setup steps',
          value: _step,
          onValueChange: (int step) => setState(() => _step = step),
          arrows: false,
          indicators: false,
          loop: false,
          children: <Widget>[
            for (int i = 0; i < _steps.length; i++)
              Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: NebaFlex(
                      direction: NebaOrientation.vertical,
                      spacing: 1,
                      justifyContent: NebaJustifyContent.center,
                      children: <Widget>[
                        NebaTypography(
                          'Step ${i + 1} of ${_steps.length}',
                          level: NebaTypographyLevel.overline,
                        ),
                        NebaTypography(_steps[i], level: NebaTypographyLevel.h4),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaButtonGroup(
            variant: NebaVariant.outline,
            size: NebaSize.sm,
            color: NebaColor.secondary,
            children: <Widget>[
              NebaButton(
                onPressed: _step == 0 ? null : () => setState(() => _step--),
                child: const Text('Back'),
              ),
              NebaButton(
                onPressed: _step == _steps.length - 1 ? null : () => setState(() => _step++),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
