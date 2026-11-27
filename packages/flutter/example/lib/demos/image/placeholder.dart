import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImagePlaceholder extends StatefulWidget {
  const ImagePlaceholder({super.key});

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        alignItems: NebaAlignItems.start,
        spacing: 3,
        children: <Widget>[
          // Until there is an image the picture is still arriving, so the
          // 24-pixel copy stands in for it, blurred.
          NebaImage(
            image: _requested
                ? const AssetImage('assets/samples/photos/misty-tea-terraces-sunrise.jpg')
                : null,
            alt: 'Terraced tea fields under morning mist',
            width: 560,
            height: 373,
            rounded: NebaSize.md,
            placeholder: const NebaImagePlaceholder.image(
              AssetImage('assets/samples/photos/misty-tea-terraces-sunrise-tiny.jpg'),
              blur: 20,
            ),
          ),
          NebaButton(
            variant: NebaVariant.outline,
            size: NebaSize.sm,
            onPressed: () => setState(() => _requested = !_requested),
            child: Text(_requested ? 'Reset' : 'Load the picture'),
          ),
        ],
      ),
    );
  }
}
