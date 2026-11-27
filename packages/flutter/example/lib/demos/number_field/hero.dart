import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Whole dollars with a comma every three digits.
String _dollars(double value) {
  final String digits = value.round().abs().toString();
  final String grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (Match match) => ',',
  );

  return '${value < 0 ? '-' : ''}\$$grouped';
}

class NumberFieldHero extends StatelessWidget {
  const NumberFieldHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaNumberField(label: Text('Seats'), defaultValue: 3, min: 1, max: 20),
        NebaNumberField(
          label: Text('Budget'),
          defaultValue: 1240,
          min: 0,
          step: 10,
          format: _dollars,
          description: Text('Shift steps by 10× and Alt by a tenth.'),
        ),
      ],
    );
  }
}
