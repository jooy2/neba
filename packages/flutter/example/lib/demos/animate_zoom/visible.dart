import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateZoomVisible extends StatelessWidget {
  const AnimateZoomVisible({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: SizedBox(
        height: 224,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 160,
                child: Center(
                  child: Text('Scroll down', style: TextStyle(fontSize: 14, color: tokens.mutedFg)),
                ),
              ),
              const NebaAnimateZoom(
                trigger: NebaAnimateTrigger.visible,
                threshold: 0.6,
                duration: Duration(milliseconds: 600),
                child: NebaCard(
                  size: NebaSize.sm,
                  title: Text('Here it is'),
                  child: Text(
                    'It ran when six tenths of it was on screen, and only the first time.',
                  ),
                ),
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}
