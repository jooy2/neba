import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TreeViewVariants extends StatelessWidget {
  const TreeViewVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 6,
      children: <Widget>[
        for (final NebaVariant variant in <NebaVariant>[
          NebaVariant.solid,
          NebaVariant.outline,
          NebaVariant.text,
        ])
          SizedBox(
            width: 192,
            child: NebaTreeView<String>(
              label: variant.name,
              variant: variant,
              size: NebaSize.sm,
              defaultExpanded: const <String>['design'],
              children: <NebaTreeItem<String>>[
                NebaTreeItem<String>(
                  value: 'design',
                  label: Text(variant.name),
                  children: const <NebaTreeItem<String>>[
                    NebaTreeItem<String>(value: 'brand', label: Text('Brand')),
                    NebaTreeItem<String>(value: 'product', label: Text('Product')),
                  ],
                ),
                const NebaTreeItem<String>(value: 'eng', label: Text('Engineering')),
              ],
            ),
          ),
      ],
    );
  }
}
