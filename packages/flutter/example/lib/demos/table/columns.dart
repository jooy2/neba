import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Product = ({String sku, String name, int stock, double price});

final List<NebaTableColumn<_Product>> _headers = <NebaTableColumn<_Product>>[
  NebaTableColumn<_Product>(
    key: 'sku',
    label: const Text('SKU'),
    width: 110,
    builder: (BuildContext context, _Product row, int index) => Text(row.sku),
  ),
  NebaTableColumn<_Product>(
    key: 'name',
    label: const Text('Product'),
    builder: (BuildContext context, _Product row, int index) => Text(row.name),
  ),
  NebaTableColumn<_Product>(
    key: 'stock',
    label: const Text('In stock'),
    width: 100,
    align: NebaAlign.center,
    builder: (BuildContext context, _Product row, int index) => Text('${row.stock}'),
  ),
  NebaTableColumn<_Product>(
    key: 'price',
    label: const Text('Price'),
    width: 120,
    align: NebaAlign.end,
    builder: (BuildContext context, _Product row, int index) =>
        Text(r'$' + row.price.toStringAsFixed(2)),
  ),
];

const List<_Product> _items = <_Product>[
  (sku: 'NB-001', name: 'Acrylic sheet, 3mm', stock: 42, price: 18.5),
  (sku: 'NB-014', name: 'Edge polish kit', stock: 7, price: 64),
  (sku: 'NB-090', name: 'Frosting spray', stock: 0, price: 9.99),
];

class TableColumns extends StatelessWidget {
  const TableColumns({super.key});

  @override
  Widget build(BuildContext context) {
    // Three fixed columns leave the product name too little room on a phone,
    // so the table keeps a width of its own there and scrolls sideways.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget table = NebaTable<_Product>(
          headers: _headers,
          items: _items,
          rowKey: (_Product row, int index) => ValueKey<String>(row.sku),
        );

        return constraints.maxWidth >= 520
            ? table
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: 520, child: table),
              );
      },
    );
  }
}
