import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _weeks = <Object>['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];

// Two weeks the collector was down. Not two weeks of zero.
const List<num?> _readings = <num?>[42, 47, null, null, 51, 58, 55, 62];

class LineChartGaps extends StatelessWidget {
  const LineChartGaps({super.key});

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
          child: const _Readings(
            title: 'nulls="gap"',
            subtitle: 'The default',
            label: 'Readings with a two-week gap',
            nulls: NebaChartNulls.gap,
          ),
        ),
        NebaGrid(
          span: third,
          child: const _Readings(
            title: 'nulls="connect"',
            subtitle: 'Only when the gap is an artefact',
            label: 'Readings, bridged',
            nulls: NebaChartNulls.connect,
          ),
        ),
        NebaGrid(
          span: third,
          child: const _Readings(
            title: 'nulls="zero"',
            subtitle: 'Only when nothing happened',
            label: 'Readings, read as zero',
            nulls: NebaChartNulls.zero,
          ),
        ),
      ],
    );
  }
}

class _Readings extends StatelessWidget {
  const _Readings({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.nulls,
  });

  final String title;
  final String subtitle;
  final String label;
  final NebaChartNulls nulls;

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: Text(title),
      subtitle: Text(subtitle),
      size: NebaSize.sm,
      child: NebaLineChart(
        label: label,
        size: NebaSize.sm,
        height: 160,
        categories: _weeks,
        series: const <NebaChartSeries>[NebaChartSeries(name: 'Readings', data: _readings)],
        markers: NebaChartMarkers.all,
        nulls: nulls,
      ),
    );
  }
}
