import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<({String id, String detail})> _projects = <({String id, String detail})>[
  (id: 'web', detail: 'Deployed 4 minutes ago'),
  (id: 'api', detail: 'Deployed 2 hours ago'),
  (id: 'docs', detail: 'Deployed yesterday'),
];

class ListSpacing extends StatefulWidget {
  const ListSpacing({super.key});

  @override
  State<ListSpacing> createState() => _ListSpacingState();
}

class _ListSpacingState extends State<ListSpacing> {
  String _open = 'web';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: NebaList(
        spacing: 1,
        children: <Widget>[
          for (final ({String id, String detail}) project in _projects)
            NebaListItem(
              description: Text(project.detail),
              selected: _open == project.id,
              onPressed: () => setState(() => _open = project.id),
              child: Text(project.id),
            ),
        ],
      ),
    );
  }
}
