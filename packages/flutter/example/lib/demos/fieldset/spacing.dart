import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FieldsetSpacing extends StatelessWidget {
  const FieldsetSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFieldset(
        legend: Text('Shipping address'),
        spacing: 6,
        children: <Widget>[
          NebaTextField(label: Text('Street')),
          NebaTextField(label: Text('City')),
          NebaSelect<String>(
            label: Text('Country'),
            placeholder: Text('Choose one'),
            items: <NebaSelectOption<String>>[
              NebaSelectOption<String>(value: 'kr', label: Text('South Korea')),
              NebaSelectOption<String>(value: 'jp', label: Text('Japan')),
            ],
          ),
        ],
      ),
    );
  }
}
