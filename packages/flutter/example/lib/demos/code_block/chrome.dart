import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''docker build -t neba/docs:latest .
docker run --rm -p 8080:80 neba/docs:latest''';

class CodeBlockChrome extends StatefulWidget {
  const CodeBlockChrome({super.key});

  @override
  State<CodeBlockChrome> createState() => _CodeBlockChromeState();
}

class _CodeBlockChromeState extends State<CodeBlockChrome> {
  bool _toolbar = true;
  bool _showLanguage = true;
  bool _copyable = true;
  bool _rawToggle = true;
  bool _lineNumbers = false;

  Widget _option(String label, bool checked, ValueChanged<bool> onChanged) {
    return NebaCheckbox(
      size: NebaSize.sm,
      checked: checked,
      onCheckedChange: onChanged,
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: <Widget>[
            _option('toolbar', _toolbar, (bool next) => setState(() => _toolbar = next)),
            _option(
              'showLanguage',
              _showLanguage,
              (bool next) => setState(() => _showLanguage = next),
            ),
            _option('copyable', _copyable, (bool next) => setState(() => _copyable = next)),
            _option('rawToggle', _rawToggle, (bool next) => setState(() => _rawToggle = next)),
            _option(
              'lineNumbers',
              _lineNumbers,
              (bool next) => setState(() => _lineNumbers = next),
            ),
          ],
        ),
        NebaCodeBlock(
          code: _source,
          language: 'bash',
          toolbar: _toolbar,
          showLanguage: _showLanguage,
          copyable: _copyable,
          rawToggle: _rawToggle,
          lineNumbers: _lineNumbers,
        ),
      ],
    );
  }
}
