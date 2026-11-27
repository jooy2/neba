import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A share written as a percentage with one decimal, and read back.
String _percent(double value) => '${(value * 100).toStringAsFixed(1)}%';

double? _readPercent(String text) {
  final double? number = double.tryParse(text.replaceAll('%', '').trim());

  return number == null ? null : number / 100;
}

/// Kilograms, with the decimals the number has.
String _kilograms(double value) {
  final String number = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  return '$number kg';
}

/// Whole won with a comma every three digits.
String _won(double value) {
  final String digits = value.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (Match match) => ',',
  );

  return '₩$digits';
}

class NumberFieldFormat extends StatefulWidget {
  const NumberFieldFormat({super.key});

  @override
  State<NumberFieldFormat> createState() => _NumberFieldFormatState();
}

class _NumberFieldFormatState extends State<NumberFieldFormat> {
  double? _rate = 0.075;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 4,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            NebaNumberField(
              label: const Text('Rate'),
              value: _rate,
              onValueChange: (double? value) => setState(() => _rate = value),
              min: 0,
              max: 1,
              step: 0.005,
              format: _percent,
              parse: _readPercent,
            ),
            const NebaNumberField(
              label: Text('Weight'),
              defaultValue: 72.5,
              step: 0.5,
              format: _kilograms,
            ),
            const NebaNumberField(
              label: Text('Won'),
              defaultValue: 39000,
              step: 1000,
              format: _won,
            ),
          ],
        ),
        Text('value: $_rate', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
      ],
    );
  }
}
