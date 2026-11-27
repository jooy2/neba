import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _scopes = <String>['Read', 'Write', 'Delete'];

class CheckboxIndeterminate extends StatefulWidget {
  const CheckboxIndeterminate({super.key});

  @override
  State<CheckboxIndeterminate> createState() => _CheckboxIndeterminateState();
}

class _CheckboxIndeterminateState extends State<CheckboxIndeterminate> {
  List<bool> _checked = <bool>[true, false, false];

  @override
  Widget build(BuildContext context) {
    final bool all = _checked.every((bool on) => on);
    final bool some = _checked.any((bool on) => on);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaCheckbox(
          label: const Text('All permissions'),
          checked: all,
          indeterminate: some && !all,
          onCheckedChange: (bool next) {
            setState(() => _checked = <bool>[for (final bool _ in _checked) next]);
          },
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 24),
          child: NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 3,
            children: <Widget>[
              for (int i = 0; i < _scopes.length; i++)
                NebaCheckbox(
                  label: Text(_scopes[i]),
                  checked: _checked[i],
                  onCheckedChange: (bool next) {
                    setState(() {
                      _checked = <bool>[
                        for (int j = 0; j < _checked.length; j++) j == i ? next : _checked[j],
                      ];
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
