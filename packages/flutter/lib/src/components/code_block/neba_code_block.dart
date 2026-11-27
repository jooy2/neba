/// `NebaCodeBlock`, a viewer for one line of code or a thousand, and
/// `NebaCodeTheme`, the palette it wears.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/visually_hidden/neba_visually_hidden.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/highlight.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/scroll_keys.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/highlight.dart'
    show NebaCodeKind, NebaCodeSpan, NebaCodeTokenizer, registerNebaCodeLanguage;

enum _Source { light, dark, page, mono, fixed }

/// The palette a [NebaCodeBlock] wears.
///
/// Four are the library's own. [dark] is the default, and [light] is its
/// counterpart: neither follows the page, because code is read against a
/// ground chosen for code. [auto] follows the theme the block is in, and
/// [mono] has no hue at all, carrying the structure in weight and muting.
/// Eight more are ports kept at their published values. A theme of the
/// caller's own is a [NebaCodeTheme] made from a [NebaCodePalette]; the muted
/// text, the hairline, the hover tint and the two a marked line takes are
/// mixed from its `background` and `foreground`.
@immutable
class NebaCodeTheme {
  /// A theme of the caller's own, in [palette]'s colours.
  const NebaCodeTheme(NebaCodePalette palette, {this.name = 'custom'})
    : _palette = palette,
      _source = _Source.fixed;

  const NebaCodeTheme._(this.name, this._source, [this._palette]);

  /// The library's dark palette, whatever the page's theme. The default.
  static const NebaCodeTheme dark = NebaCodeTheme._('dark', _Source.dark);

  /// The library's light palette, whatever the page's theme.
  static const NebaCodeTheme light = NebaCodeTheme._('light', _Source.light);

  /// The light or the dark palette, by the theme the block is in.
  static const NebaCodeTheme auto = NebaCodeTheme._('auto', _Source.page);

  /// No hue at all: the page's own ink and muted ink, with keywords, names,
  /// tags and types set in a heavier weight.
  static const NebaCodeTheme mono = NebaCodeTheme._('mono', _Source.mono);

