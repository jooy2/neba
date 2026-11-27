import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _stages = <Object>[
  'Signed up',
  'Email verified',
  'Team invited',
  'Repo connected',
  'PR opened',
  'PR merged',
  'Deployed',
];

const List<NebaChartSeries> _cohorts = <NebaChartSeries>[
  NebaChartSeries(name: 'Week 1', data: <num>[980, 830, 520, 430, 290, 210, 120]),
  NebaChartSeries(name: 'Week 2', data: <num>[1040, 910, 610, 520, 360, 270, 180]),
  NebaChartSeries(name: 'Week 3', data: <num>[880, 760, 480, 400, 250, 190, 110]),
  NebaChartSeries(name: 'Week 4', data: <num>[1210, 1080, 740, 640, 470, 360, 250]),
];

class HeatmapChartAxes extends StatelessWidget {
  const HeatmapChartAxes({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Onboarding by cohort'),
      subtitle: Text('Accounts reaching each stage'),
      child: NebaHeatmapChart(
        label: 'Accounts reaching each onboarding stage, by cohort',
        categories: _stages,
        series: _cohorts,
        xAxis: NebaChartAxis(label: 'Stage', tickAngle: -45),
        yAxis: NebaChartAxis(label: 'Cohort'),
      ),
    );
  }
}
