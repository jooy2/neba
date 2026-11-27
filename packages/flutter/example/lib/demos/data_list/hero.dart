import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DataListHero extends StatelessWidget {
  const DataListHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaCard(
        title: const Text('Deployment 8f2c1a'),
        subtitle: const Text('Production'),
        child: NebaDataList(
          dividers: true,
          children: <Widget>[
            const NebaDataListItem(
              label: Text('Status'),
              child: NebaChip(
                size: NebaSize.xs,
                variant: NebaVariant.solid,
                color: NebaColor.success,
                child: Text('Live'),
              ),
            ),
            const NebaDataListItem(label: Text('Region'), child: Text('Frankfurt · eu-central-1')),
            const NebaDataListItem(
              label: Text('Author'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  NebaAvatar(
                    size: NebaSize.xs,
                    image: AssetImage('assets/samples/people/anya-sol.jpg'),
                    name: 'Anya Sol',
                  ),
                  Flexible(child: Text('Kim Minji')),
                ],
              ),
            ),
            const NebaDataListItem(label: Text('Duration'), child: Text('42s')),
            NebaDataListItem(
              label: const Text('Commit'),
              child: NebaTextLink(
                onPressed: () {},
                href: Uri.parse('#commit'),
                child: const Text('8f2c1a'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
