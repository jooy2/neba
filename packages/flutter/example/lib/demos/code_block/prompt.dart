import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CodeBlockPrompt extends StatelessWidget {
  const CodeBlockPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        NebaCodeBlock(
          code: 'npm install neba\nnpm run build',
          language: 'bash',
          prompt: r'$',
          showLanguage: false,
          title: Text("a user's shell"),
        ),
        NebaCodeBlock(
          code: 'apt-get update\napt-get install -y build-essential',
          language: 'bash',
          prompt: '#',
          showLanguage: false,
          title: Text('root'),
        ),
        NebaCodeBlock(
          code: 'cd C:\\projects\\neba\nnpm run docs:dev',
          language: 'powershell',
          prompt: 'C:\\>',
          showLanguage: false,
          title: Text('PowerShell'),
        ),
      ],
    );
  }
}
