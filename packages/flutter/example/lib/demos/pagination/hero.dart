import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PaginationHero extends StatefulWidget {
  const PaginationHero({super.key});

  @override
  State<PaginationHero> createState() => _PaginationHeroState();
}

class _PaginationHeroState extends State<PaginationHero> {
  int _page = 7;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        // A row wider than a phone scrolls sideways there.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: NebaPagination(
            count: 24,
            page: _page,
            onPageChange: (int page) => setState(() => _page = page),
            showEdges: true,
          ),
        ),
        const NebaTypography('Showing 121–140 of 480', level: NebaTypographyLevel.caption),
      ],
    );
  }
}
