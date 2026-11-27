import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TextFieldVariants extends StatelessWidget {
  const TextFieldVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          for (final NebaVariant variant in NebaVariant.values)
            NebaGrid(
              span: third,
              child: NebaTextField(
                variant: variant,
                label: Text(variant.name),
                placeholder: 'Type here',
                fullWidth: true,
              ),
            ),
        ],
      ),
    );
  }
}
