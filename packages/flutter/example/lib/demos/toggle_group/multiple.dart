import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleGroupMultiple extends StatefulWidget {
  const ToggleGroupMultiple({super.key});

  @override
  State<ToggleGroupMultiple> createState() => _ToggleGroupMultipleState();
}

class _ToggleGroupMultipleState extends State<ToggleGroupMultiple> {
  List<String> _marks = <String>['bold'];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaToggleGroup(
          multiple: true,
          semanticLabel: 'Marks',
          value: _marks,
          onValueChange: (List<String> next) => setState(() => _marks = next),
          children: const <Widget>[
            NebaToggle(value: 'bold', child: Text('Bold')),
            NebaToggle(value: 'italic', child: Text('Italic')),
            NebaToggle(value: 'underline', child: Text('Underline')),
          ],
        ),
        Text(
          _marks.isEmpty ? 'none' : _marks.join(', '),
          style: TextStyle(fontSize: 12, color: tokens.mutedFg),
        ),
      ],
    );
  }
}
