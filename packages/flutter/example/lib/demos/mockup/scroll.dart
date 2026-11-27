import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _services = <String>[
  'api-gateway',
  'web-storefront',
  'checkout',
  'search-index',
  'image-resizer',
  'mailer',
  'billing',
  'webhooks',
  'auth',
  'analytics',
  'scheduler',
  'notifications',
  'exports',
  'admin',
];

class MockupScroll extends StatelessWidget {
  const MockupScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NebaMockup(
        device: NebaMockupDevice.mobile,
        size: NebaSize.xs,
        scroll: true,
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              for (final (int index, String service) in _services.indexed)
                NebaCard(
                  size: NebaSize.xs,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: <Widget>[
                      Flexible(child: NebaTypography(service, level: NebaTypographyLevel.caption)),
                      NebaChip(
                        size: NebaSize.xs,
                        variant: NebaVariant.text,
                        color: index % 4 == 1 ? NebaColor.info : NebaColor.success,
                        child: Text(index % 4 == 1 ? 'Building' : 'Live'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