  /// One Dark.
  static const NebaCodeTheme oneDark = NebaCodeTheme._(
    'one-dark',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFF282C34),
      foreground: Color(0xFFABB2BF),
      comment: Color(0xFF5C6370),
      keyword: Color(0xFFC678DD),
      string: Color(0xFF98C379),
      number: Color(0xFFD19A66),
      function: Color(0xFF61AFEF),
      type: Color(0xFFE5C07B),
      variable: Color(0xFFE06C75),
      tag: Color(0xFFE06C75),
      attribute: Color(0xFFD19A66),
      meta: Color(0xFF56B6C2),
      addition: Color(0xFF98C379),
      deletion: Color(0xFFE06C75),
    ),
  );

  /// Dracula.
  static const NebaCodeTheme dracula = NebaCodeTheme._(
    'dracula',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFF282A36),
      foreground: Color(0xFFF8F8F2),
      comment: Color(0xFF6272A4),
      keyword: Color(0xFFFF79C6),
      string: Color(0xFFF1FA8C),
      number: Color(0xFFBD93F9),
      function: Color(0xFF50FA7B),
      type: Color(0xFF8BE9FD),
      variable: Color(0xFFF8F8F2),
      tag: Color(0xFFFF79C6),
      attribute: Color(0xFF50FA7B),
      meta: Color(0xFF6272A4),
      addition: Color(0xFF50FA7B),
      deletion: Color(0xFFFF5555),
    ),
  );

  /// Monokai.
  static const NebaCodeTheme monokai = NebaCodeTheme._(
    'monokai',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFF272822),
      foreground: Color(0xFFF8F8F2),
      comment: Color(0xFF75715E),
      keyword: Color(0xFFF92672),
      string: Color(0xFFE6DB74),
      number: Color(0xFFAE81FF),
      function: Color(0xFFA6E22E),
      type: Color(0xFF66D9EF),
      variable: Color(0xFFF8F8F2),
      tag: Color(0xFFF92672),
      attribute: Color(0xFFA6E22E),
      meta: Color(0xFF75715E),
      addition: Color(0xFFA6E22E),
      deletion: Color(0xFFF92672),
    ),
  );

  /// Nord.
  static const NebaCodeTheme nord = NebaCodeTheme._(
    'nord',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFF2E3440),
      foreground: Color(0xFFD8DEE9),
      comment: Color(0xFF616E88),
      keyword: Color(0xFF81A1C1),
      string: Color(0xFFA3BE8C),
      number: Color(0xFFB48EAD),
      function: Color(0xFF88C0D0),
      type: Color(0xFF8FBCBB),
      variable: Color(0xFFD8DEE9),
      tag: Color(0xFF81A1C1),
      attribute: Color(0xFF8FBCBB),
      meta: Color(0xFF5E81AC),
      addition: Color(0xFFA3BE8C),
      deletion: Color(0xFFBF616A),
    ),
  );

  /// Night Owl.
  static const NebaCodeTheme nightOwl = NebaCodeTheme._(
    'night-owl',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFF011627),
      foreground: Color(0xFFD6DEEB),
      comment: Color(0xFF637777),
      keyword: Color(0xFFC792EA),
      string: Color(0xFFECC48D),
      number: Color(0xFFF78C6C),
      function: Color(0xFF82AAFF),
      type: Color(0xFFFFCB8B),
      variable: Color(0xFFADDB67),
      tag: Color(0xFF7FDBCA),
      attribute: Color(0xFFADDB67),
      meta: Color(0xFF82AAFF),
      addition: Color(0xFFADDB67),
      deletion: Color(0xFFEF5350),
    ),
  );

  /// Gruvbox.
  static const NebaCodeTheme gruvbox = NebaCodeTheme._(
    'gruvbox',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFF282828),
      foreground: Color(0xFFEBDBB2),
      comment: Color(0xFF928374),
      keyword: Color(0xFFFB4934),
      string: Color(0xFFB8BB26),
      number: Color(0xFFD3869B),
      function: Color(0xFFB8BB26),
      type: Color(0xFFFABD2F),
      variable: Color(0xFF83A598),
      tag: Color(0xFF8EC07C),
      attribute: Color(0xFFFABD2F),
      meta: Color(0xFF928374),
      addition: Color(0xFFB8BB26),
      deletion: Color(0xFFFB4934),
    ),
  );

  /// GitHub's light palette.
  static const NebaCodeTheme github = NebaCodeTheme._(
    'github',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFFFFFFFF),
      foreground: Color(0xFF24292F),
      comment: Color(0xFF6E7781),
      keyword: Color(0xFFCF222E),
      string: Color(0xFF0A3069),
      number: Color(0xFF0550AE),
      function: Color(0xFF8250DF),
      type: Color(0xFF953800),
      variable: Color(0xFF953800),
      tag: Color(0xFF116329),
      attribute: Color(0xFF0550AE),
      meta: Color(0xFF6E7781),
      addition: Color(0xFF116329),
      deletion: Color(0xFF82071E),
    ),
  );

  /// Solarized Light.
  static const NebaCodeTheme solarizedLight = NebaCodeTheme._(
    'solarized-light',
    _Source.fixed,
    NebaCodePalette(
      background: Color(0xFFFDF6E3),
      foreground: Color(0xFF657B83),
      comment: Color(0xFF93A1A1),
      keyword: Color(0xFF859900),
      string: Color(0xFF2AA198),
      number: Color(0xFFD33682),
      function: Color(0xFF268BD2),
      type: Color(0xFFB58900),
      variable: Color(0xFF268BD2),
      tag: Color(0xFF268BD2),
      attribute: Color(0xFFB58900),
      meta: Color(0xFFCB4B16),
      addition: Color(0xFF859900),
      deletion: Color(0xFFDC322F),
    ),
  );

  /// Every theme the library has, the four of its own first.
  static const List<NebaCodeTheme> values = <NebaCodeTheme>[
    dark,
    light,
    auto,
    mono,
    oneDark,
    dracula,
    monokai,
    nord,
    nightOwl,
    gruvbox,
    github,
    solarizedLight,
  ];

  /// What the theme is called: `dracula`, `one-dark`, the React package's
  /// `theme` string.
  final String name;

  final _Source _source;
  final NebaCodePalette? _palette;

  /// Whether keywords, names, tags and types are set heavier, which is how
  /// [mono] tells them apart without a hue.
  bool get weighted => _source == _Source.mono;

  /// The colours, in the theme [tokens] describe: [auto] and [mono] read
  /// them, and every other theme is the same whatever they say.
  NebaCodePalette paletteOf(NebaTokens tokens) {
    switch (_source) {
      case _Source.light:
        return NebaTokens.light().code;
      case _Source.dark:
        return NebaTokens.dark().code;
      case _Source.page:
        return tokens.code;
      case _Source.mono:
        return NebaCodePalette(
          background: mixOklab(tokens.fg, 0.04, tokens.surface),
          foreground: tokens.fg,
          comment: tokens.mutedFg,
          keyword: tokens.fg,
          string: tokens.mutedFg,
          number: tokens.mutedFg,
          function: tokens.fg,
          type: tokens.fg,
          variable: tokens.fg,
          tag: tokens.fg,
          attribute: tokens.mutedFg,
          meta: tokens.mutedFg,
          addition: tokens.fg,
          deletion: tokens.mutedFg,
        );
      case _Source.fixed:
        return _palette!;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is NebaCodeTheme &&
        other.name == name &&
        other._source == _source &&
        other._palette == _palette;
  }

  @override
  int get hashCode => Object.hash(name, _source, _palette);
}

