import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptyHero extends StatelessWidget {
  const EmptyHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: NebaCard(
        title: const Text('Projects'),
        dividers: true,
        child: NebaEmpty(
          title: const Text('No projects yet'),
          actions: <Widget>[
            NebaButton(onPressed: () {}, size: NebaSize.sm, child: const Text('Create a project')),
          ],
          child: const Text(
            'Everything you deploy shows up here. Start from scratch or import a repository.',
          ),
        ),
      ),
    );
  }
}
