import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OverlayHero extends StatefulWidget {
  const OverlayHero({super.key});

  @override
  State<OverlayHero> createState() => _OverlayHeroState();
}

class _OverlayHeroState extends State<OverlayHero> {
  bool _open = false;
  Timer? _timer;

  void _run() {
    setState(() => _open = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2200), () => setState(() => _open = false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        NebaButton(onPressed: _run, child: const Text('Publish')),
        NebaOverlay(
          open: _open,
          tone: NebaOverlayTone.blur,
          label: 'Publishing',
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              NebaProgressCircular(size: NebaSize.lg),
              Text('Publishing your site…', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