/// A viewer for one line of code or a thousand.
///
/// Everything it draws around the code is optional and off one argument
/// each, so the same widget is a bare snippet inside a paragraph and the full
/// transcript at the top of a page: the bar with a [title], the language and
/// a copy button; [lineNumbers]; a shell [prompt]; marked lines.
///
/// The code is coloured by a lexer of the library's own for the languages
/// the documentation shows, and drawn plain for any other, which
/// [registerNebaCodeLanguage] can teach it. A block that is wider or taller
/// than its box scrolls inside it, and is then a named region in the focus
/// order that the arrow keys scroll. The code can be selected, Ctrl or ⌘ + A
/// in the focused block selects the code alone, and neither the prompts nor
/// the numbers are ever part of a selection or of what the copy button
/// copies.
///
/// It takes the width it is given, as a paragraph does.
///
/// ```dart
/// const NebaCodeBlock(code: 'npm install neba', language: 'bash')
/// ```
class NebaCodeBlock extends StatefulWidget {
  /// A block that shows [code].
  const NebaCodeBlock({
    required this.code,
    this.language,
    this.theme,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.highlight = true,
    this.toolbar = true,
    this.title,
    this.showLanguage = true,
    this.copyable = true,
    this.rawToggle = false,
    this.highlightLines,
    this.lineNumbers = false,
    this.startLine = 1,
    this.prompt,
    this.wrap = false,
    this.maxHeight,
    this.fontFamily,
    this.fontSize,
    this.lineHeight,
    this.letterSpacing,
    this.locale,
    this.copyLabel,
    this.copiedLabel,
    this.rawLabel,
    this.semanticLabel,
    this.onCopy,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The code. Line endings are normalised and trailing blank lines dropped;
  /// nothing is taken off the front, where indentation means something.
  final String code;

  /// What it is written in: `ts`, `bash`, `yml`. The common spellings and
  /// file extensions are understood, and a name nothing here knows is drawn
  /// plain rather than refused.
  final String? language;

  /// The palette. Defaults to [NebaCodeTheme.dark].
  final NebaCodeTheme? theme;

  /// The type scale and the air around the code. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the focus rings take. It does not reach the code, whose
  /// colours are the theme's. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The padding. Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `0`, which is none.
  final NebaElevation? elevation;

  /// Whether the code is coloured.
  final bool highlight;

  /// The bar over the code, and the switch for everything on it: off, there
  /// is no bar whatever [showLanguage], [copyable] and [rawToggle] say.
  final bool toolbar;

  /// A name at the start of the bar: a file path, usually. A [Text] also
  /// names the scrolling region.
  final Widget? title;

  /// Whether the bar names the language.
  final bool showLanguage;

  /// Whether the bar has a button that puts the code on the clipboard.
  final bool copyable;

  /// Whether the bar has a toggle that drops the colouring and shows the
  /// characters as they are. It means nothing when [highlight] is off.
  final bool rawToggle;

  /// Lines to mark with a tinted row and a rule down the leading edge: a line
  /// or a range, or a list of them, `'4'`, `'4-9'`, `'1,4-9,12'`. They are
  /// counted as the gutter counts, from [startLine], and what cannot be read
  /// is left out.
  final String? highlightLines;

  /// Whether the lines are numbered down the side.
  final bool lineNumbers;

  /// What the first line is numbered.
  final int startLine;

  /// A shell prompt in front of every line with something on it: `$`, `#`,
  /// `C:\>`. Drawn but never selected or copied.
  final String? prompt;

  /// Whether long lines wrap rather than scroll sideways.
  final bool wrap;

  /// How tall the block may get, in pixels, before the code scrolls inside
  /// it. Left out, the block is as tall as the code.
  final double? maxHeight;

  /// The typeface. Defaults to [NebaScale.monoFonts].
  final String? fontFamily;

  /// The code's size in pixels, over the one [size] chose.
  final double? fontSize;

  /// The code's leading, as a multiple of its size, over the one [size]
  /// chose.
  final double? lineHeight;

  /// The code's tracking, in pixels.
  final double? letterSpacing;

  /// The language of the block's own words: the copy button, the raw toggle
  /// and the region's name. Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The copy button's label, over the [locale]'s word for it.
  final String? copyLabel;

  /// What the copy button says once the code is on the clipboard.
  final String? copiedLabel;

  /// The raw toggle's name.
  final String? rawLabel;

  /// The name a screen reader announces for a block that scrolls, over the
  /// [title], the language and the word for code, in that order.
  final String? semanticLabel;

  /// Called with the copied text once the clipboard has taken it.
  final ValueChanged<String>? onCopy;

  /// The code's type at each size, one step under the running text: a
  /// monospaced face reads a size larger than the prose around it.
  static const Map<NebaSize, ({double size, double height})> codeText =
      <NebaSize, ({double size, double height})>{
        NebaSize.xs: (size: 11, height: 1.55),
        NebaSize.sm: (size: 12, height: 1.6),
        NebaSize.md: (size: 13, height: 1.65),
        NebaSize.lg: (size: 14, height: 1.7),
        NebaSize.xl: (size: 16, height: 1.7),
      };

  /// The air above and below the code.
  static const Map<NebaDensity, Map<NebaSize, double>> paddingY =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 8,
          NebaSize.sm: 12,
          NebaSize.md: 14,
          NebaSize.lg: 16,
          NebaSize.xl: 20,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 6,
          NebaSize.sm: 8,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 14,
        },
      };

