import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''.neba-code-line[data-prompt]::after {
  content: attr(data-prompt);
  user-select: none;
}''';

class CodeBlockTypography extends StatelessWidget {
  const CodeBlockTypography({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        NebaCodeBlock(
          code: _source,
          language: 'css',
          size: NebaSize.sm,
          title: Text('size: NebaSize.sm'),
        ),
        NebaCodeBlock(
          code: _source,
          language: 'css',
          title: Text('letterSpacing · lineHeight'),
          fontSize: 15,
          lineHeight: 2,
          letterSpacing: 0.6,
        ),
      ],
    );
  }
}
