import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The text is walked into rather than required to be one string, which is
/// what makes a highlight survive the first search result with styling in it.
class HighlightNested extends StatelessWidget {
  const HighlightNested({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle strong = TextStyle(fontWeight: FontWeight.w700);
    const TextStyle em = TextStyle(fontStyle: FontStyle.italic);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaHighlight(
        query: 'surface',
        color: NebaColor.primary,
        child: NebaTypography.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: 'A '),
              TextSpan(text: 'surface', style: strong),
              TextSpan(text: ' is a sheet, and a '),
              TextSpan(text: 'surface', style: em),
              TextSpan(text: ' that moves is a key. The '),
              TextSpan(text: 'surface', style: strong),
              TextSpan(text: ' keeps its edge either way.'),
            ],
          ),
        ),
      ),
    );
  }
}
