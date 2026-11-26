import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridSpans extends StatelessWidget {
  const GridSpans({super.key});

  static const List<List<int>> rows = <List<int>>[
    <int>[12],
    <int>[6, 6],
    <int>[4, 4, 4],
    <int>[3, 3, 3, 3],
    <int>[8, 4],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: <Widget>[
        for (final List<int> row in rows)
          NebaGridContainer(
            padded: false,
            children: <Widget>[
              for (final int span in row)
                NebaGrid(
                  span: NebaGridSpan.columns(span),
                  child: NebaBox(
                    size: NebaSize.sm,
                    child: Center(child: Text('$span')),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
