/// What colours a [NebaCodeBlock]'s code: the React package's
/// `internal/highlight.ts`, without highlight.js.
///
/// The React package reaches highlight.js through a dynamic import, one
/// grammar per language. A Flutter package takes no dependency for it, so the
/// lexers here are written out, one small function per language, and they
/// colour what the documentation's demos colour: TypeScript and JavaScript
/// with JSX, JSON, HTML and XML, CSS, Bash, PowerShell, Python, YAML, SQL,
/// Rust and diffs. Every other name React knows is still understood and named
/// on the block's bar, and drawn plain; [registerNebaCodeLanguage] teaches the
/// block one, as `registerLanguage` does.
///
/// What comes out is lines of runs, as `tokenize` gives the React package:
/// the source is lexed as a whole, so a comment or a string that crosses a
/// line break is coloured on both lines, and then split at every newline.
///
/// The library talking to itself, except for the four public names
/// `neba_code_block.dart` exports.
library;

/// What a run of code is, by the colour a theme gives it.
///
/// Grouped by what a run is rather than by what a grammar calls it, as the
/// React stylesheet maps highlight.js's scopes onto the same slots: a keyword
/// and a literal are one colour, a function's name and a class's are one.
enum NebaCodeKind {
  /// Anything else: names, operators, punctuation, whitespace.
  plain,

  /// A comment, drawn in italics.
  comment,

  /// A keyword, a literal such as `true` or `null`, an operator a grammar
  /// names.
  keyword,

  /// A string, a character or a regular expression.
  string,

  /// A number, and a list's bullet.
  number,

  /// The name of a function, a class or a markup element.
  function,

  /// A type or a built-in.
  type,

  /// A variable, a parameter or an interpolation.
  variable,

  /// The angle brackets of a markup tag.
  tag,

  /// An attribute, a property or a key.
  attribute,

  /// A decorator, a directive, a document marker, punctuation a grammar names.
  meta,

  /// An added line in a diff.
  addition,

  /// A removed line in a diff.
  deletion,
}

/// One run of code in one colour.
class NebaCodeSpan {
  /// [text], coloured as [kind].
  const NebaCodeSpan(this.text, [this.kind = NebaCodeKind.plain]);

  /// The characters.
  final String text;

  /// What they are.
  final NebaCodeKind kind;

