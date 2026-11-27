// A chart lays its labels out in text painters of its own, and every one of
// them is disposed: the set a new trace or a new build replaces, after the
// frame that stops painting it, and the last one with the chart.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../support/host.dart';

const List<String> _months = <String>['Jan', 'Feb', 'Mar', 'Apr'];

/// Every chart that lays text out on its canvas, with its labels on and the
/// data at [step], so a different step traces it again.
List<Widget> _charts(int step) {
  final List<num> data = <num>[10 + step, 20, 30, 40];
  final List<NebaChartSeries> series = <NebaChartSeries>[NebaChartSeries(name: 'Web', data: data)];

  return <Widget>[
    NebaBarChart(categories: _months, series: series, valueLabels: NebaChartValueLabels.all),
    NebaLineChart(categories: _months, series: series, valueLabels: NebaChartValueLabels.all),
    NebaAreaChart(categories: _months, series: series, valueLabels: NebaChartValueLabels.all),
    NebaPieChart(categories: _months, data: data, valueLabels: NebaChartValueLabels.all),
    NebaGaugeChart(value: 40.0 + step, max: 100.0 + step, label: 'CPU'),
  ];
}

void main() {
  testWidgets('disposes every text painter a chart lays out, once it stops painting it', (
    WidgetTester tester,
  ) async {
    final Set<Object> live = Set<Object>.identity();

    void track(ObjectEvent event) {
      if (event is ObjectCreated && event.className == 'TextPainter') {
        live.add(event.object);
      } else if (event is ObjectDisposed) {
        live.remove(event.object);
      }
    }

    FlutterMemoryAllocations.instance.addListener(track);
    addTearDown(() => FlutterMemoryAllocations.instance.removeListener(track));

    for (final int step in <int>[0, 1, 2]) {
      await tester.pumpWidget(
        host(SingleChildScrollView(child: Column(children: _charts(step))), height: 2400),
      );
      await tester.pump();
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(live, isEmpty);
  });
}
