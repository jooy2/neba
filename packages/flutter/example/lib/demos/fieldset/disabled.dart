import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FieldsetDisabled extends StatefulWidget {
  const FieldsetDisabled({super.key});

  @override
  State<FieldsetDisabled> createState() => _FieldsetDisabledState();
}

class _FieldsetDisabledState extends State<FieldsetDisabled> {
  bool _custom = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaCheckbox(
            label: const Text('Ship to a different address'),
            checked: _custom,
            onCheckedChange: (bool checked) => setState(() => _custom = checked),
          ),
          NebaFieldset(
            legend: const Text('Delivery address'),
            disabled: !_custom,
            children: const <Widget>[
              NebaTextField(label: Text('Street')),
              NebaTextField(label: Text('City')),
            ],
          ),
        ],
      ),
    );
  }
}
