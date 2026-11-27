import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class NumberFieldVariants extends StatelessWidget {
  const NumberFieldVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaNumberField(variant: NebaVariant.solid, label: Text('Solid'), defaultValue: 12),
        NebaNumberField(variant: NebaVariant.outline, label: Text('Outline'), defaultValue: 12),
        NebaNumberField(variant: NebaVariant.text, label: Text('Text'), defaultValue: 12),
      ],
    );
  }
}
