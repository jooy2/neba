import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _results = <String>[
  'Acrylic surfaces and the light that lands on them',
  'A control never moves: colour and depth carry every state',
  'Translucency is tuned with the blur radius, not the alpha',
];

class HighlightHero extends StatefulWidget {
  const HighlightHero({super.key});

  @override
  State<HighlightHero> createState() => _HighlightHeroState();
}

class _HighlightHeroState extends State<HighlightHero> {
  String _query = 'a control';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaTextField(
            label: const Text('Search'),
            initialValue: _query,
            onChanged: (String value) => setState(() => _query = value),
            placeholder: 'Type to highlight',
            fullWidth: true,
          ),
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 13, height: 1.5),
            child: NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 2,
              children: <Widget>[
                for (final String result in _results)
                  NebaHighlight(query: _query, child: Text(result)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
