import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DividerHero extends StatelessWidget {
  const DividerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          NebaDivider(),
          NebaDivider(child: Text('OR')),
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: <Widget>[
                Center(child: Text('Draft', style: TextStyle(fontSize: 13))),
                NebaDivider(orientation: NebaOrientation.vertical),
                Flexible(
                  child: Center(
                    child: Text(
                      'Edited 2 min ago',
                      style: TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                NebaDivider(orientation: NebaOrientation.vertical),
                Flexible(
                  child: Center(
                    child: Text(
                      '3 comments',
                      style: TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
