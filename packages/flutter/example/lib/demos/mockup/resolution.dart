import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

import 'package:neba_example/demos/mockup/screen.dart';

/// Both mockups are drawn the same width on the page. What differs is the
/// screen behind that: 390 pixels on the left and 1440 on the right, which is
/// why the same three cards stack on one and sit in a row on the other.
class MockupResolution extends StatelessWidget {
  const MockupResolution({super.key});

  @override
  Widget build(BuildContext context) {
    return const MockupLabels(<(String, Widget)>[
      (
        '390 × 844',
        NebaMockup(
          device: NebaMockupDevice.mobile,
          bezel: NebaMockupBezel.thin,
          systemUi: false,
          notch: NebaMockupNotch.none,
          width: 230,
          child: _Cards(),
        ),
      ),
      (
        '1440 × 900',
        NebaMockup(
          device: NebaMockupDevice.desktop,
          bezel: NebaMockupBezel.thin,
          systemUi: false,
          width: 230,
          child: _Cards(),
        ),
      ),
    ]);
  }
}

/// A row once the screen is 600 pixels wide: the media query inside the
/// mockup is the screen's, so this answers to the device rather than the
/// window.
class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 600;
    final List<Widget> cards = <Widget>[
      for (final String label in const <String>['Requests', 'Error rate', 'Latency'])
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.roles(NebaColor.primary).soft,
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
          ),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[for (final Widget card in cards) Expanded(child: card)],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: cards),
    );
  }
}
