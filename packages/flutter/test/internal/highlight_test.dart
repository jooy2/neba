// The lexers behind NebaCodeBlock, checked directly: which name a spelling
// means, how runs split into lines, and the colour of the runs the
// documentation's demos lean on in each language.

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/highlight.dart';

void main() {
  tearDown(resetNebaCodeLanguages);

  /// The runs of [source] in [language] that are not plain, as `kind:text`.
  List<String> marked(String source, String language) {
    return <String>[
      for (final List<NebaCodeSpan> line in nebaHighlight(source, language)!)
        for (final NebaCodeSpan span in line)
          if (span.kind != NebaCodeKind.plain) '${span.kind.name}:${span.text}',
    ];
  }

  group('names', () {
    test('reads a spelling off a fenced block or an extension', () {
      expect(nebaCodeLanguage('TSX'), 'typescript');
      expect(nebaCodeLanguage(' yml '), 'yaml');
      expect(nebaCodeLanguage('sh'), 'bash');
      expect(nebaCodeLanguage('html'), 'xml');
    });

    test('keeps a name it does not know, and has none for nothing', () {
      expect(nebaCodeLanguage('klingon'), 'klingon');
      expect(nebaCodeLanguage(''), isNull);
      expect(nebaCodeLanguage(null), isNull);
      expect(nebaHighlight('a', 'klingon'), isNull);
    });

    test('lets a registered language win over an alias spelled the same', () {
      registerNebaCodeLanguage(
        'vue',
        (String source) => <NebaCodeSpan>[NebaCodeSpan(source, NebaCodeKind.tag)],
      );

      expect(nebaCodeLanguage('vue'), 'vue');
      expect(marked('<a>', 'vue'), <String>['tag:<a>']);
    });
  });

  group('lines', () {
    test('splits a run across a newline onto both lines, in its colour', () {
      expect(
        nebaCodeLines(const <NebaCodeSpan>[
          NebaCodeSpan('a '),
          NebaCodeSpan('/* b\nc */', NebaCodeKind.comment),
          NebaCodeSpan('\n\nd'),
        ]),
        <List<NebaCodeSpan>>[
          const <NebaCodeSpan>[NebaCodeSpan('a '), NebaCodeSpan('/* b', NebaCodeKind.comment)],
          const <NebaCodeSpan>[NebaCodeSpan('c */', NebaCodeKind.comment)],
          const <NebaCodeSpan>[],
          const <NebaCodeSpan>[NebaCodeSpan('d')],
        ],
      );
    });

    test('draws plain lines with a blank line as no runs at all', () {
      expect(nebaPlainLines('a\n\nb'), <List<NebaCodeSpan>>[
        const <NebaCodeSpan>[NebaCodeSpan('a')],
        const <NebaCodeSpan>[],
        const <NebaCodeSpan>[NebaCodeSpan('b')],
      ]);
    });
  });

  group('languages', () {
    test('TypeScript: keywords, calls, members, types and literals', () {
      expect(
        marked('const n: number = JSON.parse(text).count ?? 0; // done', 'typescript'),
        <String>[
          'keyword:const',
          'type:number',
          'type:JSON',
          'function:parse',
          'attribute:count',
          'number:0',
          'comment:// done',
        ],
      );
    });

    test('JSX: the tag, its name, its attributes and the script inside it', () {
      expect(marked('return <p className="lead">{name}</p>;', 'typescript'), <String>[
        'keyword:return',
        'tag:<',
        'function:p',
        'attribute:className',
        'string:"lead"',
        'tag:>',
        'tag:</',
        'function:p',
        'tag:>',
      ]);
    });

    test('a comparison is not an element', () {
      expect(marked('a < b', 'typescript'), isEmpty);
    });

    test('Bash: comments, strings with their variables, and built-ins', () {
      expect(marked('# deploy\necho "to \$HOST" --fast 2>&1', 'bash'), <String>[
        'comment:# deploy',
        'type:echo',
        'string:"to ',
        r'variable:$HOST',
        'string:"',
      ]);
    });

    test('Python: decorators, definitions and the built-in types', () {
      expect(marked('@dataclass\ndef scaled(self, by: float):', 'python'), <String>[
        'meta:@dataclass',
        'keyword:def',
        'function:scaled',
        'variable:self',
        'type:float',
      ]);
    });

    test('YAML: keys, bullets, scalars and literals', () {
      expect(marked('on:\n  - uses: actions/checkout@v5\n    ok: true', 'yaml'), <String>[
        'attribute:on',
        'number:-',
        'attribute:uses',
        'string:actions/checkout@v5',
        'attribute:ok',
        'keyword:true',
      ]);
    });

    test('SQL: keywords in any case, functions and operators', () {
      expect(marked('select count(id) from t where n = 1', 'sql'), <String>[
        'keyword:select',
        'type:count',
        'keyword:from',
        'keyword:where',
        'keyword:=',
        'number:1',
      ]);
    });

    test('Rust: definitions, macros and types', () {
      expect(marked('fn main() { let v: Vec<u8> = vec![]; }', 'rust'), <String>[
        'keyword:fn',
        'function:main',
        'keyword:let',
        'type:Vec',
        'type:u8',
        'function:vec!',
      ]);
    });

    test('CSS: selectors, properties and functions', () {
      expect(marked('.a[data-b]::after { content: attr(x); }', 'css'), <String>[
        'function:.a',
        'attribute:[data-b]::after',
        'attribute:content',
        'type:attr',
      ]);
    });

    test('PowerShell: a command alias at the start of a line', () {
      expect(marked('cd C:\\projects\\neba', 'powershell'), <String>['type:cd']);
    });

    test('a diff: additions, deletions and hunks', () {
      expect(marked('@@ -1 +1 @@\n-old\n+new', 'diff'), <String>[
        'meta:@@ -1 +1 @@',
        'deletion:-old',
        'addition:+new',
      ]);
    });
  });
}
