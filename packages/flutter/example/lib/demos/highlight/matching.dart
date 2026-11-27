import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HighlightMatching extends StatelessWidget {
  const HighlightMatching({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 13, height: 1.6),
        child: NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 4,
          children: <Widget>[
            // Several terms at once. The longest is tried first, so `database`
            // wins over `data` rather than leaving `base` outside the mark.
            const NebaHighlight.terms(
              query: <String>['data', 'database'],
              child: Text('One data row in one database, and the data it holds.'),
            ),
            // Case, which is off by default.
            const NebaHighlight(
              query: 'fox',
              caseSensitive: true,
              color: NebaColor.primary,
              child: Text('Fox, FOX and fox are three different words to a case-sensitive search.'),
            ),
            // Whole words, which is what stops `cat` marking `concatenate`.
            const NebaHighlight(
              query: 'cat',
              wholeWord: true,
              color: NebaColor.success,
              child: Text('A cat that concatenates is still a cat.'),
            ),
            // A regular expression, used as written.
            NebaHighlight.pattern(
              query: RegExp(r'\b[A-Z]{2,}\b'),
              color: NebaColor.danger,
              child: const Text('HTTP and TLS are acronyms; Http and Tls are not.'),
            ),
          ],
        ),
      ),
    );
  }
}
