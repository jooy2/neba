import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ConfirmHero extends StatefulWidget {
  const ConfirmHero({super.key});

  @override
  State<ConfirmHero> createState() => _ConfirmHeroState();
}

class _ConfirmHeroState extends State<ConfirmHero> {
  List<String> _log = const <String>[];

  void _add(String line) {
    setState(() => _log = <String>[line, ..._log].take(3).toList());
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaConfirmProvider(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          _Actions(onLog: _add),
          NebaTypography(
            _log.isEmpty ? 'Nothing answered yet.' : _log.join(' · '),
            level: NebaTypographyLevel.caption,
            style: TextStyle(color: tokens.mutedFg),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onLog});

  final ValueChanged<String> onLog;

  @override
  Widget build(BuildContext context) {
    final NebaConfirm confirm = NebaConfirmProvider.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        NebaButton(
          onPressed: () async {
            final bool yes = await confirm(
              const NebaConfirmOptions(
                title: Text('Delete the project?'),
                description: Text('Everything in it goes with it. This cannot be undone.'),
                confirmLabel: Text('Delete'),
                color: NebaColor.danger,
              ),
            );

            onLog(yes ? 'Deleted the project.' : 'Kept the project.');
          },
          color: NebaColor.danger,
          child: const Text('Delete project'),
        ),
        NebaButton(
          onPressed: () async {
            await confirm(
              const NebaConfirmOptions(title: Text('Your export is ready.'), alert: true),
            );
            onLog('Acknowledged the export.');
          },
          variant: NebaVariant.outline,
          child: const Text('Show an alert'),
        ),
      ],
    );
  }
}
