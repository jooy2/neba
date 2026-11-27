import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class StreamingTextReserve extends StatefulWidget {
  const StreamingTextReserve({super.key});

  @override
  State<StreamingTextReserve> createState() => _StreamingTextReserveState();
}

class _StreamingTextReserveState extends State<StreamingTextReserve> {
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.border),
              borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
            ),
            child: NebaStreamingText(streaming: _text.isEmpty, lines: 3, child: Text(_text)),
          ),
          Text(
            'The box is three lines tall before the first word lands, and stays three lines tall '
            'once it has. What comes after it never moves.',
            style: TextStyle(fontSize: 13, color: tokens.mutedFg),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NebaButton(
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              onPressed: () => setState(() => _text = _text.isEmpty ? 'One line.' : ''),
              child: Text(_text.isEmpty ? 'Let the first word land' : 'Empty it again'),
            ),
          ),
        ],
      ),
    );
  }
}
