import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The window slides toward whichever end it is near rather than being
/// clipped by it, so the row keeps the same number of slots on every page:
/// otherwise stepping from page 1 to page 2 would move every button out from
/// under the pointer that just pressed one.
class PaginationRange extends StatelessWidget {
  const PaginationRange({super.key});

  @override
  Widget build(BuildContext context) {
    Widget labelled(String label, Widget pagination) {
      return NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 1,
        children: <Widget>[
          NebaTypography(label, level: NebaTypographyLevel.caption),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: pagination),
        ],
      );
    }

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        for (final int page in <int>[1, 2, 10, 19, 20])
          labelled('page: $page', NebaPagination(count: 20, page: page, showArrows: false)),
        labelled(
          'siblingCount: 2 · boundaryCount: 2',
          const NebaPagination(
            count: 20,
            page: 10,
            siblingCount: 2,
            boundaryCount: 2,
            showArrows: false,
          ),
        ),
      ],
    );
  }
}
