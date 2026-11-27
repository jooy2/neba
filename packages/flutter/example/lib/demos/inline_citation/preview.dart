import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// [citation] set into the line.
WidgetSpan _inline(Widget citation) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(padding: const EdgeInsetsDirectional.only(start: 2), child: citation),
  );
}

class InlineCitationPreview extends StatelessWidget {
  const InlineCitationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 15, height: 1.6),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'With a preview'),
              _inline(
                NebaInlineCitation(
                  index: 1,
                  title: const Text('The design language'),
                  site: const Text('neba.cdget.com'),
                  href: Uri.parse('https://neba.cdget.com/design/design-language'),
                  onPressed: () {},
                  description: const Text('Rest the pointer here and the source comes up.'),
                ),
              ),
              const TextSpan(text: ', without one'),
              _inline(
                NebaInlineCitation(
                  index: 2,
                  href: Uri.parse('https://neba.cdget.com/design/breakpoints'),
                  onPressed: () {},
                  preview: false,
                ),
              ),
              const TextSpan(text: ', and with nothing to point at at all'),
              _inline(const NebaInlineCitation(index: 3)),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }
}
