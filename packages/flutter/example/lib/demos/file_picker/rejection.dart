import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const Map<NebaFileRejectionReason, String> _why = <NebaFileRejectionReason, String>{
  NebaFileRejectionReason.type: 'is not an image',
  NebaFileRejectionReason.size: 'is over 100 kB',
  NebaFileRejectionReason.count: 'would be the third file',
};

/// What the app's own file dialog would hand back, one batch a press.
const List<List<NebaFile>> _batches = <List<NebaFile>>[
  <NebaFile>[
    NebaFile(name: 'logo.png', size: 40000, type: 'image/png'),
    NebaFile(name: 'notes.txt', size: 3200, type: 'text/plain'),
  ],
  <NebaFile>[
    NebaFile(name: 'photo.jpg', size: 2100000, type: 'image/jpeg'),
    NebaFile(name: 'icon.svg', size: 3000, type: 'image/svg+xml'),
    NebaFile(name: 'banner.webp', size: 64000, type: 'image/webp'),
  ],
];

/// A rejected file that vanishes without a word is the worst thing a drop
/// target does, which is why `onReject` exists at all: the widget turns files
/// away, and only the app knows how to say so.
class FilePickerRejection extends StatefulWidget {
  const FilePickerRejection({super.key});

  @override
  State<FilePickerRejection> createState() => _FilePickerRejectionState();
}

class _FilePickerRejectionState extends State<FilePickerRejection> {
  List<NebaFile> _files = const <NebaFile>[];
  List<NebaFileRejection> _rejected = const <NebaFileRejection>[];
  int _next = 0;

  /// Stands in for the app's file dialog.
  Future<List<NebaFile>?> _pick() async {
    final List<NebaFile> batch = _batches[_next % _batches.length];

    _next += 1;

    return batch;
  }

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaFilePicker(
          multiple: true,
          accept: 'image/*',
          maxSize: 100000,
          maxFiles: 2,
          title: const Text('Images only, under 100 kB, two at a time'),
          hint: const Text('Press twice to try both batches'),
          onPick: _pick,
          value: _files,
          onFilesChange: (List<NebaFile> next) {
            setState(() {
              _files = next;
              _rejected = const <NebaFileRejection>[];
            });
          },
          onReject: (List<NebaFileRejection> rejected) => setState(() => _rejected = rejected),
        ),
        if (_rejected.isNotEmpty)
          NebaAlert(
            color: NebaColor.warning,
            title: const Text('Some files were turned away'),
            onClose: () => setState(() => _rejected = const <NebaFileRejection>[]),
            child: Text(
              _rejected
                  .map((NebaFileRejection one) => '${one.file.name} ${_why[one.reason]}')
                  .join(' · '),
            ),
          ),
      ],
    );
  }
}
