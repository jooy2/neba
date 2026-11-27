import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _sections = <String>[
  'Overview',
  'Activity',
  'Members',
  'Settings',
  'Billing',
  'Integrations',
  'Audit log',
  'Webhooks',
  'API keys',
  'Domains',
];

class TabsWheel extends StatelessWidget {
  const TabsWheel({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          _Labelled(
            label: 'Roll over the bar; the page waits until the pointer leaves',
            child: _Bar(),
          ),
          _Labelled(label: "wheel: false — the wheel is the page's", child: _Bar(wheel: false)),
        ],
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NebaTypography(label, level: NebaTypographyLevel.caption, color: NebaColor.secondary),
        child,
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({this.wheel = true});

  final bool wheel;

  @override
  Widget build(BuildContext context) {
    return NebaTabs<String>(
      defaultValue: 'Overview',
      wheel: wheel,
      children: <Widget>[
        for (final String section in _sections)
          NebaTab<String>(value: section, child: Text(section)),
        const NebaTabPanel<String>(
          value: 'Overview',
          child: Text('Ten sections in a box too narrow for them.'),
        ),
      ],
    );
  }
}
