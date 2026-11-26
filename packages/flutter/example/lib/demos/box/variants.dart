import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BoxVariants extends StatelessWidget {
  const BoxVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          Expanded(
            child: NebaBox(variant: variant, child: Text(variant.name)),
          ),
      ],
    );
  }
}
