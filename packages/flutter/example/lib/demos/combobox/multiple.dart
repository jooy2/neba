import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _labels = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'bug', label: 'bug'),
  NebaComboboxOption<String>(value: 'docs', label: 'documentation'),
  NebaComboboxOption<String>(value: 'dx', label: 'developer experience'),
  NebaComboboxOption<String>(value: 'good-first', label: 'good first issue'),
  NebaComboboxOption<String>(value: 'perf', label: 'performance'),
];

class ComboboxMultiple extends StatefulWidget {
  const ComboboxMultiple({super.key});

  @override
  State<ComboboxMultiple> createState() => _ComboboxMultipleState();
}

class _ComboboxMultipleState extends State<ComboboxMultiple> {
  List<String> _chosen = <String>['bug'];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          NebaCombobox<String>.multiple(
            fullWidth: true,
            items: _labels,
            label: const Text('Labels'),
            placeholder: 'Add a label',
            description: const Text(
              'Type something the list does not have and the last row offers it.',
            ),
            value: _chosen,
            onValueChange: (List<String> next) => setState(() => _chosen = next),
          ),
          Text(
            _chosen.isEmpty ? 'nothing chosen' : _chosen.join(', '),
            style: TextStyle(fontSize: 12, color: tokens.mutedFg),
          ),
        ],
      ),
    );
  }
}
