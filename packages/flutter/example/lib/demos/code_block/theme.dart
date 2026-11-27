import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''/* a queue that never grows past its bound */
export class Ring<T> {
  #items: (T | undefined)[];

  constructor(readonly size = 16) {
    this.#items = new Array(size);
  }

  push(item: T): boolean {
    const at = this.#count % this.size;
    this.#items[at] = item;
    return ++this.#count <= this.size;
  }
}''';

class CodeBlockTheme extends StatefulWidget {
  const CodeBlockTheme({super.key});

  @override
  State<CodeBlockTheme> createState() => _CodeBlockThemeState();
}

class _CodeBlockThemeState extends State<CodeBlockTheme> {
  NebaCodeTheme _theme = NebaCodeTheme.dracula;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaSelect<NebaCodeTheme>(
            size: NebaSize.sm,
            label: const Text('Theme'),
            items: <NebaSelectOption<NebaCodeTheme>>[
              for (final NebaCodeTheme theme in NebaCodeTheme.values)
                NebaSelectOption<NebaCodeTheme>(value: theme, label: Text(theme.name)),
            ],
            value: _theme,
            onValueChange: (NebaCodeTheme? next) => setState(() => _theme = next ?? _theme),
          ),
        ),
        NebaCodeBlock(code: _source, language: 'ts', theme: _theme, title: Text(_theme.name)),
      ],
    );
  }
}
