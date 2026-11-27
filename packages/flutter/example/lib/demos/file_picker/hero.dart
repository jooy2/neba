import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// What the app's own file dialog would hand back, one file a press.
const List<NebaFile> _samples = <NebaFile>[
  NebaFile(name: 'receipt.pdf', size: 182000, type: 'application/pdf'),
  NebaFile(name: 'whiteboard.jpg', size: 2400000, type: 'image/jpeg'),
  NebaFile(name: 'notes.txt', size: 3200, type: 'text/plain'),
  NebaFile(name: 'scan.png', size: 7200000, type: 'image/png'),
];

class FilePickerHero extends StatefulWidget {
  const FilePickerHero({super.key});

  @override
  State<FilePickerHero> createState() => _FilePickerHeroState();
}

class _FilePickerHeroState extends State<FilePickerHero> {
  List<NebaFile> _files = const <NebaFile>[];
  int _next = 0;

  /// Stands in for the app's file dialog.
  Future<List<NebaFile>?> _pick() async {
    final NebaFile file = _samples[_next % _samples.length];

    _next += 1;

    return <NebaFile>[file];
  }

  @override
  Widget build(BuildContext context) {
    return NebaFilePicker(
      multiple: true,
      label: const Text('Attachments'),
      accept: 'image/*,.pdf',
      maxSize: 5000000,
      maxFiles: 4,
      hint: const Text('PNG, JPG or PDF · up to 5 MB each · 4 files'),
      description: const Text('Every file is checked against accept, picked or dropped.'),
      onPick: _pick,
      value: _files,
      onFilesChange: (List<NebaFile> files) => setState(() => _files = files),
    );
  }
}
