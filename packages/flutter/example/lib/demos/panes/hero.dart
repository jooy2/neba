import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PanesHero extends StatelessWidget {
  const PanesHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 288,
      child: NebaPanes(
        children: <NebaPane>[
          NebaPane(
            defaultSize: NebaPaneSize.pixels(200),
            minSize: NebaPaneSize.pixels(140),
            maxSize: NebaPaneSize.percent(45),
            child: _Region(title: 'Files', note: 'Drag the bar to resize.'),
          ),
          NebaPane(
            child: NebaPanes(
              orientation: NebaOrientation.vertical,
              children: <NebaPane>[
                NebaPane(
                  defaultSize: NebaPaneSize.percent(70),
                  minSize: NebaPaneSize.pixels(80),
                  child: _Region(title: 'Editor', note: 'A split inside a split.'),
                ),
                NebaPane(
                  minSize: NebaPaneSize.pixels(60),
                  child: _Region(title: 'Terminal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A heading and a line under it, in a pane's padding.
class _Region extends StatelessWidget {
  const _Region({required this.title, this.note});

  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final String? note = this.note;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NebaTypography(title, level: NebaTypographyLevel.h6),
          if (note != null) NebaTypography(note, color: NebaColor.secondary),
        ],
      ),
    );
  }
}
