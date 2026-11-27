import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<num> _data = <num>[32, 28, 41, 39, 52, 47, 61, 58, 72, 68, 81, 94];

class SparklineVariants extends StatelessWidget {
  const SparklineVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        for (final NebaSparklineShape shape in NebaSparklineShape.values)
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 4 : 12),
            child: _Labelled(
              label: 'shape="${shape.name}"',
              child: NebaSparkline(
                data: _data,
                shape: shape,
                size: NebaSize.lg,
                label: 'Example, ${shape.name}',
              ),
            ),
          ),
        NebaGrid(
          span: NebaGridSpan.columns(wide ? 6 : 12),
          child: const _Labelled(
            label: 'curve="smooth" · endDot',
            child: NebaSparkline(
              data: _data,
              curve: NebaChartCurve.smooth,
              size: NebaSize.lg,
              endDot: true,
              label: 'Example, smoothed',
            ),
          ),
        ),
        NebaGrid(
          span: NebaGridSpan.columns(wide ? 6 : 12),
          child: const _Labelled(
            label: 'baseline={60}',
            child: NebaSparkline(
              data: _data,
              shape: NebaSparklineShape.area,
              size: NebaSize.lg,
              baseline: 60,
              color: NebaColor.success,
              label: 'Example against a target of 60',
            ),
          ),
        ),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      children: <Widget>[
        NebaTypography(label, level: NebaTypographyLevel.overline),
        child,
      ],
    );
  }
}
