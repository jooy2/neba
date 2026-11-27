import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PromptInputRows extends StatelessWidget {
  const PromptInputRows({super.key});

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
            label: Text('One line to start'),
            placeholder: 'Type, and watch it grow',
            maxRows: 4,
          ),
          NebaPromptInput(
            label: Text('Three lines to start'),
            minRows: 3,
            maxRows: 6,
            initialValue:
                'It starts three rows tall\nand stops growing at six,\nafter which it scrolls.',
          ),
        ],
      ),
    );
  }
}
