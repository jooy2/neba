import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Entry = ({int id, String account, String memo, int amount});

const List<String> _memos = <String>['Subscription', 'Refund', 'Top-up', 'Chargeback', 'Payout'];

final List<_Entry> _items = List<_Entry>.generate(137, (int index) {
  return (
    id: 4100 + index,
    account: 'ACC-${(index * 17) % 60 + 100}',
    memo: _memos[index % _memos.length],
    // Rounded half up, as `Math.round` rounds.
    amount: (((index * 733) % 90000 - 30000) / 100 + 0.5).floor() * 100,
  );
});

/// An amount as US dollars, `-$1,200.00`.
String _dollars(int amount) {
  final String whole = amount.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (Match match) => ',',
  );

  return '${amount < 0 ? '-' : ''}\$$whole.00';
}

final List<NebaDataTableColumn<_Entry>> _headers = <NebaDataTableColumn<_Entry>>[
  NebaDataTableColumn<_Entry>(
    key: 'index',
    label: const Text('#'),
    width: 70,
    align: NebaAlign.end,
    builder: (BuildContext context, _Entry row, int index) => Text('${index + 1}'),
  ),
  NebaDataTableColumn<_Entry>(
    key: 'id',
    label: const Text('Entry'),
    width: 100,
    align: NebaAlign.end,
    value: (_Entry row) => row.id,
  ),
  NebaDataTableColumn<_Entry>(
    key: 'account',
    label: const Text('Account'),
    width: 130,
    value: (_Entry row) => row.account,
  ),
  NebaDataTableColumn<_Entry>(
    key: 'memo',
    label: const Text('Memo'),
    value: (_Entry row) => row.memo,
  ),
  NebaDataTableColumn<_Entry>(
    key: 'amount',
    label: const Text('Amount'),
    width: 130,
    align: NebaAlign.end,
    value: (_Entry row) => row.amount,
    builder: (BuildContext context, _Entry row, int index) => Text(
      _dollars(row.amount),
      style: row.amount < 0
          ? TextStyle(color: NebaTheme.of(context).roles(NebaColor.danger).accent)
          : null,
    ),
  ),
];

Object _rowKey(_Entry row, int index) => row.id;

class DataTablePages extends StatelessWidget {
  const DataTablePages({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaDataTable<_Entry>(
      semanticLabel: 'Ledger',
      headers: _headers,
      items: _items,
      rowKey: _rowKey,
      paging: NebaDataTablePaging.pages,
      defaultPageSize: 10,
      pageSizeOptions: const <int>[10, 25, 50],
      sortable: true,
      striped: NebaDataTableStripe.even,
    );
  }
}
