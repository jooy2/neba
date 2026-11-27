import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _lines = <String>['\$ npm install neba', '\$ npm run dev', '  ready in 312 ms'];

class AnimateTypingTerminal extends StatelessWidget {
  const AnimateTypingTerminal({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaBox(
        variant: NebaVariant.solid,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontFamily: NebaScale.monoFonts.first,
            fontFamilyFallback: NebaScale.monoFonts.sublist(1),
            fontSize: 12,
          ),
          child: NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 1,
            alignItems: NebaAlignItems.stretch,
            children: <Widget>[
              for (int index = 0; index < _lines.length; index++)
                NebaAnimateTyping(
                  key: ValueKey<String>(_lines[index]),
                  text: _lines[index],
                  speed: 26,
                  delay: Duration(milliseconds: index * 900),
                  caret: index == _lines.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
