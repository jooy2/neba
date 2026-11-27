import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Whole dollars with a comma every three digits.
String _dollars(double value) {
  final String digits = value.round().toString();
  final String grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (Match match) => ',',
  );

  return '\$$grouped';
}

class SliderRange extends StatefulWidget {
  const SliderRange({super.key});

  @override
  State<SliderRange> createState() => _SliderRangeState();
}

class _SliderRangeState extends State<SliderRange> {
  List<double> _range = <double>[200, 800];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaSlider.range(
        label: const Text('Price'),
        min: 0,
        max: 1000,
        step: 50,
        values: _range,
        onValuesChange: (List<double> next) => setState(() => _range = next),
        format: _dollars,
        showValue: true,
      ),
    );
  }
}
