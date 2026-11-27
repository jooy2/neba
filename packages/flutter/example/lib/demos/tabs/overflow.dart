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
];

class TabsOverflow extends StatelessWidget {
  const TabsOverflow({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          _Labelled(label: 'overflow: scroll — the default', child: _Bar()),
          _Labelled(
            label: 'overflow: wrap',
            child: _Bar(overflow: NebaTabsOverflow.wrap),
          ),
          _Labelled(
            label: 'overflow: wrap · lines: 2',
            child: _Bar(overflow: NebaTabsOverflow.wrap, lines: 2),
          ),
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
  const _Bar({this.overflow = NebaTabsOverflow.scroll, this.lines});

  final NebaTabsOverflow overflow;
  final int? lines;

  @override
  Widget build(BuildContext context) {
    return NebaTabs<String>(
      defaultValue: 'Overview',
      overflow: overflow,
      lines: lines,
      children: <Widget>[
        for (final String section in _sections)
          NebaTab<String>(value: section, child: Text(section)),
        const NebaTabPanel<String>(
          value: 'Overview',
          child: Text('Nine sections in a box too narrow for them.'),
        ),
      ],
    );
  }
}
