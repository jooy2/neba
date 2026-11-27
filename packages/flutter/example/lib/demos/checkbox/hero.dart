import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxHero extends StatelessWidget {
  const CheckboxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaCheckbox(label: Text('Remember me'), defaultChecked: true),
        NebaCheckbox(
          label: Text('Send me product updates'),
          description: Text('About once a month. No newsletters.'),
        ),
        NebaCheckbox(label: Text('Delete after export'), color: NebaColor.danger),
        NebaCheckbox(
          label: Text('Managed by your workspace'),
          disabled: true,
          defaultChecked: true,
        ),
      ],
    );
  }
}
