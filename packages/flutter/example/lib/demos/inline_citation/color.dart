import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaColor> _colors = <NebaColor>[
  NebaColor.primary,
  NebaColor.secondary,
  NebaColor.success,
  NebaColor.info,
];

class InlineCitationColor extends StatelessWidget {
  const InlineCitationColor({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 15, height: 1.6),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(
                text:
                    'The mark follows the type around it, so it tracks whatever sentence it '
                    'interrupts',
              ),
              for (int at = 0; at < _colors.length; at++)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 2),
                    child: NebaInlineCitation(
                      index: at + 1,
                      color: _colors[at],
                      title: Text(_colors[at].name),
                    ),
                  ),
                ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }
}
