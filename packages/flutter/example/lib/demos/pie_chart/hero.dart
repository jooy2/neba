import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PieChartHero extends StatelessWidget {
  const PieChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Traffic by source'),
      subtitle: Text('Sessions this month'),
      child: NebaPieChart(
        label: 'Sessions by traffic source',
        shape: NebaPieShape.donut,
        categories: <Object>['Organic', 'Direct', 'Paid', 'Referral', 'Social'],
        data: <num>[18420, 9260, 6140, 3080, 1690],
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NebaTypography('Sessions', level: NebaTypographyLevel.overline),
            NebaTypography('38.6K', level: NebaTypographyLevel.h4),
          ],
        ),
      ),
    );
  }
}
