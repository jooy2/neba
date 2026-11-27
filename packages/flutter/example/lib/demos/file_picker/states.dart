import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaFile> _sample = <NebaFile>[
  NebaFile(name: 'design-spec.pdf', size: 24000, type: 'application/pdf'),
];

/// Stands in for the app's file dialog.
Future<List<NebaFile>?> _pick() async => _sample;

class FilePickerStates extends StatelessWidget {
  const FilePickerStates({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.lg.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaFilePicker(
            size: NebaSize.sm,
            label: Text('Required'),
            error: Text('Pick a file before saving.'),
            title: Text('Nothing here yet'),
            onPick: _pick,
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaFilePicker(
            size: NebaSize.sm,
            label: Text('Read-only'),
            readOnly: true,
            defaultValue: _sample,
            title: Text('Locked'),
            onPick: _pick,
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaFilePicker(
            size: NebaSize.sm,
            label: Text('Disabled'),
            disabled: true,
            title: Text('Unavailable'),
            onPick: _pick,
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaFilePicker(
            size: NebaSize.sm,
            label: Text('No picture, no list'),
            showIcon: false,
            showList: false,
            defaultValue: _sample,
            title: Text('Just the sentence'),
            hint: Text('showIcon: false · showList: false'),
            onPick: _pick,
          ),
        ),
      ],
    );
  }
}