  @override
  bool operator ==(Object other) {
    return other is NebaCodeSpan && other.text == text && other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(text, kind);

  @override
  String toString() => 'NebaCodeSpan(${kind.name}, "$text")';
}

/// A language, as a function from the whole source to its runs, in order.
///
/// The runs may hold newlines; the block splits them into lines afterwards,
/// keeping each run's colour on both sides of a break.
typedef NebaCodeTokenizer = List<NebaCodeSpan> Function(String source);

final Map<String, NebaCodeTokenizer> _registered = <String, NebaCodeTokenizer>{};

/// Teaches every [NebaCodeBlock] built after it the language [name].
///
/// The counterpart of the React package's `registerLanguage`, which takes a
/// highlight.js grammar: here a language is a [NebaCodeTokenizer]. A name the
/// library already colours is replaced, and a registered name wins over an
/// alias spelled the same. Call it before the blocks are built; a block
/// already on screen keeps the colours it has.
///
/// ```dart
/// registerNebaCodeLanguage('ini', (String source) => <NebaCodeSpan>[
///   for (final String line in source.split('\n'))
///     NebaCodeSpan('$line\n', line.startsWith(';') ? NebaCodeKind.comment : NebaCodeKind.plain),
/// ]);
/// ```
void registerNebaCodeLanguage(String name, NebaCodeTokenizer tokenizer) {
  _registered[name.trim().toLowerCase()] = tokenizer;
}

/// Forgets every registered language. For tests.
void resetNebaCodeLanguages() {
  _registered.clear();
}

/// What a caller writes, against the name the language goes by: the React
/// package's table, so a `language` copied off a fenced block or a file
/// extension means the same thing in both.
const Map<String, String> _aliases = <String, String>{
  'c++': 'cpp',
  'cc': 'cpp',
  'cjs': 'javascript',
  'console': 'bash',
  'cs': 'csharp',
  'cts': 'typescript',
  'docker': 'dockerfile',
  'gql': 'graphql',
  'golang': 'go',
  'h': 'cpp',
  'hpp': 'cpp',
  'htm': 'xml',
  'html': 'xml',
  'js': 'javascript',
  'jsx': 'javascript',
  'kt': 'kotlin',
  'kts': 'kotlin',
  'md': 'markdown',
  'mdx': 'markdown',
  'mjs': 'javascript',
  'mm': 'objectivec',
  'mts': 'typescript',
  'mysql': 'sql',
  'node': 'javascript',
  'none': 'plaintext',
  'objc': 'objectivec',
  'plain': 'plaintext',
  'posh': 'powershell',
  'ps1': 'powershell',
  'psql': 'sql',
  'py': 'python',
  'rb': 'ruby',
  'rs': 'rust',
  'sh': 'bash',
  'svelte': 'xml',
  'svg': 'xml',
  'text': 'plaintext',
  'toml': 'ini',
  'ts': 'typescript',
  'tsx': 'typescript',
  'txt': 'plaintext',
  'vue': 'xml',
  'yml': 'yaml',
  'zsh': 'bash',
};

/// The name a caller's spelling of a language means, whether or not anything
/// here colours it, or `null` for no language at all.
String? nebaCodeLanguage(String? language) {
  final String key = language?.trim().toLowerCase() ?? '';

  if (key.isEmpty) {
    return null;
  }

  if (_registered.containsKey(key)) {
    return key;
  }

  return _aliases[key] ?? key;
}

final Map<String, NebaCodeTokenizer> _builtIn = <String, NebaCodeTokenizer>{
  'typescript': (String source) => _Script(source, typed: true).run(),
  'javascript': (String source) => _Script(source, typed: false).run(),
  'json': _json,
  'xml': (String source) => _Markup(source).run(),
  'css': _css,
  'bash': _shell,
  'shell': _shell,
  'powershell': _powershell,
  'python': _python,
  'yaml': _yaml,
  'sql': _sql,
  'rust': _rust,
  'diff': _diff,
  'plaintext': (String source) => <NebaCodeSpan>[NebaCodeSpan(source)],
};

/// Whether [name], as [nebaCodeLanguage] gives it, is a language the block
/// can colour.
bool nebaCodeColours(String name) => _registered.containsKey(name) || _builtIn.containsKey(name);

/// [source] in [name], as lines of runs, or `null` for a language nothing
/// here colours. An empty line is an empty list.
List<List<NebaCodeSpan>>? nebaHighlight(String source, String name) {
  final NebaCodeTokenizer? tokenizer = _registered[name] ?? _builtIn[name];

  if (tokenizer == null) {
    return null;
  }

  return nebaCodeLines(tokenizer(source));
}

/// [source] with no colour in it: what a block draws when it colours
/// nothing.
List<List<NebaCodeSpan>> nebaPlainLines(String source) {
  return <List<NebaCodeSpan>>[
    for (final String line in source.split('\n'))
      if (line.isEmpty) <NebaCodeSpan>[] else <NebaCodeSpan>[NebaCodeSpan(line)],
  ];
}

/// [spans] split at every newline, with a run that crosses one kept, in its
/// colour, on both of the lines it reaches, and runs of one colour beside
/// each other joined.
List<List<NebaCodeSpan>> nebaCodeLines(List<NebaCodeSpan> spans) {
  final List<List<NebaCodeSpan>> lines = <List<NebaCodeSpan>>[<NebaCodeSpan>[]];

  void add(String text, NebaCodeKind kind) {
    final List<NebaCodeSpan> line = lines.last;

    if (line.isNotEmpty && line.last.kind == kind) {
      line[line.length - 1] = NebaCodeSpan(line.last.text + text, kind);
    } else {
      line.add(NebaCodeSpan(text, kind));
    }
  }

  for (final NebaCodeSpan span in spans) {
    final List<String> parts = span.text.split('\n');

    for (int index = 0; index < parts.length; index++) {
      if (index > 0) {
        lines.add(<NebaCodeSpan>[]);
      }

      if (parts[index].isNotEmpty) {
        add(parts[index], span.kind);
      }
    }
  }

  return lines;
}

/* ---------------------------------------------------------------------------
 * The machinery
 * ------------------------------------------------------------------------- */

/// A rule: what it matches at the cursor, and what the match is. A rule with
/// no kind is classified by [_Lexer.word].
class _Rule {
  const _Rule(this.pattern, [this.kind]);

  final Pattern pattern;
  final NebaCodeKind? kind;
}

final RegExp _space = RegExp(r'\s+');
final RegExp _word = RegExp(r'[A-Za-z_$][\w$]*');
final RegExp _number = RegExp(
  r'(?:0[xX][\da-fA-F_]+|0[bB][01_]+|0[oO][0-7_]+|(?:\d[\d_]*(?:\.\d[\d_]*)?|\.\d[\d_]*)(?:[eE][+-]?\d+)?)[a-zA-Z\d]*',
);

/// Walks a source with an ordered list of rules: the first that matches at
/// the cursor takes the text, a word goes to [word], and anything else is one
/// plain character.
class _Lexer {
  _Lexer(this.source, this.rules, {this.word});

  final String source;
  final List<_Rule> rules;
  final NebaCodeKind Function(_Lexer lexer, String word, int end)? word;
  final List<NebaCodeSpan> out = <NebaCodeSpan>[];

  /// The last run that was not whitespace, for the rules that read context.
  NebaCodeSpan? previous;

  List<NebaCodeSpan> run([int from = 0]) {
    int at = from;

    while (at < source.length) {
      at = step(at);
    }

    return out;
  }

  int step(int at) {
    final Match? space = _space.matchAsPrefix(source, at);

    if (space != null) {
      emit(space[0]!, NebaCodeKind.plain);

      return space.end;
    }

    for (final _Rule rule in rules) {
      final Match? match = rule.pattern.matchAsPrefix(source, at);

      if (match != null && match.end > at) {
        emit(match[0]!, rule.kind ?? NebaCodeKind.plain);

        return match.end;
      }
    }

    final Match? name = _word.matchAsPrefix(source, at);

    if (name != null) {
      final NebaCodeKind Function(_Lexer lexer, String word, int end)? classify = word;

      emit(name[0]!, classify == null ? NebaCodeKind.plain : classify(this, name[0]!, name.end));

      return name.end;
    }

    if (at < source.length && _isDigit(source.codeUnitAt(at))) {
      final Match number = _number.matchAsPrefix(source, at)!;

      emit(number[0]!, NebaCodeKind.number);

      return number.end;
    }

    emit(source[at], NebaCodeKind.plain);

    return at + 1;
  }

