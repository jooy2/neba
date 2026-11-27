import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BreadcrumbHero extends StatelessWidget {
  const BreadcrumbHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaBreadcrumb(
      children: <NebaBreadcrumbItem>[
        NebaBreadcrumbItem(onPressed: () {}, href: Uri.parse('#home'), child: const Text('Home')),
        NebaBreadcrumbItem(
          onPressed: () {},
          href: Uri.parse('#projects'),
          child: const Text('Projects'),
        ),
        NebaBreadcrumbItem(onPressed: () {}, href: Uri.parse('#neba'), child: const Text('Neba')),
        const NebaBreadcrumbItem(child: Text('Settings')),
      ],
    );
  }
}
