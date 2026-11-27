import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageProtect extends StatelessWidget {
  const ImageProtect({super.key});

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
            image: AssetImage('assets/samples/photos/lighthouse-cliff-wildflowers.jpg'),
            alt: 'A print of a lighthouse, offered without the browser menu',
            ratio: 4 / 5,
            rounded: NebaSize.lg,
            protect: true,
            watermark: NebaImageWatermark(
              'proof',
              position: AlignmentDirectional.topStart,
              size: NebaSize.sm,
              color: Color(0xFF2F4A3C),
            ),
          ),
          Text(
            'In a browser, try to right-click it.',
            style: TextStyle(fontSize: 14, color: tokens.mutedFg),
          ),
        ],
      ),
    );
  }
}