  void emit(String text, NebaCodeKind kind) {
    final NebaCodeSpan span = NebaCodeSpan(text, kind);

    out.add(span);

    if (text.trim().isNotEmpty) {
      previous = span;
    } else if (text.contains('\n')) {
      // A new line starts afresh: what came before it is no context for a
      // command, an element or a keyword on this one.
      previous = null;
    }
  }

  /// The first character after [end] that is not a space or a tab, or an
  /// empty string at the end.
  String after(int end) {
    int at = end;

    while (at < source.length && (source[at] == ' ' || source[at] == '\t')) {
      at += 1;
    }

    return at < source.length ? source[at] : '';
  }

  /// The character before the word that ends at [end] and is [length] long.
  String before(int end, int length) {
    final int at = end - length - 1;

    return at >= 0 ? source[at] : '';
  }
}

bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;

bool _isCapitalised(String word) => RegExp(r'^[A-Z][a-z][A-Za-z\d]*$').hasMatch(word);

Set<String> _set(String words) => words.split(' ').toSet();

final RegExp _doubleQuoted = RegExp(r'"(?:\\.|[^"\\\n])*"?');
final RegExp _singleQuoted = RegExp(r"'(?:\\.|[^'\\\n])*'?");
final RegExp _blockComment = RegExp(r'/\*[\s\S]*?(?:\*/|$)');
final RegExp _lineComment = RegExp(r'//[^\n]*');
final RegExp _hashComment = RegExp(r'#[^\n]*');

/* ---------------------------------------------------------------------------
 * TypeScript and JavaScript, with JSX
 * ------------------------------------------------------------------------- */

final Set<String> _scriptKeywords = _set(
  'as async await break case catch class const continue debugger default delete do else enum '
  'export extends finally for from function get if implements import in instanceof interface '
  'let new of package private protected public return set static super switch throw try '
  'typeof var void while with yield',
);
final Set<String> _typeKeywords = _set(
  'abstract declare is keyof infer namespace module override readonly satisfies type unique',
);
final Set<String> _scriptLiterals = _set('true false null undefined NaN Infinity');
final Set<String> _scriptTypes = _set(
  'Object Function Boolean Symbol Math Date Number BigInt String RegExp Array Float32Array '
  'Float64Array Int8Array Uint8Array Int16Array Uint16Array Int32Array Uint32Array Map Set '
  'WeakMap WeakSet Promise Proxy Reflect JSON Intl ArrayBuffer DataView Error EvalError '
  'RangeError ReferenceError SyntaxError TypeError URIError',
);
final Set<String> _scriptBuiltIns = _set(
  'setInterval setTimeout clearInterval clearTimeout require exports eval isFinite isNaN '
  'parseFloat parseInt decodeURI decodeURIComponent encodeURI encodeURIComponent',
);
final Set<String> _scriptVariables = _set(
  'arguments this super console window document localStorage sessionStorage module global',
);
final Set<String> _tsTypes = _set(
  'any void number boolean string object never symbol bigint unknown',
);

/// Whether a `<` after [previous] opens a JSX element rather than comparing
/// or opening a type's arguments: it does after an operator, a bracket or a
/// keyword, and never after a name, a number or a closing bracket.
bool _opensElement(NebaCodeSpan? previous) {
  if (previous == null) {
    return true;
  }

  final String text = previous.text;

  if (previous.kind == NebaCodeKind.keyword) {
    return const <String>{'return', 'yield', 'await', 'default', 'case', 'else'}.contains(text);
  }

  if (previous.kind != NebaCodeKind.plain) {
    return false;
  }

  final String last = text[text.length - 1];

  return '([{,;:?=&|!>'.contains(last) || text == '=>';
}

class _Script {
  _Script(this.source, {required this.typed});

  final String source;
  final bool typed;

  late final _Lexer lexer = _Lexer(source, <_Rule>[
    _Rule(_lineComment, NebaCodeKind.comment),
    _Rule(_blockComment, NebaCodeKind.comment),
    _Rule(RegExp(r'`(?:\\[\s\S]|[^`\\])*`?'), NebaCodeKind.string),
    _Rule(_doubleQuoted, NebaCodeKind.string),
    _Rule(_singleQuoted, NebaCodeKind.string),
    _Rule(RegExp(r'@[A-Za-z_$][\w$.]*'), NebaCodeKind.meta),
    _Rule(RegExp(r'#[A-Za-z_$][\w$]*'), NebaCodeKind.attribute),
    _Rule(RegExp(r'=>')),
  ], word: _classify);

  NebaCodeKind _classify(_Lexer lexer, String word, int end) {
    final String previous = lexer.previous?.text ?? '';
    final bool member = lexer.before(end, word.length) == '.';

    if (!member) {
      if (_scriptKeywords.contains(word) || (typed && _typeKeywords.contains(word))) {
        return NebaCodeKind.keyword;
      }

      if (_scriptLiterals.contains(word)) {
        return NebaCodeKind.keyword;
      }

      if (_scriptVariables.contains(word)) {
        return NebaCodeKind.variable;
      }

      if (typed && _tsTypes.contains(word) && lexer.after(end) != '(') {
        return NebaCodeKind.type;
      }

      if (_scriptTypes.contains(word) || _scriptBuiltIns.contains(word)) {
        return NebaCodeKind.type;
      }
    }

    if (lexer.after(end) == '(' || previous == 'function') {
      return NebaCodeKind.function;
    }

    if (member) {
      return NebaCodeKind.attribute;
    }

    if (_isCapitalised(word) || previous == 'class' || previous == 'extends') {
      return NebaCodeKind.function;
    }

    return NebaCodeKind.plain;
  }

