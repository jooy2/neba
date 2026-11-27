import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const Text _sentence = Text('A sheet of cut acrylic, not a moulded plastic key.');

class HighlightVariants extends StatelessWidget {
  const HighlightVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 13, height: 1.6),
        child: const NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 3,
          children: <Widget>[
            NebaHighlight(query: 'acrylic', child: _sentence),
            NebaHighlight(
              query: 'acrylic',
              variant: NebaVariant.outline,
              color: NebaColor.primary,
              child: _sentence,
            ),
            NebaHighlight(
              query: 'acrylic',
              variant: NebaVariant.text,
              color: NebaColor.danger,
              child: _sentence,
            ),
            NebaHighlight(
              query: 'acrylic',
              variant: NebaVariant.text,
              color: NebaColor.primary,
              underline: true,
              child: _sentence,
            ),
            NebaHighlight(
              query: 'acrylic',
              variant: NebaVariant.text,
              color: NebaColor.success,
              weight: FontWeight.w700,
              child: _sentence,
            ),
          ],
        ),
      ),
    );
  }
}
