import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DividerVertical extends StatelessWidget {
  const DividerVertical({super.key});

  @override
  Widget build(BuildContext context) {
    Widget cell(String text) {
      return Flexible(
        child: SizedBox(
          width: 112,
          child: Center(child: Text(text, style: const TextStyle(fontSize: 13))),
        ),
      );
    }

    return SizedBox(
      height: 128,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          cell('Before'),
          const NebaDivider(orientation: NebaOrientation.vertical),
          cell('Between'),
          const NebaDivider(orientation: NebaOrientation.vertical, child: Text('AND')),
          cell('After'),
        ],
      ),
    );
  }
}
