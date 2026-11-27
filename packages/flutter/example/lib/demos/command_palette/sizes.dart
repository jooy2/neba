import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaCommandItem> _items = <NebaCommandItem>[
  NebaCommandItem(value: 'a', label: 'Go to overview'),
  NebaCommandItem(value: 'b', label: 'Deploy production'),
  NebaCommandItem(value: 'c', label: 'Invite a teammate'),
];

const List<NebaSize> _sizes = <NebaSize>[NebaSize.sm, NebaSize.md, NebaSize.lg];

class CommandPaletteSizes extends StatefulWidget {
  const CommandPaletteSizes({super.key});

  @override
  State<CommandPaletteSizes> createState() => _CommandPaletteSizesState();
}

class _CommandPaletteSizesState extends State<CommandPaletteSizes> {
  NebaSize? _size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        for (final NebaSize size in _sizes)
          NebaButton(
            onPressed: () => setState(() => _size = size),
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            child: Text(size.name),
          ),
        NebaCommandPalette(
          items: _items,
          shortcut: null,
          size: _size ?? NebaSize.md,
          open: _size != null,
          onOpenChange: (bool open) => setState(() => _size = open ? _size : null),
        ),
      ],
    );
  }
}
