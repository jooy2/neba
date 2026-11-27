import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _countries = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'kr', label: Text('South Korea')),
  NebaSelectOption<String>(value: 'jp', label: Text('Japan')),
  NebaSelectOption<String>(value: 'us', label: Text('United States')),
];

class FieldsetHero extends StatelessWidget {
  const FieldsetHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaCard(
        title: Text('Checkout'),
        child: NebaFieldset(
          legend: Text('Billing address'),
          description: Text('Where the card statement goes.'),
          children: <Widget>[
            NebaTextField(label: Text('Street')),
            NebaTextField(label: Text('City')),
            NebaSelect<String>(
              items: _countries,
              label: Text('Country'),
              placeholder: Text('Choose one'),
            ),
          ],
        ),
      ),
    );
  }
}
