import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Stands in for the app's file dialog, which the reader dismissed.
Future<List<NebaFile>?> _pick() async => null;

class FilePickerVariants extends StatelessWidget {
  const FilePickerVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.lg.width;

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 4 : 12),
            child: NebaFilePicker(
              variant: variant,
              size: NebaSize.sm,
              title: Text(variant.name),
              hint: const Text('Any file'),
              onPick: _pick,
            ),
          ),
      ],
    );
  }
}
