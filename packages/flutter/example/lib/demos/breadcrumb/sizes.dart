import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BreadcrumbSizes extends StatelessWidget {
  const BreadcrumbSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaBreadcrumb(
            size: size,
            label: size.name,
            children: <NebaBreadcrumbItem>[
              NebaBreadcrumbItem(
                onPressed: () {},
                href: Uri.parse('#home'),
                child: const Text('Home'),
              ),
              NebaBreadcrumbItem(
                onPressed: () {},
                href: Uri.parse('#projects'),
                child: const Text('Projects'),
              ),
              NebaBreadcrumbItem(child: Text(size.name)),
            ],
          ),
      ],
    );
  }
}
