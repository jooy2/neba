import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _categories = <Object>['Free', 'Pro', 'Team', 'Enterprise'];
const List<num> _data = <num>[4820, 2140, 890, 210];

class PieChartRing extends StatelessWidget {
  const PieChartRing({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: third,
          child: const NebaCard(
            title: Text('hole: 0.38'),
            subtitle: Text('A thicker ring'),
            size: NebaSize.sm,
            child: NebaPieChart(
              label: 'Accounts by plan, thick ring',
              size: NebaSize.sm,
              height: 160,
              shape: NebaPieShape.donut,
              hole: 0.38,
              categories: _categories,
              data: _data,
              center: NebaTypography('8,060', level: NebaTypographyLevel.h5),
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaCard(
            title: Text('gap: 6'),
            subtitle: Text('Slices parted further'),
            size: NebaSize.sm,
            child: NebaPieChart(
              label: 'Accounts by plan, wide gap',
              size: NebaSize.sm,
              height: 160,
              shape: NebaPieShape.donut,
              gap: 6,
              categories: _categories,
              data: _data,
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaCard(
            title: Text('gap: 0'),
            subtitle: Text('Slices meeting'),
            size: NebaSize.sm,
            child: NebaPieChart(
              label: 'Accounts by plan, no gap',
              size: NebaSize.sm,
              height: 160,
              gap: 0,
              categories: _categories,
              data: _data,
            ),
          ),
        ),
      ],
    );
  }
}
