import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CollapsibleHero extends StatelessWidget {
  const CollapsibleHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaCollapsible(
        title: Text('Shipping and returns'),
        subtitle: Text('Before you order'),
        child: NebaTypography(
          'Orders placed before 2pm ship the same day. Returns are free for thirty days and '
          'the label is already in the box.',
        ),
      ),
    );
  }
}
