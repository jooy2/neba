import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const AssetImage _rowboat = AssetImage('assets/samples/photos/rowboat-misty-pond-sunrise.jpg');

class ImageWatermark extends StatelessWidget {
  const ImageWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 6 : 12),
            child: const NebaImage(
              image: _rowboat,
              alt: 'A rowboat moored on a misty pond',
              ratio: 3 / 2,
              rounded: NebaSize.md,
              watermark: NebaImageWatermark('© Neba'),
            ),
          ),
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 6 : 12),
            child: const NebaImage(
              image: _rowboat,
              alt: 'A rowboat moored on a misty pond, marked as a proof',
              ratio: 3 / 2,
              rounded: NebaSize.md,
              watermark: NebaImageWatermark('PROOF · DO NOT COPY', repeat: true, opacity: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}