  List<NebaCodeSpan> run() {
    int at = 0;

    while (at < source.length) {
      if (source[at] == '<' && _opensElement(lexer.previous) && _elementStart(at)) {
        at = _Markup(source, lexer: lexer, script: this).element(at);
      } else {
        at = lexer.step(at);
      }
    }

    return lexer.out;
  }

  bool _elementStart(int at) {
    return RegExp(r'<(?:[A-Za-z]|>|/)').matchAsPrefix(source, at) != null;
  }

  /// A `{…}` inside an element, as script, up to its matching brace; returns
  /// where it ends.
  int expression(int at) {
    lexer.emit('{', NebaCodeKind.plain);

    int depth = 1;
    int cursor = at + 1;

    while (cursor < source.length) {
      final String char = source[cursor];

      if (char == '{') {
        depth += 1;
      } else if (char == '}') {
        depth -= 1;

        if (depth == 0) {
          lexer.emit('}', NebaCodeKind.plain);

          return cursor + 1;
        }
      } else if (char == '<' && _opensElement(lexer.previous) && _elementStart(cursor)) {
        cursor = _Markup(source, lexer: lexer, script: this).element(cursor);

        continue;
      }

      if (char == '{' || char == '}') {
        lexer.emit(char, NebaCodeKind.plain);
        cursor += 1;
      } else {
        cursor = lexer.step(cursor);
      }
    }

    return cursor;
  }
}

/* ---------------------------------------------------------------------------
 * Markup: HTML, XML, and the elements inside a JSX expression
 * ------------------------------------------------------------------------- */

class _Markup {
  _Markup(this.source, {_Lexer? lexer, this.script})
    : lexer = lexer ?? _Lexer(source, const <_Rule>[]);

  final String source;
  final _Lexer lexer;

  /// The script an element sits in, which reads its `{…}`; markup on its own
  /// has none.
  final _Script? script;

  static final RegExp _comment = RegExp(r'<!--[\s\S]*?(?:-->|$)');
  static final RegExp _declaration = RegExp(r'<![^>]*>?|<\?[\s\S]*?(?:\?>|$)');
  static final RegExp _name = RegExp(r'[A-Za-z][\w.:-]*');
  static final RegExp _attribute = RegExp(r'[A-Za-z_:@][\w.:-]*');
  static final RegExp _entity = RegExp(r'&(?:#\d+|#x[\da-fA-F]+|\w+);');
  static final RegExp _text = RegExp(r'[^<&{]+');
  static final RegExp _markupText = RegExp(r'[^<&]+');

  List<NebaCodeSpan> run() {
    int at = 0;

    while (at < source.length) {
      at = content(at);
    }

    return lexer.out;
  }

  /// One piece of what is between tags.
  int content(int at) {
    for (final (RegExp pattern, NebaCodeKind kind) in <(RegExp, NebaCodeKind)>[
      (_comment, NebaCodeKind.comment),
      (_declaration, NebaCodeKind.meta),
      (_entity, NebaCodeKind.number),
    ]) {
      final Match? match = pattern.matchAsPrefix(source, at);

      if (match != null) {
        lexer.emit(match[0]!, kind);

        return match.end;
      }
    }

    if (source[at] == '<' && RegExp(r'</?[A-Za-z>]').matchAsPrefix(source, at) != null) {
      return element(at);
    }

    final Match? text = (script == null ? _markupText : _text).matchAsPrefix(source, at);

    if (text != null) {
      lexer.emit(text[0]!, NebaCodeKind.plain);

      return text.end;
    }

    lexer.emit(source[at], NebaCodeKind.plain);

    return at + 1;
  }

  /// A tag, and for an opening tag inside a script, everything up to the tag
  /// that closes it; returns where it ends.
  int element(int at) {
    final int afterTag = tag(at);
    final _Script? script = this.script;

    if (script == null) {
      return afterTag;
    }

    final String written = source.substring(at, afterTag);

    if (written.startsWith('</') || written.endsWith('/>')) {
      return afterTag;
    }

    // The children, until the tag that closes this one.
    int cursor = afterTag;

    while (cursor < source.length) {
      if (source.startsWith('</', cursor)) {
        return tag(cursor);
      }

      if (source[cursor] == '{') {
        cursor = script.expression(cursor);
      } else {
        cursor = content(cursor);
      }
    }

    return cursor;
  }

