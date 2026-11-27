import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PromptInputSubmitKey extends StatelessWidget {
  const PromptInputSubmitKey({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          NebaPromptInput(
            label: Text('Enter sends'),
            placeholder: 'Enter sends, Shift+Enter breaks the line',
            end: <Widget>[NebaShortcut(size: NebaSize.xs, keys: 'Enter')],
          ),
          NebaPromptInput(
            label: Text('Mod+Enter sends'),
            submitKey: NebaPromptSubmitKey.modEnter,
            placeholder: 'Enter breaks the line, Mod+Enter sends',
            end: <Widget>[NebaShortcut(size: NebaSize.xs, keys: 'Mod+Enter')],
          ),
        ],
      ),
    );
  }
}
