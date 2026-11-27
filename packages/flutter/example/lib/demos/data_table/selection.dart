import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Asset = ({String path, String kind, int size});

const List<String> _kinds = <String>[
  'image/png',
  'image/svg+xml',
  'font/woff2',
  'text/css',
  'video/mp4',
];

final List<_Asset> _items = List<_Asset>.generate(600, (int index) {
  final String kind = _kinds[index % _kinds.length];

  return (
    path: 'assets/${kind.split('/').first}/file-${'$index'.padLeft(3, '0')}',
    kind: kind,
    size: 1024 + (index * 971) % 4000000,
  );
});

final List<NebaDataTableColumn<_Asset>> _headers = <NebaDataTableColumn<_Asset>>[
  NebaDataTableColumn<_Asset>(
    key: 'path',
    label: const Text('Path'),
    value: (_Asset row) => row.path,
  ),
  NebaDataTableColumn<_Asset>(
    key: 'kind',
    label: const Text('Type'),
    width: 150,
    value: (_Asset row) => row.kind,
  ),
  NebaDataTableColumn<_Asset>(
    key: 'size',
    label: const Text('Size'),
    width: 110,
    align: NebaAlign.end,
    value: (_Asset row) => row.size,
    builder: (BuildContext context, _Asset row, int index) =>
        Text('${(row.size / 1024).round()} KB'),
  ),
];

Object _rowKey(_Asset row, int index) => row.path;

class DataTableSelection extends StatefulWidget {
  const DataTableSelection({super.key});

  @override
  State<DataTableSelection> createState() => _DataTableSelectionState();
}

class _DataTableSelectionState extends State<DataTableSelection> {
  List<Object> _selected = <Object>[];
  String? _opened;

  @override
  Widget build(BuildContext context) {
    final String? opened = _opened;

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaDataTable<_Asset>(
          semanticLabel: 'Assets',
          headers: _headers,
          items: _items,
          rowKey: _rowKey,
          height: 240,
          selectionMode: NebaDataTableSelectionMode.multiple,
          checkboxes: true,
          selected: _selected,
          onSelectedChange: (List<Object> selected, List<_Asset> rows) =>
              setState(() => _selected = selected),
          onRowActivate: (_Asset row, int index) => setState(() => _opened = row.path),
        ),
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 12, color: NebaTheme.of(context).mutedFg),
          child: NebaFlex(
            wrap: true,
            spacing: 3,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              NebaButton(
                size: NebaSize.xs,
                variant: NebaVariant.text,
                disabled: _selected.isEmpty,
                onPressed: () => setState(() => _selected = <Object>[]),
                child: Text('Clear ${_selected.length} selected'),
              ),
              const NebaFlex(
                wrap: true,
                spacing: 1,
                alignItems: NebaAlignItems.center,
                children: <Widget>[
                  NebaShortcut.split(keys: <String>['Shift', 'ArrowUp'], size: NebaSize.xs),
                  Text('extends ·'),
                  NebaShortcut.split(keys: <String>['Mod', 'A'], size: NebaSize.xs),
                  Text('takes everything ·'),
                  NebaShortcut(keys: 'Enter', size: NebaSize.xs),
                  Text('opens'),
                ],
              ),
              if (opened != null) Text('Opened $opened'),
            ],
          ),
        ),
      ],
    );
  }
}