  /// The air at each end of a line, on the line itself, so a marked line's
  /// tint reaches both edges of the block.
  static const Map<NebaDensity, Map<NebaSize, double>> linePaddingX =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 8,
          NebaSize.sm: 12,
          NebaSize.md: 14,
          NebaSize.lg: 16,
          NebaSize.xl: 20,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 6,
          NebaSize.sm: 8,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 14,
        },
      };

  /// The bar's padding, shallower than the body's. Its ends are
  /// [linePaddingX] plus the two pixels a line spends on its rule, so the
  /// name on the bar starts where the code under it does.
  static const Map<NebaDensity, Map<NebaSize, EdgeInsets>> barPadding =
      <NebaDensity, Map<NebaSize, EdgeInsets>>{
        NebaDensity.standard: <NebaSize, EdgeInsets>{
          NebaSize.xs: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          NebaSize.sm: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          NebaSize.md: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          NebaSize.lg: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          NebaSize.xl: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        },
        NebaDensity.compact: <NebaSize, EdgeInsets>{
          NebaSize.xs: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          NebaSize.sm: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          NebaSize.md: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          NebaSize.lg: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          NebaSize.xl: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        },
      };

  /// How long the copy button says it worked.
  static const Duration copiedFor = Duration(seconds: 2);

  /// How long the announcement stays empty before it says so again, so a
  /// screen reader hears a second copy as a change.
  static const Duration speakAfter = Duration(milliseconds: 100);

  /// [code] as the block holds it: line endings normalised and trailing
  /// whitespace dropped. What the clipboard gets.
  static String normalise(String code) {
    return code.replaceAll(RegExp(r'\r\n?'), '\n').trimRight();
  }

  /// The line numbers [spec] marks, from [first] to [last]: `'4'`, `'4-9'`,
  /// `'1,4-9,12'`. A range written backwards is the same range, and a token
  /// that is not a number or a range is dropped.
  static Set<int> markedLines(String? spec, int first, int last) {
    final Set<int> marked = <int>{};

    if (spec == null) {
      return marked;
    }

    final RegExp range = RegExp(r'^\s*(\d+)\s*(?:-\s*(\d+)\s*)?$');

    for (final String token in spec.split(',')) {
      final RegExpMatch? match = range.firstMatch(token);

      if (match == null) {
        continue;
      }

      final int from = int.parse(match[1]!);
      final int to = match[2] == null ? from : int.parse(match[2]!);
      // Held to the lines the block has, so a range written as `10-100000000`
      // walks three lines rather than a hundred million.
      final int low = from < to ? from : to;
      final int high = from < to ? to : from;

      for (int line = low < first ? first : low; line <= (high > last ? last : high); line++) {
        marked.add(line);
      }
    }

    return marked;
  }

  @override
  State<NebaCodeBlock> createState() => _NebaCodeBlockState();
}

class _NebaCodeBlockState extends State<NebaCodeBlock> {
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();
  final FocusNode _focus = FocusNode(debugLabel: 'NebaCodeBlock');
  final GlobalKey<SelectableRegionState> _region = GlobalKey<SelectableRegionState>();
  final _LinesDelegate _selection = _LinesDelegate();

