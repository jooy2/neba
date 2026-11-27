import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CheckboxGroupHero extends StatelessWidget {
  const CheckboxGroupHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCheckboxGroup(
      label: Text('Email me about'),
      defaultValue: <String>['deploys', 'digest'],
      children: <Widget>[
        NebaCheckbox(value: 'deploys', label: Text('Failed deploys')),
        NebaCheckbox(value: 'members', label: Text('New members')),
        NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
      ],
    );
  }
}
