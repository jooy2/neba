import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TourHero extends StatefulWidget {
  const TourHero({super.key});

  @override
  State<TourHero> createState() => _TourHeroState();
}

class _TourHeroState extends State<TourHero> {
  final GlobalKey _search = GlobalKey();
  final GlobalKey _status = GlobalKey();
  final GlobalKey _deploy = GlobalKey();
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaToolbar(
            size: NebaSize.sm,
            end: <Widget>[
              NebaButton(
                key: _deploy,
                onPressed: () {},
                size: NebaSize.sm,
                child: const Text('Deploy'),
              ),
            ],
            children: <Widget>[
              Flexible(
                child: NebaTextField(
                  key: _search,
                  size: NebaSize.sm,
                  placeholder: 'Search projects',
                ),
              ),
              NebaChip(
                key: _status,
                size: NebaSize.sm,
                variant: NebaVariant.solid,
                color: NebaColor.success,
                child: const Text('Live'),
              ),
            ],
          ),
          const NebaBox(
            child: NebaTypography(
              'A page that already exists. The tour stands over it and points.',
              color: NebaColor.secondary,
            ),
          ),
          NebaButton(
            onPressed: () => setState(() => _open = true),
            variant: NebaVariant.outline,
            child: const Text('Show me around'),
          ),
          NebaTour(
            open: _open,
            onOpenChange: (bool open) => setState(() => _open = open),
            steps: <NebaTourStep>[
              NebaTourStep(
                target: _search,
                title: const Text('Find anything'),
                content: const Text('Every project, deployment and log line is behind this field.'),
              ),
              NebaTourStep(
                target: _status,
                title: const Text('The current state'),
                content: const Text('Green means the last deploy is serving traffic.'),
              ),
              NebaTourStep(
                target: _deploy,
                title: const Text('Ship it'),
                content: const Text(
                  'Builds the current branch and moves traffic when it is healthy.',
                ),
                side: NebaSide.left,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
