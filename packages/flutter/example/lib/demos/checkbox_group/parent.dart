import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String)> _regions = <(String, String)>[
  ('icn', 'Seoul'),
  ('nrt', 'Tokyo'),
  ('fra', 'Frankfurt'),
  ('iad', 'Washington DC'),
];

class CheckboxGroupParent extends StatefulWidget {
  const CheckboxGroupParent({super.key});

  @override
  State<CheckboxGroupParent> createState() => _CheckboxGroupParentState();
}

class _CheckboxGroupParentState extends State<CheckboxGroupParent> {
  List<String> _value = <String>['icn'];

  @override
  Widget build(BuildContext context) {
    return NebaCheckboxGroup(
      label: const Text('Deploy to'),
      value: _value,
      onValueChange: (List<String> next) => setState(() => _value = next),
      allValues: <String>[for (final (String value, String _) in _regions) value],
      children: <Widget>[
        const NebaCheckbox(parent: true, label: Text('Every region')),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 24),
          child: NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            children: <Widget>[
              for (final (String value, String label) in _regions)
                NebaCheckbox(value: value, label: Text(label)),
            ],
          ),
        ),
      ],
    );
  }
}
