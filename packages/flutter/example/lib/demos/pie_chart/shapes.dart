import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _categories = <Object>['Free', 'Pro', 'Team', 'Enterprise'];
const List<num> _data = <num>[4820, 2140, 890, 210];

class PieChartShapes extends StatelessWidget {
  const PieChartShapes({super.key});

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
            title: Text('shape="pie"'),
            size: NebaSize.sm,
            child: NebaPieChart(
              label: 'Accounts by plan, pie',
              size: NebaSize.sm,
              height: 160,
              categories: _categories,
              data: _data,
              valueLabels: NebaChartValueLabels.all,
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaCard(
            title: Text('shape="donut"'),
            size: NebaSize.sm,
            child: NebaPieChart(
              label: 'Accounts by plan, donut',
              size: NebaSize.sm,
              height: 160,
              shape: NebaPieShape.donut,
              categories: _categories,
              data: _data,
              center: NebaTypography('8,060', level: NebaTypographyLevel.h5),
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaCard(
            title: Text('shape="semi"'),
            size: NebaSize.sm,
            child: NebaPieChart(
              label: 'Accounts by plan, semicircle',
              size: NebaSize.sm,
              height: 160,
              shape: NebaPieShape.semi,
              categories: _categories,
              data: _data,
            ),
          ),
        ),
      ],
    );
  }
}