  bool _raw = false;
  bool _focused = false;
  bool? _copied;
  bool? _spoken;
  Timer? _copiedTimer;
  Timer? _speakTimer;
  final Map<Axis, bool> _overflow = <Axis, bool>{};

  ({String source, String? name, bool coloured, List<List<NebaCodeSpan>> lines})? _lines;

  bool get _overflows => _overflow.values.any((bool overflows) => overflows);

  @override
  void initState() {
    super.initState();
    _focus
      ..onKeyEvent = _onKey
      ..addListener(_onFocus);
  }

  @override
  void dispose() {
    _copiedTimer?.cancel();
    _speakTimer?.cancel();
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _vertical.dispose();
    _horizontal.dispose();
    _selection.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    final bool selectAll =
        (event.logicalKey == LogicalKeyboardKey.keyA ||
            event.physicalKey == PhysicalKeyboardKey.keyA) &&
        (keyboard.isControlPressed || keyboard.isMetaPressed) &&
        !keyboard.isAltPressed;

    if (selectAll) {
      if (event is KeyDownEvent) {
        _region.currentState?.selectAll(SelectionChangedCause.keyboard);
      }

      return KeyEventResult.handled;
    }

    if (!_overflows) {
      return KeyEventResult.ignored;
    }

    return nebaScrollKey(
      context,
      event,
      vertical: _overflow[Axis.vertical] ?? false ? _vertical : null,
      horizontal: _overflow[Axis.horizontal] ?? false ? _horizontal : null,
    );
  }

  bool _onMetrics(ScrollMetrics metrics) {
    final bool overflows = metrics.maxScrollExtent > metrics.minScrollExtent + 1;

    if (_overflow[metrics.axis] != overflows) {
      setState(() => _overflow[metrics.axis] = overflows);
    }

    return false;
  }

  Future<void> _copy(String source) async {
    bool done;

    try {
      await Clipboard.setData(ClipboardData(text: source));
      done = true;
    } on Object {
      done = false;
    }

    if (!mounted) {
      return;
    }

    _copiedTimer?.cancel();
    _speakTimer?.cancel();
    setState(() {
      _copied = done;
      _spoken = null;
    });
    // Emptied and written again a moment later, so a second copy inside the
    // two seconds is a change a screen reader hears.
    _speakTimer = Timer(NebaCodeBlock.speakAfter, () => setState(() => _spoken = done));
    _copiedTimer = Timer(NebaCodeBlock.copiedFor, () {
      setState(() {
        _copied = null;
        _spoken = null;
      });
    });

    if (done) {
      widget.onCopy?.call(source);
    }
  }

