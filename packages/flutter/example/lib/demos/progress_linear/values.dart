import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressLinearValues extends StatefulWidget {
  const ProgressLinearValues({super.key});

  @override
  State<ProgressLinearValues> createState() => _ProgressLinearValuesState();
}

class _ProgressLinearValuesState extends State<ProgressLinearValues> {
  double _sent = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (Timer _) {
      setState(() => _sent = _sent >= 4000 ? 0 : _sent + 320);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          // A range that is not 0 to 100, shown as a percentage of itself.
          const NebaProgressLinear(
            value: 3,
            max: 4,
            label: Text('Step 3 of 4'),
            showValue: true,
            color: NebaColor.info,
          ),

          // And the same range with the caller saying what the number means.
          NebaProgressLinear(
            value: _sent,
            max: 4000,
            label: const Text('Transferred'),
            showValue: true,
            format: _megabytes,
          ),
        ],
      ),
    );
  }
}

/// `1,280 MB`: whole megabytes, grouped by thousands.
String _megabytes(double value) {
  final String digits = value.round().toString();
  final StringBuffer grouped = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      grouped.write(',');
    }

    grouped.write(digits[i]);
  }

  return '$grouped MB';
}