  /// One tag, from its `<` to its `>`.
  int tag(int at) {
    int cursor = at + (source.startsWith('</', at) ? 2 : 1);

    lexer.emit(source.substring(at, cursor), NebaCodeKind.tag);

    final Match? name = _name.matchAsPrefix(source, cursor);

    if (name != null) {
      lexer.emit(name[0]!, NebaCodeKind.function);
      cursor = name.end;
    }

    while (cursor < source.length) {
      final Match? space = _space.matchAsPrefix(source, cursor);

      if (space != null) {
        lexer.emit(space[0]!, NebaCodeKind.plain);
        cursor = space.end;

        continue;
      }

      if (source.startsWith('/>', cursor)) {
        lexer.emit('/>', NebaCodeKind.tag);

        return cursor + 2;
      }

      if (source[cursor] == '>') {
        lexer.emit('>', NebaCodeKind.tag);

        return cursor + 1;
      }

      final Match? attribute = _attribute.matchAsPrefix(source, cursor);

      if (attribute != null) {
        lexer.emit(attribute[0]!, NebaCodeKind.attribute);
        cursor = attribute.end;

        continue;
      }

      final Match? string =
          _doubleQuoted.matchAsPrefix(source, cursor) ??
          _singleQuoted.matchAsPrefix(source, cursor);

      if (string != null) {
        lexer.emit(string[0]!, NebaCodeKind.string);
        cursor = string.end;

        continue;
      }

      final _Script? script = this.script;

      if (source[cursor] == '{' && script != null) {
        cursor = script.expression(cursor);

        continue;
      }

      lexer.emit(source[cursor], NebaCodeKind.plain);
      cursor += 1;
    }

    return cursor;
  }
}

/* ---------------------------------------------------------------------------
 * JSON
 * ------------------------------------------------------------------------- */

List<NebaCodeSpan> _json(String source) {
  final _Lexer lexer = _Lexer(
    source,
    <_Rule>[
      _Rule(_lineComment, NebaCodeKind.comment),
      _Rule(_blockComment, NebaCodeKind.comment),
      _Rule(RegExp(r'"(?:\\.|[^"\\\n])*"(?=\s*:)'), NebaCodeKind.attribute),
      _Rule(_doubleQuoted, NebaCodeKind.string),
      _Rule(RegExp(r'[{}[\],:]'), NebaCodeKind.meta),
    ],
    word: (_Lexer lexer, String word, int end) {
      return _set('true false null').contains(word) ? NebaCodeKind.keyword : NebaCodeKind.plain;
    },
  );

  int at = 0;

  while (at < source.length) {
    final Match? number = RegExp(r'-?\d[\d.eE+-]*').matchAsPrefix(source, at);

    if (number != null) {
      lexer.emit(number[0]!, NebaCodeKind.number);
      at = number.end;
    } else {
      at = lexer.step(at);
    }
  }

  return lexer.out;
}

/* ---------------------------------------------------------------------------
 * CSS
 * ------------------------------------------------------------------------- */

List<NebaCodeSpan> _css(String source) {
  final List<NebaCodeSpan> out = <NebaCodeSpan>[];
  int depth = 0;
  int at = 0;

  final List<(RegExp, NebaCodeKind)> shared = <(RegExp, NebaCodeKind)>[
    (_blockComment, NebaCodeKind.comment),
    (_doubleQuoted, NebaCodeKind.string),
    (_singleQuoted, NebaCodeKind.string),
    (RegExp(r'@[\w-]+'), NebaCodeKind.keyword),
  ];
  final List<(RegExp, NebaCodeKind)> selector = <(RegExp, NebaCodeKind)>[
    (RegExp(r'[.#][\w-]+'), NebaCodeKind.function),
    (RegExp(r'\[[^\]\n]*\]?'), NebaCodeKind.attribute),
    (RegExp(r'::?[\w-]+'), NebaCodeKind.attribute),
    (RegExp(r'[a-zA-Z][\w-]*'), NebaCodeKind.keyword),
  ];
  final List<(RegExp, NebaCodeKind)> declaration = <(RegExp, NebaCodeKind)>[
    (RegExp(r'-?-?[a-zA-Z][\w-]*(?=\s*:)'), NebaCodeKind.attribute),
    (RegExp(r'#[\da-fA-F]{3,8}\b'), NebaCodeKind.number),
    (RegExp(r'-?(?:\d+\.?\d*|\.\d+)(?:%|[a-zA-Z]+)?'), NebaCodeKind.number),
    (RegExp(r'[a-zA-Z-][\w-]*(?=\()'), NebaCodeKind.type),
    (RegExp(r'!important'), NebaCodeKind.keyword),
    (RegExp(r'[a-zA-Z-][\w-]*'), NebaCodeKind.plain),
  ];

  outer:
  while (at < source.length) {
    for (final (RegExp pattern, NebaCodeKind kind) in <(RegExp, NebaCodeKind)>[
      ...shared,
      ...(depth == 0 ? selector : declaration),
    ]) {
      final Match? match = pattern.matchAsPrefix(source, at);

      if (match != null && match.end > at) {
        out.add(NebaCodeSpan(match[0]!, kind));
        at = match.end;

        continue outer;
      }
    }

    final String char = source[at];

    if (char == '{') {
      depth += 1;
    } else if (char == '}') {
      depth = depth > 0 ? depth - 1 : 0;
    }

    out.add(NebaCodeSpan(char));
    at += 1;
  }

  return out;
}

/* ---------------------------------------------------------------------------
 * Shells
 * ------------------------------------------------------------------------- */

final Set<String> _shellKeywords = _set(
  'if then else elif fi for while until in do done case esac function select time return break '
  'continue',
);
final Set<String> _shellBuiltIns = _set(
  'alias bg bind builtin caller cd command declare dirs disown echo enable eval exec exit export '
  'false fc fg getopts hash help history jobs kill let local logout mapfile popd printf pushd '
  'pwd read readonly set shift shopt source suspend test times trap true type typeset ulimit '
  'umask unalias unset wait',
);
final RegExp _shellVariable = RegExp(r'\$(?:\{[^}\n]*\}?|[A-Za-z_]\w*|[\d@*#?$!-])');

List<NebaCodeSpan> _shell(String source) {
  final _Lexer lexer = _Lexer(source, <_Rule>[
    _Rule(RegExp(r"'[^']*'?"), NebaCodeKind.string),
    _Rule(_shellVariable, NebaCodeKind.variable),
    // Flags, paths and numbers in an argument are plain, as highlight.js
    // leaves them.
    _Rule(RegExp(r'[\w./:@%+,=-]+')),
  ], word: (_Lexer lexer, String word, int end) => NebaCodeKind.plain);

  int at = 0;

  while (at < source.length) {
    final String char = source[at];

    // A comment starts a word, never the middle of one.
    if (char == '#' && (at == 0 || RegExp(r'\s').hasMatch(source[at - 1]))) {
      final Match comment = _hashComment.matchAsPrefix(source, at)!;

      lexer.emit(
        comment[0]!,
        at == 0 && comment[0]!.startsWith('#!') ? NebaCodeKind.meta : NebaCodeKind.comment,
      );
      at = comment.end;

      continue;
    }

    // A double-quoted string, with what it interpolates picked out of it.
    if (char == '"') {
      at = _interpolated(source, at, lexer);

      continue;
    }

    final Match? word = RegExp(r'[A-Za-z_][\w-]*').matchAsPrefix(source, at);

    if (word != null && (at == 0 || !RegExp(r'[\w./-]').hasMatch(source[at - 1]))) {
      final String text = word[0]!;
      final bool command = _commandPosition(lexer.previous);

      lexer.emit(
        text,
        _shellKeywords.contains(text) && (command || text == 'in')
            ? NebaCodeKind.keyword
            : command && _shellBuiltIns.contains(text)
            ? NebaCodeKind.type
            : NebaCodeKind.plain,
      );
      at = word.end;

      continue;
    }

    at = lexer.step(at);
  }

  return lexer.out;
}

/// Whether a word after [previous] is the name of a command: at the start of
/// a line, or after an operator that starts another command.
bool _commandPosition(NebaCodeSpan? previous) {
  if (previous == null) {
    return true;
  }

  return const <String>{';', '|', '&', '(', '{', '`'}.contains(previous.text) ||
      previous.text == '&&' ||
      previous.text == '||' ||
      previous.kind == NebaCodeKind.keyword;
}

int _interpolated(String source, int at, _Lexer lexer) {
  int cursor = at + 1;
  final StringBuffer run = StringBuffer('"');

  void flush() {
    if (run.isNotEmpty) {
      lexer.emit(run.toString(), NebaCodeKind.string);
      run.clear();
    }
  }

  while (cursor < source.length) {
    final String char = source[cursor];

    if (char == r'\' && cursor + 1 < source.length) {
      run.write(source.substring(cursor, cursor + 2));
      cursor += 2;

      continue;
    }

    if (char == r'$') {
      final Match? variable = _shellVariable.matchAsPrefix(source, cursor);

      if (variable != null) {
        flush();
        lexer.emit(variable[0]!, NebaCodeKind.variable);
        cursor = variable.end;

        continue;
      }
    }

    run.write(char);
    cursor += 1;

    if (char == '"') {
      break;
    }
  }

  flush();

  return cursor;
}

final Set<String> _powershellKeywords = _set(
  'begin break catch class continue data define do dynamicparam else elseif end exit filter '
  'finally for foreach from function if in param process return switch throw trap try until '
  'using var while',
);
final Set<String> _powershellAliases = _set(
  'cd chdir cls copy cp del dir echo erase gc gci gi gl gm gp gps gsv gu gv iex ii ipmo ise '
  'kill ls md measure mi mkdir mount move mv ni nv popd ps pushd pwd r rd ren rm rmdir sc set '
  'sl sleep sort sp start type where write',
);

List<NebaCodeSpan> _powershell(String source) {
  final _Lexer lexer = _Lexer(
    source,
    <_Rule>[
      _Rule(RegExp(r'<#[\s\S]*?(?:#>|$)'), NebaCodeKind.comment),
      _Rule(_hashComment, NebaCodeKind.comment),
      _Rule(_doubleQuoted, NebaCodeKind.string),
      _Rule(_singleQuoted, NebaCodeKind.string),
      _Rule(RegExp(r'\$(?:\{[^}\n]*\}|[\w:]+)'), NebaCodeKind.variable),
      _Rule(RegExp(r'\b[A-Z][a-z]+-[A-Z][A-Za-z]+\b'), NebaCodeKind.type),
      _Rule(RegExp(r'[\w.:\\/]*[:\\/.][\w.:\\/-]*'), null),
    ],
    word: (_Lexer lexer, String word, int end) {
      final String key = word.toLowerCase();

      if (_powershellKeywords.contains(key)) {
        return NebaCodeKind.keyword;
      }

      return _commandPosition(lexer.previous) && _powershellAliases.contains(key)
          ? NebaCodeKind.type
          : NebaCodeKind.plain;
    },
  );

  return lexer.run();
}

/* ---------------------------------------------------------------------------
 * Python
 * ------------------------------------------------------------------------- */

final Set<String> _pythonKeywords = _set(
  'and as assert async await break case class continue def del elif else except finally for '
  'from global if import in is lambda match nonlocal not or pass raise return try while with '
  'yield',
);
final Set<String> _pythonLiterals = _set('True False None');
final Set<String> _pythonBuiltIns = _set(
  'abs all any ascii bin bool breakpoint bytearray bytes callable chr classmethod compile '
  'complex delattr dict dir divmod enumerate eval exec filter float format frozenset getattr '
  'globals hasattr hash help hex id input int isinstance issubclass iter len list locals map '
  'max memoryview min next object oct open ord pow print property range repr reversed round '
  'set setattr slice sorted staticmethod str sum super tuple type vars zip',
);

List<NebaCodeSpan> _python(String source) {
  final _Lexer lexer = _Lexer(
    source,
    <_Rule>[
      _Rule(_hashComment, NebaCodeKind.comment),
      _Rule(RegExp(r'[rRbBuUfF]{0,2}"""[\s\S]*?(?:"""|$)'), NebaCodeKind.string),
      _Rule(RegExp(r"[rRbBuUfF]{0,2}'''[\s\S]*?(?:'''|$)"), NebaCodeKind.string),
      _Rule(
        RegExp(
          r'[rRbBuUfF]{1,2}(?="|'
          "')",
        ),
        NebaCodeKind.string,
      ),
      _Rule(_doubleQuoted, NebaCodeKind.string),
      _Rule(_singleQuoted, NebaCodeKind.string),
      _Rule(RegExp(r'@[A-Za-z_][\w.]*'), NebaCodeKind.meta),
    ],
    word: (_Lexer lexer, String word, int end) {
      final String previous = lexer.previous?.text ?? '';

      if (_pythonKeywords.contains(word) || _pythonLiterals.contains(word)) {
        return NebaCodeKind.keyword;
      }

      if (previous == 'def' || previous == 'class') {
        return NebaCodeKind.function;
      }

      if (word == 'self' || word == 'cls') {
        return NebaCodeKind.variable;
      }

      if (_pythonBuiltIns.contains(word) && lexer.before(end, word.length) != '.') {
        return NebaCodeKind.type;
      }

      return NebaCodeKind.plain;
    },
  );

  return lexer.run();
}

/* ---------------------------------------------------------------------------
 * YAML
 * ------------------------------------------------------------------------- */

List<NebaCodeSpan> _yaml(String source) {
  final List<NebaCodeSpan> out = <NebaCodeSpan>[];
  final RegExp key = RegExp(
    r"""(?:[^\s#:'"\[\]{},-][^\n#:]*?|"[^"\n]*"|'[^'\n]*')(?=[ \t]*:(?:\s|$))""",
    multiLine: true,
  );
  // A value runs to the end of its line, a comment, or the end of the flow
  // collection it is in.
  const String until = r'(?=[ \t]*(?:$|[ \t]#|,|\]|\}))';
  final RegExp literal = RegExp(
    '(?:true|false|yes|no|null|~)$until',
    multiLine: true,
    caseSensitive: false,
  );
  final RegExp number = RegExp(
    r'[-+]?(?:\d[\d_]*(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?' + until,
    multiLine: true,
  );
  final RegExp scalar = RegExp(r'[^\s#,\[\]{}][^\n#,\[\]{}]*?' + until, multiLine: true);
  final RegExp space = RegExp(r'[ \t]+');
  int at = 0;
  // Whether nothing but indentation, or a bullet, is before the cursor on its
  // line: where a key can be.
  bool keyed = true;

  void add(String text, [NebaCodeKind kind = NebaCodeKind.plain]) {
    out.add(NebaCodeSpan(text, kind));
  }

  while (at < source.length) {
    final String char = source[at];

    if (char == '\n') {
      add('\n');
      at += 1;
      keyed = true;

      continue;
    }

    final Match? gap = space.matchAsPrefix(source, at);

    if (gap != null) {
      add(gap[0]!);
      at = gap.end;

      continue;
    }

    if (char == '#') {
      final Match comment = _hashComment.matchAsPrefix(source, at)!;

      add(comment[0]!, NebaCodeKind.comment);
      at = comment.end;

      continue;
    }

    if (keyed && (source.startsWith('---', at) || source.startsWith('...', at))) {
      add(source.substring(at, at + 3), NebaCodeKind.meta);
      at += 3;
      keyed = false;

      continue;
    }

    if (keyed && char == '-' && (at + 1 == source.length || ' \t\n'.contains(source[at + 1]))) {
      add('-', NebaCodeKind.number);
      at += 1;

      continue;
    }

    if (keyed) {
      keyed = false;

      final Match? name = key.matchAsPrefix(source, at);

      if (name != null) {
        add(name[0]!, NebaCodeKind.attribute);
        at = name.end;

        continue;
      }
    }

    if (':,[]{}|>&*!?'.contains(char)) {
      add(char);
      at += 1;

      continue;
    }

    final Match? quoted =
        _doubleQuoted.matchAsPrefix(source, at) ?? _singleQuoted.matchAsPrefix(source, at);

    if (quoted != null) {
      add(quoted[0]!, NebaCodeKind.string);
      at = quoted.end;

      continue;
    }

    final Match? value =
        literal.matchAsPrefix(source, at) ??
        number.matchAsPrefix(source, at) ??
        scalar.matchAsPrefix(source, at);

    if (value != null && value.end > at) {
      final NebaCodeKind kind = identical(value.pattern, literal)
          ? NebaCodeKind.keyword
          : identical(value.pattern, number)
          ? NebaCodeKind.number
          : NebaCodeKind.string;

      add(value[0]!, kind);
      at = value.end;

      continue;
    }

    add(char);
    at += 1;
  }

  return out;
}

/* ---------------------------------------------------------------------------
 * SQL
 * ------------------------------------------------------------------------- */

final Set<String> _sqlKeywords = _set(
  'add all alter and any as asc begin between by case cascade check column commit constraint '
  'create cross current_date current_time current_timestamp database default delete desc '
  'distinct drop else end except exists false fetch for foreign from full grant group having '
  'if in index inner insert intersect into is join key left like limit natural not null offset '
  'on or order outer over partition primary references replace returning revoke right rollback '
  'row rows select set table then to top true truncate union unique update using values view '
  'when where window with',
);
final Set<String> _sqlFunctions = _set(
  'abs avg cast ceil coalesce concat count date dense_rank extract first_value floor greatest '
  'lag last_value lead least length lower max min now nullif rank round row_number substring '
  'sum trim upper',
);

List<NebaCodeSpan> _sql(String source) {
  final _Lexer lexer = _Lexer(
    source,
    <_Rule>[
      _Rule(RegExp(r'--[^\n]*'), NebaCodeKind.comment),
      _Rule(_blockComment, NebaCodeKind.comment),
      _Rule(RegExp(r"'(?:''|[^'])*'?"), NebaCodeKind.string),
      _Rule(_doubleQuoted, NebaCodeKind.string),
      _Rule(RegExp(r'[-+*/=%^~]|<>|!=|<=|>=|<|>|\|\|'), NebaCodeKind.keyword),
    ],
    word: (_Lexer lexer, String word, int end) {
      final String key = word.toLowerCase();

      if (lexer.before(end, word.length) == '.') {
        return NebaCodeKind.plain;
      }

      if (_sqlFunctions.contains(key) && lexer.after(end) == '(') {
        return NebaCodeKind.type;
      }

      return _sqlKeywords.contains(key) ? NebaCodeKind.keyword : NebaCodeKind.plain;
    },
  );

  return lexer.run();
}

/* ---------------------------------------------------------------------------
 * Rust
 * ------------------------------------------------------------------------- */

final Set<String> _rustKeywords = _set(
  'abstract as async await become box break const continue crate do dyn else enum extern false '
  'final fn for if impl in let loop macro match mod move mut override priv pub ref return self '
  'Self static struct super trait true try type typeof union unsafe unsized use virtual where '
  'while yield',
);
final Set<String> _rustTypes = _set(
  'i8 i16 i32 i64 i128 isize u8 u16 u32 u64 u128 usize f32 f64 str char bool Box Option Result '
  'String Vec Some None Ok Err',
);

List<NebaCodeSpan> _rust(String source) {
  final _Lexer lexer = _Lexer(
    source,
    <_Rule>[
      _Rule(_lineComment, NebaCodeKind.comment),
      _Rule(_blockComment, NebaCodeKind.comment),
      _Rule(RegExp(r'b?r(#*)"[\s\S]*?(?:"\1|$)'), NebaCodeKind.string),
      _Rule(RegExp(r'b?"(?:\\[\s\S]|[^"\\])*"?'), NebaCodeKind.string),
      _Rule(RegExp(r"b?'(?:\\.|[^\\'\n])'"), NebaCodeKind.string),
      _Rule(RegExp(r"'[A-Za-z_]\w*"), NebaCodeKind.meta),
      _Rule(RegExp(r'#!?\[[^\]\n]*\]?'), NebaCodeKind.meta),
      _Rule(RegExp(r'[A-Za-z_]\w*!(?=\s*[(\[{])'), NebaCodeKind.function),
    ],
    word: (_Lexer lexer, String word, int end) {
      final String previous = lexer.previous?.text ?? '';

      if (_rustKeywords.contains(word)) {
        return NebaCodeKind.keyword;
      }

      if (_rustTypes.contains(word)) {
        return NebaCodeKind.type;
      }

      if (previous == 'fn' || lexer.after(end) == '(') {
        return NebaCodeKind.function;
      }

      return RegExp(r'^[A-Z]').hasMatch(word) ? NebaCodeKind.type : NebaCodeKind.plain;
    },
  );

  return lexer.run();
}

/* ---------------------------------------------------------------------------
 * Diffs
 * ------------------------------------------------------------------------- */

List<NebaCodeSpan> _diff(String source) {
  return <NebaCodeSpan>[
    for (final (int index, String line) in source.split('\n').indexed) ...<NebaCodeSpan>[
      if (index > 0) const NebaCodeSpan('\n'),
      NebaCodeSpan(
        line,
        line.startsWith('+++') || line.startsWith('---') || line.startsWith('@@')
            ? NebaCodeKind.meta
            : line.startsWith('diff ') || line.startsWith('index ')
            ? NebaCodeKind.comment
            : line.startsWith('+') || line.startsWith('>')
            ? NebaCodeKind.addition
            : line.startsWith('-') || line.startsWith('<')
            ? NebaCodeKind.deletion
            : NebaCodeKind.plain,
      ),
    ],
  ];
}
