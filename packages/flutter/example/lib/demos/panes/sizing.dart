import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PanesSizing extends StatefulWidget {
  const PanesSizing({super.key});

  @override
  State<PanesSizing> createState() => _PanesSizingState();
}

class _PanesSizingState extends State<PanesSizing> {
  List<double> _sizes = const <double>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        SizedBox(
          height: 160,
          child: NebaPanes(
            onResize: (List<double> sizes) => setState(() => _sizes = sizes),
            children: const <NebaPane>[
              NebaPane(
                defaultSize: NebaPaneSize.pixels(180),
                minSize: NebaPaneSize.pixels(120),
                maxSize: NebaPaneSize.percent(50),
                child: _Label('180px to start, never under 120'),
              ),
              NebaPane(minSize: NebaPaneSize.percent(20), child: _Label('at least a fifth')),
            ],
          ),
        ),
        NebaTypography(
          _sizes.isEmpty
              ? 'Drag the bar.'
              : _sizes.map((double size) => '${size.round()}%').join(' · '),
          level: NebaTypographyLevel.caption,
          color: NebaColor.secondary,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: NebaTypography(text, color: NebaColor.secondary),
    );
  }
}
