import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class TextLinkSizes extends StatelessWidget {
  const TextLinkSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaTextLink(
            onPressed: _open,
            size: size,
            color: NebaColor.primary,
            child: Text(size.name),
          ),
      ],
    );
  }
}
