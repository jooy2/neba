import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const Map<String, String> _samples = <String, String>{
  'tsx': r'''export function Greeting({ name }: { name: string }) {
  return <p className="text-lg">Hello, {name}!</p>;
}''',
  'python': r'''from dataclasses import dataclass

@dataclass
class Point:
    x: float = 0.0
    y: float = 0.0

    def scaled(self, by: float) -> "Point":
        return Point(self.x * by, self.y * by)''',
  'yaml': r'''name: run-test
on:
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5''',
  'sql': r'''SELECT p.name, count(o.id) AS orders
FROM products p
LEFT JOIN orders o ON o.product_id = p.id
WHERE p.archived_at IS NULL
GROUP BY p.name
ORDER BY orders DESC
LIMIT 10;''',
  'rust': r'''fn main() {
    let names = vec!["ada", "grace", "alan"];
    for (index, name) in names.iter().enumerate() {
        println!("{index}: {name}");
    }
}''',
};

class CodeBlockLanguage extends StatefulWidget {
  const CodeBlockLanguage({super.key});

  @override
  State<CodeBlockLanguage> createState() => _CodeBlockLanguageState();
}

class _CodeBlockLanguageState extends State<CodeBlockLanguage> {
  String _language = 'tsx';

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaSelect<String>(
            size: NebaSize.sm,
            label: const Text('Language'),
            items: <NebaSelectOption<String>>[
              for (final String name in _samples.keys)
                NebaSelectOption<String>(value: name, label: Text(name)),
            ],
            value: _language,
            onValueChange: (String? next) => setState(() => _language = next ?? _language),
          ),
        ),
        NebaCodeBlock(code: _samples[_language]!, language: _language),
      ],
    );
  }
}
