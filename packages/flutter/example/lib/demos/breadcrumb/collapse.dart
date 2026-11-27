import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BreadcrumbCollapse extends StatelessWidget {
  const BreadcrumbCollapse({super.key});

  List<NebaBreadcrumbItem> _steps() {
    return <NebaBreadcrumbItem>[
      for (final String step in <String>['Home', 'Acme', 'Platform', 'neba', 'main'])
        NebaBreadcrumbItem(
          onPressed: () {},
          href: Uri.parse('#${step.toLowerCase()}'),
          child: Text(step),
        ),
      const NebaBreadcrumbItem(child: Text('Button.tsx')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        // One step at each end, everything between folded behind the `…`.
        NebaBreadcrumb(maxItems: 3, label: 'Folded', children: _steps()),
        // Two kept at the front, two at the end.
        NebaBreadcrumb(
          maxItems: 4,
          itemsBeforeCollapse: 2,
          itemsAfterCollapse: 2,
          label: 'Wider ends',
          children: _steps(),
        ),
      ],
    );
  }
}
