import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _categories = <Object>[
  'Documentation',
  'Onboarding flow',
  'Billing portal',
  'Search relevance',
  'Mobile parity',
];
const List<NebaChartSeries> _votes = <NebaChartSeries>[
  NebaChartSeries(name: 'Votes', data: <num>[412, 388, 301, 264, 190]),
];

/// `horizontal` is the right answer whenever the category names are words. A
/// vertical chart gives each name the width of one bar; a horizontal one gives
/// it a whole column.
class BarChartOrientation extends StatelessWidget {
  const BarChartOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaCard(
            title: Text('orientation="vertical"'),
            size: NebaSize.sm,
            child: NebaBarChart(
              label: 'Feature votes, vertical',
              size: NebaSize.sm,
              height: 200,
              categories: _categories,
              series: _votes,
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaCard(
            title: Text('orientation="horizontal"'),
            size: NebaSize.sm,
            child: NebaBarChart(
              label: 'Feature votes, horizontal',
              size: NebaSize.sm,
              height: 200,
              orientation: NebaOrientation.horizontal,
              categories: _categories,
              series: _votes,
              valueLabels: NebaChartValueLabels.all,
            ),
          ),
        ),
      ],
    );
  }
}
