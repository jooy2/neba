import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<({String title, String body})> _cards = <({String title, String body})>[
  (title: 'Ingest', body: 'Events arrive and are queued.'),
  (title: 'Enrich', body: 'Each event is matched to an account.'),
  (title: 'Store', body: 'Everything lands in the warehouse.'),
];

class AnimateAppearVisible extends StatelessWidget {
  const AnimateAppearVisible({super.key});

  static Widget _column(List<Widget> children) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      alignItems: NebaAlignItems.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SizedBox(
        height: 240,
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
              NebaAnimateAppear(
                trigger: NebaAnimateTrigger.visible,
                stagger: const Duration(milliseconds: 140),
                layoutBuilder: _column,
                children: <Widget>[
                  for (final ({String title, String body}) card in _cards)
                    NebaCard(
                      key: ValueKey<String>(card.title),
                      size: NebaSize.sm,
                      title: Text(card.title),
                      child: Text(card.body),
                    ),
                ],
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}
