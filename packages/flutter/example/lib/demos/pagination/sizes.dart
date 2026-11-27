import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PaginationSizes extends StatelessWidget {
  const PaginationSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: NebaPagination(size: size, count: 9, defaultPage: 4),
          ),
      ],
    );
  }
}
