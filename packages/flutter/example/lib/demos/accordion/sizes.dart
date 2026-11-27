import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AccordionSizes extends StatelessWidget {
  const AccordionSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaAccordion<String>(
            size: size,
            defaultValue: const <String>['a'],
            children: <Widget>[
              NebaAccordionItem<String>(
                value: 'a',
                title: Text(size.name),
                subtitle: const Text('Radius and padding, never the ladder'),
                child: const Text(
                  "A section's size is the sheet's size — its radius and its padding — exactly "
                  'as on Box.',
                ),
              ),
            ],
          ),
      ],
    );
  }
}
