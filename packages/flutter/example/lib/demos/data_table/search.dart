import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Package = ({String name, String version, String licence, int size, bool outdated});

const List<_Package> _items = <_Package>[
  (name: '@base-ui/react', version: '1.2.0', licence: 'MIT', size: 412, outdated: false),
  (name: 'react', version: '19.1.0', licence: 'MIT', size: 132, outdated: false),
  (name: 'react-dom', version: '19.1.0', licence: 'MIT', size: 1040, outdated: false),
  (name: 'tailwindcss', version: '4.0.3', licence: 'MIT', size: 380, outdated: true),
  (name: 'vitepress', version: '1.6.1', licence: 'MIT', size: 2180, outdated: true),
  (name: 'vitest', version: '4.1.10', licence: 'MIT', size: 1460, outdated: false),
  (name: 'terser', version: '5.36.0', licence: 'BSD-2-Clause', size: 940, outdated: true),
  (name: 'typescript', version: '5.7.2', licence: 'Apache-2.0', size: 22100, outdated: false),
];

final List<NebaDataTableColumn<_Package>> _headers = <NebaDataTableColumn<_Package>>[
  NebaDataTableColumn<_Package>(
    key: 'name',
    label: const Text('Package'),
    value: (_Package row) => row.name,
  ),
  NebaDataTableColumn<_Package>(
    key: 'version',
    label: const Text('Version'),
    width: 110,
    value: (_Package row) => row.version,
  ),
  NebaDataTableColumn<_Package>(
    key: 'licence',
    label: const Text('Licence'),
    width: 130,
    value: (_Package row) => row.licence,
  ),
  NebaDataTableColumn<_Package>(
    key: 'size',
    label: const Text('Install size'),
    width: 130,
    align: NebaAlign.end,
    value: (_Package row) => row.size,
    builder: (BuildContext context, _Package row, int index) =>
        Text('${(row.size / 1024).toStringAsFixed(1)} MB'),
  ),
  NebaDataTableColumn<_Package>(
    key: 'outdated',
    label: const Text('State'),
    width: 110,
    // `searchable: false` keeps `true` and `false` out of the query, which
    // would otherwise make "true" match half the table.
    searchable: false,
    value: (_Package row) => row.outdated,
    builder: (BuildContext context, _Package row, int index) => row.outdated
        ? const NebaChip(
            size: NebaSize.xs,
            variant: NebaVariant.text,
            color: NebaColor.warning,
            child: Text('outdated'),
          )
        : const SizedBox.shrink(),
  ),
];

Object _rowKey(_Package row, int index) => row.name;

bool _outdatedOnly(_Package row, int index) => row.outdated;

class DataTableSearch extends StatefulWidget {
  const DataTableSearch({super.key});

  @override
  State<DataTableSearch> createState() => _DataTableSearchState();
}

class _DataTableSearchState extends State<DataTableSearch> {
  bool _onlyOutdated = false;

  @override
  Widget build(BuildContext context) {
    return NebaDataTable<_Package>(
      semanticLabel: 'Packages',
      headers: _headers,
      items: _items,
      rowKey: _rowKey,
      sortable: true,
      searchable: true,
      searchPlaceholder: 'Filter packages',
      filter: _onlyOutdated ? _outdatedOnly : null,
      toolbar: NebaButton(
        size: NebaSize.sm,
        variant: _onlyOutdated ? NebaVariant.solid : NebaVariant.text,
        color: NebaColor.warning,
        onPressed: () => setState(() => _onlyOutdated = !_onlyOutdated),
        child: const Text('Outdated only'),
      ),
      empty: const Text('No package matches.'),
    );
  }
}
