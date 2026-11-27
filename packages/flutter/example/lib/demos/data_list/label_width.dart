import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DataListLabelWidth extends StatelessWidget {
  const DataListLabelWidth({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaBox(
            child: NebaDataList(
              children: <Widget>[
                NebaDataListItem(label: Text('Id'), child: Text('8f2c1a')),
                NebaDataListItem(label: Text('Environment'), child: Text('Production')),
              ],
            ),
          ),
          NebaBox(
            child: NebaDataList(
              labelWidth: 140,
              children: <Widget>[
                NebaDataListItem(label: Text('Id'), child: Text('8f2c1a')),
                NebaDataListItem(label: Text('Environment'), child: Text('Production')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
