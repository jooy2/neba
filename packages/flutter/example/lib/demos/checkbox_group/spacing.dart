import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxGroupSpacing extends StatelessWidget {
  const CheckboxGroupSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCheckboxGroup(
      label: Text('Show in the sidebar'),
      spacing: 4,
      defaultValue: <String>['activity'],
      children: <Widget>[
        NebaCheckbox(
          value: 'activity',
          label: Text('Activity'),
          description: Text('Deploys, comments and reviews.'),
        ),
        NebaCheckbox(
          value: 'usage',
          label: Text('Usage'),
          description: Text('Requests and bandwidth this month.'),
        ),
        NebaCheckbox(
          value: 'billing',
          label: Text('Billing'),
          description: Text('The next invoice and its total.'),
        ),
      ],
    );
  }
}
