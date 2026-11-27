import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RadioGroupDescriptions extends StatelessWidget {
  const RadioGroupDescriptions({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaRadioGroup<String>(
      label: Text('Deploy target'),
      description: Text('You can change this later.'),
      defaultValue: 'preview',
      children: <Widget>[
        NebaRadio<String>(
          value: 'preview',
          label: Text('Preview'),
          description: Text('A throwaway URL per pull request.'),
        ),
        NebaRadio<String>(
          value: 'staging',
          label: Text('Staging'),
          description: Text('Shared, and reset every night.'),
        ),
        NebaRadio<String>(
          value: 'production',
          label: Text('Production'),
          description: Text('Live. Requires an approval.'),
        ),
      ],
    );
  }
}
