import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToolCallVariant extends StatelessWidget {
  const ToolCallVariant({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final NebaVariant variant in <NebaVariant>[
            NebaVariant.outline,
            NebaVariant.solid,
            NebaVariant.text,
          ])
            NebaToolCall(
              variant: variant,
              name: const Text('fetch_page'),
              status: NebaRunStatus.success,
              duration: const Duration(milliseconds: 730),
              meta: Text(variant.name),
              result: const Text('200 OK'),
            ),
        ],
      ),
    );
  }
}