  List<List<NebaCodeSpan>> _linesOf(String source, String? name, bool coloured) {
    final ({String source, String? name, bool coloured, List<List<NebaCodeSpan>> lines})? held =
        _lines;

    if (held != null && held.source == source && held.name == name && held.coloured == coloured) {
      return held.lines;
    }

    final List<List<NebaCodeSpan>> lines =
        (coloured && name != null ? nebaHighlight(source, name) : null) ?? nebaPlainLines(source);

    _lines = (source: source, name: name, coloured: coloured, lines: lines);

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaElevation elevation = widget.elevation ?? 0;
    final NebaCodeTheme theme = widget.theme ?? NebaCodeTheme.dark;
    final NebaCodePalette palette = theme.paletteOf(tokens);
    final Color ring = tokens.roles(color).ring;
    final Map<String, String> messages = nebaMessages(context, 'code', locale: widget.locale);

    final String source = NebaCodeBlock.normalise(widget.code);
    final String? name = nebaCodeLanguage(widget.language);
    final bool coloured = widget.highlight && !_raw && name != null;
    final List<List<NebaCodeSpan>> lines = _linesOf(source, name, coloured);
    final int lastLine = widget.startLine + (lines.isEmpty ? 0 : lines.length - 1);
    final Set<int> marked = NebaCodeBlock.markedLines(
      widget.highlightLines,
      widget.startLine,
      lastLine,
    );

    final Color dim = mixOklab(palette.foreground, 0.58, palette.background);
    final Color rule = mixOklab(palette.foreground, 0.14, transparent);
    final Color hover = mixOklab(palette.foreground, 0.09, transparent);

    final ({double size, double height}) type = NebaCodeBlock.codeText[size]!;
    final double fontSize = widget.fontSize ?? type.size;
    final TextStyle codeStyle = TextStyle(
      fontFamily: widget.fontFamily ?? NebaScale.monoFonts.first,
      fontFamilyFallback: NebaScale.monoFonts.sublist(widget.fontFamily == null ? 1 : 0),
      fontSize: fontSize,
      height: widget.lineHeight ?? type.height,
      letterSpacing: widget.letterSpacing,
      color: palette.foreground,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    );
    final TextStyle monoMeta = TextStyle(
      fontFamily: widget.fontFamily ?? NebaScale.monoFonts.first,
      fontFamilyFallback: NebaScale.monoFonts.sublist(widget.fontFamily == null ? 1 : 0),
      fontSize: NebaScale.metaText[size],
      height: 1.5,
    );

    final String copyName = widget.copyLabel ?? messages['copy']!;
    final String copiedName = widget.copiedLabel ?? messages['copied']!;
    final String rawName = widget.rawLabel ?? messages['raw']!;
    final String failedName = messages['copyFailed']!;
    final Widget? title = widget.title;
    final String regionName =
        widget.semanticLabel ??
        (title is Text && (title.data?.isNotEmpty ?? false) ? title.data! : null) ??
        name ??
        messages['code']!;

    final bool showsLanguage = widget.showLanguage && name != null;
    final bool showsRaw = widget.rawToggle && widget.highlight;
    final bool bar =
        widget.toolbar && (showsLanguage || widget.copyable || showsRaw || title != null);

    Widget? toolbar;

    if (bar) {
      final Widget? named = title == null
          ? null
          : DefaultTextStyle.merge(
              style: monoMeta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: title,
            );

      toolbar = Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: rule)),
        ),
        padding: NebaCodeBlock.barPadding[density]![size]!,
        child: Row(
          spacing: 4,
          children: <Widget>[
            Expanded(
              child: Row(
                spacing: 4,
                children: <Widget>[
                  if (named != null) Flexible(child: named),
                  if (showsLanguage)
                    Text(
                      name.toUpperCase(),
                      semanticsLabel: name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: monoMeta.copyWith(
                        color: dim,
                        letterSpacing: NebaScale.metaText[size]! * 0.025,
                      ),
                    ),
                ],
              ),
            ),
            if (showsRaw)
              _BarButton(
                size: size,
                ink: dim,
                inkActive: palette.foreground,
                hover: hover,
                ring: ring,
                pressed: _raw,
                semanticLabel: rawName,
                icon: NebaGlyphs.code,
                onPressed: () => setState(() => _raw = !_raw),
              ),
            if (widget.copyable)
              _BarButton(
                size: size,
                ink: dim,
                inkActive: palette.foreground,
                hover: hover,
                ring: ring,
                icon: _copied ?? false ? NebaGlyphs.check : NebaGlyphs.copy,
                label: _copied == null
                    ? copyName
                    : _copied!
                    ? copiedName
                    : failedName,
                onPressed: () => _copy(source),
              ),
          ],
        ),
      );
    }

    _selection.rows = <int>[
      for (int index = 0; index < lines.length; index++)
        if (lines[index].isNotEmpty) index,
    ];

    final _CodeLines drawn = _CodeLines(
      selection: _selection,
      lines: lines,
      palette: palette,
      weighted: theme.weighted,
      style: codeStyle,
      dim: dim,
      mark: mixOklab(palette.foreground, 0.10, transparent),
      markEdge: mixOklab(palette.foreground, 0.45, transparent),
      marked: marked,
      startLine: widget.startLine,
      lineNumbers: widget.lineNumbers,
      digits: '$lastLine'.length,
      prompt: widget.prompt,
      wrap: widget.wrap,
      paddingX: NebaCodeBlock.linePaddingX[density]![size]!,
    );

    // The lines, as wide as the longest of them and never narrower than the
    // box, so every number starts at one place and every marked row reaches
    // the same edge however far the code is scrolled sideways.
    Widget body = widget.wrap
        ? drawn
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                controller: _horizontal,
                primary: false,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: IntrinsicWidth(child: drawn),
                ),
              );
            },
          );

    // Selectable, with the numbers and the prompts outside the selection. The
    // selection sits inside the vertical scroll and around the horizontal
    // one, because a selection across two nested scroll views selects
    // nothing. A selection draws its handles in the overlay, so a block with
    // none above it is drawn as it is, unselectable, rather than failing.
    body = Overlay.maybeOf(context) == null
        ? Focus(focusNode: _focus, child: body)
        : SelectableRegion(
            key: _region,
            focusNode: _focus,
            selectionControls: emptyTextSelectionControls,
            child: body,
          );

    body = SingleChildScrollView(
      controller: _vertical,
      primary: false,
      padding: EdgeInsets.symmetric(vertical: NebaCodeBlock.paddingY[density]![size]!),
      child: body,
    );

    body = NotificationListener<ScrollMetricsNotification>(
      onNotification: (ScrollMetricsNotification notification) => _onMetrics(notification.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) => _onMetrics(notification.metrics),
        child: body,
      ),
    );

    final double? maxHeight = widget.maxHeight;

    if (maxHeight != null) {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: body,
      );
    }

    // A tab stop, ringed inside its edge, only while there is something to
    // scroll to.
    _focus.skipTraversal = !_overflows;
    body = NebaFocusRing(
      visible: _focused && _overflows,
      color: ring,
      offset: -focusRingWidth,
      child: body,
    );

    body = _overflows
        ? Semantics(
            container: true,
            role: SemanticsRole.region,
            label: regionName,
            focusable: true,
            focused: _focused,
            child: body,
          )
        : body;

    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    return AnimatedContainer(
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: rule),
        borderRadius: radius,
        boxShadow: tokens.elevation(elevation),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: palette.foreground),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ?toolbar,
            Flexible(child: body),
            // The copy button changes its own label, which a screen reader
            // reading the page rather than the button would never hear.
            NebaLiveRegion(
              role: SemanticsRole.status,
              child: NebaVisuallyHidden(
                child: Text(
                  _spoken == null
                      ? ''
                      : _spoken!
                      ? copiedName
                      : failedName,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The lines, each a row of its number, its prompt and its code, in one
/// selection that joins them with the newlines between them.
class _CodeLines extends StatelessWidget {
  const _CodeLines({
    required this.selection,
    required this.lines,
    required this.palette,
    required this.weighted,
    required this.style,
    required this.dim,
    required this.mark,
    required this.markEdge,
    required this.marked,
    required this.startLine,
    required this.lineNumbers,
    required this.digits,
    required this.prompt,
    required this.wrap,
    required this.paddingX,
  });

  final _LinesDelegate selection;
  final List<List<NebaCodeSpan>> lines;
  final NebaCodePalette palette;
  final bool weighted;
  final TextStyle style;
  final Color dim;
  final Color mark;
  final Color markEdge;
  final Set<int> marked;
  final int startLine;
  final bool lineNumbers;
  final int digits;
  final String? prompt;
  final bool wrap;
  final double paddingX;

  TextStyle? _styleOf(NebaCodeKind kind) {
    final FontWeight? heavy = weighted ? FontWeight.w600 : null;

    return switch (kind) {
      NebaCodeKind.plain => null,
      NebaCodeKind.comment => TextStyle(color: palette.comment, fontStyle: FontStyle.italic),
      NebaCodeKind.keyword => TextStyle(color: palette.keyword, fontWeight: heavy),
      NebaCodeKind.string => TextStyle(color: palette.string),
      NebaCodeKind.number => TextStyle(color: palette.number),
      NebaCodeKind.function => TextStyle(color: palette.function, fontWeight: heavy),
      NebaCodeKind.type => TextStyle(color: palette.type, fontWeight: heavy),
      NebaCodeKind.variable => TextStyle(color: palette.variable),
      NebaCodeKind.tag => TextStyle(color: palette.tag, fontWeight: heavy),
      NebaCodeKind.attribute => TextStyle(color: palette.attribute),
      NebaCodeKind.meta => TextStyle(color: palette.meta),
      NebaCodeKind.addition => TextStyle(color: palette.addition),
      NebaCodeKind.deletion => TextStyle(color: palette.deletion),
    };
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = style.fontSize!;
    final TextStyle dimStyle = style.copyWith(color: dim);
    // The gutter is as wide as the last number, so it does not step as the
    // block scrolls: `ch` in the stylesheet, the width of a `0` here.
    final TextPainter zero = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final double gutter = zero.width * digits;

    zero.dispose();

    final String? prompt = this.prompt;

    return SelectionContainer(
      delegate: selection,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int index = 0; index < lines.length; index++)
            _CodeLine(
              key: ValueKey<int>(index),
              number: startLine + index,
              marked: marked.contains(startLine + index),
              mark: mark,
              markEdge: markEdge,
              paddingX: paddingX,
              gutter: lineNumbers
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(end: fontSize * 1.25),
                      child: SizedBox(
                        width: gutter,
                        child: Text(
                          '${startLine + index}',
                          textAlign: TextAlign.end,
                          style: dimStyle,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    )
                  : null,
              prompt: prompt != null && lines[index].isNotEmpty
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(end: fontSize * 0.75),
                      child: Text(prompt, style: dimStyle, maxLines: 1, softWrap: false),
                    )
                  : null,
              code: Text.rich(
                TextSpan(
                  style: style,
                  children: <InlineSpan>[
                    for (final NebaCodeSpan span in lines[index])
                      TextSpan(text: span.text, style: _styleOf(span.kind)),
                  ],
                ),
                softWrap: wrap,
              ),
              wrap: wrap,
            ),
        ],
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.number,
    required this.marked,
    required this.mark,
    required this.markEdge,
    required this.paddingX,
    required this.gutter,
    required this.prompt,
    required this.code,
    required this.wrap,
    super.key,
  });

  final int number;
  final bool marked;
  final Color mark;
  final Color markEdge;
  final double paddingX;
  final Widget? gutter;
  final Widget? prompt;
  final Widget code;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final Widget? gutter = this.gutter;
    final Widget? prompt = this.prompt;

    return Container(
      // A rule on every line, coloured on a marked one, so marking a line
      // does not move its text two pixels along.
      decoration: BoxDecoration(
        color: marked ? mark : null,
        border: BorderDirectional(
          start: BorderSide(width: 2, color: marked ? markEdge : transparent),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: paddingX),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drawn, never read and never selected: the reader is after the
          // code, and a `$` pasted into a shell is a `$` the shell chokes on.
          if (gutter != null) ExcludeSemantics(child: SelectionContainer.disabled(child: gutter)),
          if (prompt != null) ExcludeSemantics(child: SelectionContainer.disabled(child: prompt)),
          if (wrap) Expanded(child: code) else code,
        ],
      ),
    );
  }
}

