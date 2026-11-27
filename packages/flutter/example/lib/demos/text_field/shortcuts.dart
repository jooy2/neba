import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TextFieldShortcuts extends StatefulWidget {
  const TextFieldShortcuts({super.key});

  @override
  State<TextFieldShortcuts> createState() => _TextFieldShortcutsState();
}

class _TextFieldShortcutsState extends State<TextFieldShortcuts> {
  final TextEditingController _draft = TextEditingController();
  final List<String> _sent = <String>[];

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _send() {
    final String message = _draft.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() => _sent.add(message));
    _draft.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Command on an Apple keyboard, Control everywhere else.
    final bool apple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          NebaTextField(
            controller: _draft,
            label: const Text('Message'),
            placeholder: 'Write something',
            multiline: true,
            rows: 2,
            fullWidth: true,
            shortcuts: <ShortcutActivator, VoidCallback>{
              SingleActivator(LogicalKeyboardKey.enter, meta: apple, control: !apple): _send,
              const SingleActivator(LogicalKeyboardKey.escape): _draft.clear,
            },
            description: Text('${apple ? 'Cmd' : 'Ctrl'}+Enter to send, Esc to clear'),
          ),
          if (_sent.isEmpty)
            NebaTypography(
              'Nothing sent yet.',
              level: NebaTypographyLevel.caption,
              style: TextStyle(color: tokens.mutedFg),
            )
          else
            NebaFlex(
              wrap: true,
              spacing: 1.5,
              children: <Widget>[
                for (final String message in _sent)
                  NebaChip(size: NebaSize.sm, child: Text(message)),
              ],
            ),
        ],
      ),
    );
  }
}
