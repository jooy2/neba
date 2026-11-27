import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TourCentred extends StatefulWidget {
  const TourCentred({super.key});

  @override
  State<TourCentred> createState() => _TourCentredState();
}

class _TourCentredState extends State<TourCentred> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _open = true),
          variant: NebaVariant.outline,
          child: const Text('Start the welcome'),
        ),
        NebaTour(
          open: _open,
          onOpenChange: (bool open) => setState(() => _open = open),
          skippable: false,
          steps: const <NebaTourStep>[
            NebaTourStep(
              title: Text('Welcome to Neba Cloud'),
              content: Text(
                'Three things worth knowing before you start. It takes about a minute.',
              ),
            ),
            NebaTourStep(
              title: Text('That is it'),
              content: Text('Everything else is where you would expect it.'),
            ),
          ],
        ),
      ],
    );
  }
}