/// The selection over the lines, which hands back what is selected on each
/// line joined with the newlines between them, blank lines included, as the
/// code has them.
class _LinesDelegate extends StaticSelectionContainerDelegate {
  /// The index of every line with something on it, in order: a blank line
  /// draws no text, so it has no selectable of its own to stand for it.
  List<int> rows = const <int>[];

  @override
  SelectedContent? getSelectedContent() {
    final StringBuffer buffer = StringBuffer();
    int? last;

    for (int index = 0; index < selectables.length; index++) {
      final SelectedContent? content = selectables[index].getSelectedContent();

      if (content == null) {
        continue;
      }

      final int row = index < rows.length ? rows[index] : (last ?? -1) + 1;

      if (last != null) {
        buffer.write('\n' * (row - last));
      }

      buffer.write(content.plainText);
      last = row;
    }

    return last == null ? null : SelectedContent(plainText: buffer.toString());
  }
}

/// A button on the bar: a glyph, and a label beside it when it has one.
///
/// Plain rather than a `NebaIconButton`, because a Neba control takes the
/// page's palette and the bar has refused it: an icon button here would be a
/// light control on a dark bar. What it keeps is the house treatment, the
/// radius, the eased colour and the focus ring.
class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.size,
    required this.ink,
    required this.inkActive,
    required this.hover,
    required this.ring,
    required this.icon,
    required this.onPressed,
    this.label,
    this.semanticLabel,
    this.pressed,
  });

  final NebaSize size;
  final Color ink;
  final Color inkActive;
  final Color hover;
  final Color ring;
  final List<NebaGlyphPart> icon;
  final VoidCallback onPressed;
  final String? label;
  final String? semanticLabel;
  final bool? pressed;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.metaText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.xs]!);
    final bool on = pressed ?? false;
    final String? label = this.label;

    return Semantics(
      container: true,
      button: true,
      selected: pressed,
      label: semanticLabel,
      child: NebaInteractive(
        onTap: onPressed,
        builder: (BuildContext context, NebaInteraction state, ValueListenable<Offset?> _) {
          final bool lit = state.hovered || on;
          final Duration duration = nebaDuration(
            context,
            NebaScale.duration,
            instant: state.pressed,
          );
          final Color colour = lit ? inkActive : ink;

          return NebaFocusRing(
            visible: state.focusVisible,
            color: ring,
            offset: 1,
            borderRadius: radius,
            child: AnimatedContainer(
              duration: duration,
              curve: NebaScale.ease,
              decoration: BoxDecoration(
                color: lit ? hover : hover.withValues(alpha: 0),
                borderRadius: radius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: colour),
                duration: duration,
                curve: NebaScale.ease,
                builder: (BuildContext context, Color? ink, Widget? _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: <Widget>[
                      NebaGlyph(icon, size: text * 1.15, color: ink),
                      if (label != null)
                        Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(fontSize: text, height: 1.5, color: ink),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
