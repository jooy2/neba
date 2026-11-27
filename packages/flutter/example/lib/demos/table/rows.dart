import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Member = ({String email, String role});

final List<NebaTableColumn<_Member>> _headers = <NebaTableColumn<_Member>>[
  NebaTableColumn<_Member>(
    key: 'email',
    label: const Text('Member'),
    builder: (BuildContext context, _Member row, int index) => Text(row.email),
  ),
  NebaTableColumn<_Member>(
    key: 'role',
    label: const Text('Role'),
    width: 140,
    align: NebaAlign.end,
    builder: (BuildContext context, _Member row, int index) => Text(row.role),
  ),
];

const List<_Member> _items = <_Member>[
  (email: 'jane@example.com', role: 'Owner'),
  (email: 'sam@example.com', role: 'Admin'),
  (email: 'kim@example.com', role: 'Member'),
  (email: 'lee@example.com', role: 'Member'),
];

class TableRows extends StatefulWidget {
  const TableRows({super.key});

  @override
  State<TableRows> createState() => _TableRowsState();
}

class _TableRowsState extends State<TableRows> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaTable<_Member>(
          headers: _headers,
          items: _items,
          rowKey: (_Member row, int index) => ValueKey<String>(row.email),
          striped: true,
          size: NebaSize.sm,
          onRowPressed: (_Member row, int index) => setState(() => _picked = row.email),
        ),
        NebaTypography(
          _picked == null ? 'Click a row.' : 'Selected $_picked',
          level: NebaTypographyLevel.caption,
        ),
      ],
    );
  }
}
