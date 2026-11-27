import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 2,
        children: <Widget>[
          const NebaImage(
            image: AssetImage('assets/samples/photos/vintage-camera-maple-leaves.jpg'),
            alt: 'An old rangefinder camera among fallen maple leaves, enlarged on a press',
            ratio: 1,
            rounded: NebaSize.lg,
            preview: true,
          ),
          Text(
            'Press it, or reach it with Tab and press Enter.',
            style: TextStyle(fontSize: 14, color: tokens.mutedFg),
          ),
        ],
      ),
    );
  }
}
