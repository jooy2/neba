import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AspectRatioReserving extends StatefulWidget {
  const AspectRatioReserving({super.key});

  @override
  State<AspectRatioReserving> createState() => _AspectRatioReservingState();
}

class _AspectRatioReservingState extends State<AspectRatioReserving> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          // The box is the same height either way, so the card does not jump
          // when the image arrives and nothing below it moves under the reader.
          NebaCard(
            title: const Text('Alpine lake, dawn'),
            subtitle: const Text('Uploaded 4 minutes ago'),
            child: NebaAspectRatio(
              ratio: 16 / 9,
              rounded: true,
              child: _loaded
                  ? Image.asset(
                      'assets/samples/photos/alpine-lake-dawn.jpg',
                      semanticLabel: 'A still alpine lake with the first light on the far ridge',
                    )
                  : const NebaSkeleton(
                      shape: NebaSkeletonShape.rect,
                      height: double.infinity,
                      semanticLabel: 'Loading the photograph',
                    ),
            ),
          ),
          NebaButton(
            onPressed: () => setState(() => _loaded = !_loaded),
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            child: Text(_loaded ? 'Unload the image' : 'Load the image'),
          ),
        ],
      ),
    );
  }
}
