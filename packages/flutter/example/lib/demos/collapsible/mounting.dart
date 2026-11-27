import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CollapsibleMounting extends StatelessWidget {
  const CollapsibleMounting({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaCollapsible(
        title: Text('Delivery note'),
        keepMounted: true,
        child: NebaTextField(
          size: NebaSize.sm,
          label: Text('Leave it with'),
          placeholder: 'A neighbour, the porter…',
          fullWidth: true,
        ),
      ),
    );
  }
}
