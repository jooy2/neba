/// `NebaPagination`, a row of page numbers with steppers either side.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A row of page numbers, the one being read filled, with an ellipsis for a
/// run left out and a step back and forth either side.
///
/// It draws nothing for fewer than two pages. The page numbers are buttons,
/// so a page is a press; the package opens nothing itself, and
/// [onPageChange] goes to the page.
///
/// ```dart
/// NebaPagination(count: 12, page: page, onPageChange: (int next) => setState(() => page = next))
/// ```
class NebaPagination extends StatefulWidget {
  /// Pages 1 to [count].
  const NebaPagination({
    required this.count,
    this.page,
    this.defaultPage = 1,
    this.onPageChange,
    this.siblingCount = 1,
    this.boundaryCount = 1,
    this.showEdges = false,
    this.showArrows = true,
    this.disabled = false,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.locale,
    this.semanticLabel,
    this.pageLabel,
    this.previousLabel,
    this.nextLabel,
    this.firstLabel,
    this.lastLabel,
    super.key,
  });

  /// How many pages there are.
  final int count;

  /// The page being read, from 1, when the caller holds it.
  final int? page;

  /// The page to start on, when the pagination holds its own.
  final int defaultPage;

  /// Called with the page chosen.
  final ValueChanged<int>? onPageChange;

  /// How many pages either side of the current one are always shown.
  final int siblingCount;

  /// How many pages at each end are always shown.
  final int boundaryCount;

  /// Whether a step to the first and the last page is drawn.
  final bool showEdges;

  /// Whether the steps to the previous and the next page are drawn.
  final bool showArrows;

  /// Whether every page and step takes no input.
  final bool disabled;

  /// The weight of a page that is not the current one; the current one is
  /// always `solid`. Defaults to `NebaProvider`'s, then [NebaVariant.text].
  final NebaVariant? variant;

  /// The buttons' size. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the buttons.
  final NebaColor color;

  /// The buttons' padding. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.compact].
  final NebaDensity? density;

  /// The buttons' drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// The language of what a screen reader hears.
  final Locale? locale;

  /// The row's name for a screen reader, in place of "Pagination".
  final String? semanticLabel;

  /// A page's name for a screen reader, in place of "Page 3".
  final String Function(int page)? pageLabel;

  /// The previous step's name, in place of "Previous page".
  final String? previousLabel;

  /// The next step's name, in place of "Next page".
  final String? nextLabel;

  /// The first step's name, in place of "First page".
  final String? firstLabel;

  /// The last step's name, in place of "Last page".
  final String? lastLabel;

  /// The pages shown for [page] of [count], with `null` where a run is left
  /// out.
  static List<int?> pagesOf({
    required int count,
    required int page,
    int siblingCount = 1,
    int boundaryCount = 1,
  }) {
    List<int> range(int start, int end) => <int>[for (int i = start; i <= end; i++) i];

    final List<int> startPages = range(1, math.min(boundaryCount, count));
    final List<int> endPages = range(math.max(count - boundaryCount + 1, boundaryCount + 1), count);
    final int siblingsStart = math.max(
      math.min(page - siblingCount, count - boundaryCount - siblingCount * 2 - 1),
      boundaryCount + 2,
    );
    final int siblingsEnd = math.min(
      math.max(page + siblingCount, boundaryCount + siblingCount * 2 + 2),
      endPages.isNotEmpty ? endPages.first - 2 : count - 1,
    );

    return <int?>[
      ...startPages,
      if (siblingsStart > boundaryCount + 2)
        null
      else if (boundaryCount + 1 < count - boundaryCount)
        boundaryCount + 1,
      ...range(siblingsStart, siblingsEnd),
      if (siblingsEnd < count - boundaryCount - 1)
        null
      else if (count - boundaryCount > boundaryCount)
        count - boundaryCount,
      ...endPages,
    ];
  }

  @override
  State<NebaPagination> createState() => _NebaPaginationState();
}

class _NebaPaginationState extends State<NebaPagination> {
  late int _own = widget.defaultPage;

  int get _current => math.min(math.max(widget.page ?? _own, 1), math.max(widget.count, 1));

  void _go(int next) {
    final int clamped = math.min(math.max(next, 1), widget.count);

    if (clamped == _current) {
      return;
    }

    if (widget.page == null) {
      setState(() => _own = clamped);
    }

    widget.onPageChange?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count < 2) {
      return const SizedBox.shrink();
    }

    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.compact;
    final Map<String, String> messages = nebaMessages(context, 'pagination', locale: widget.locale);
    final int current = _current;
    final int count = widget.count;
    final bool atStart = current <= 1;
    final bool atEnd = current >= count;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double side = NebaScale.controlHeight[size]!;

    String pageName(int page) =>
        widget.pageLabel?.call(page) ??
        fillNebaMessage(messages['page']!, <String, String>{'page': '$page'});

    Widget stepper({
      required String name,
      required int to,
      required bool inert,
      required List<NebaGlyphPart> glyph,
      required int quarterTurns,
    }) {
      return NebaButton(
        variant: variant,
        size: size,
        color: widget.color,
        density: density,
        elevation: widget.elevation,
        disabled: widget.disabled || inert,
        focusableWhenDisabled: !widget.disabled,
        semanticLabel: name,
        startIcon: RotatedBox(quarterTurns: quarterTurns, child: NebaGlyph(glyph)),
        onPressed: () => _go(to),
      );
    }

    final List<int?> pages = NebaPagination.pagesOf(
      count: count,
      page: current,
      siblingCount: widget.siblingCount,
      boundaryCount: widget.boundaryCount,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? messages['label'],
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: NebaScale.gap[size]!,
            children: <Widget>[
              if (widget.showEdges)
                stepper(
                  name: widget.firstLabel ?? messages['first']!,
                  to: 1,
                  inert: atStart,
                  glyph: NebaGlyphs.doubleChevron,
                  quarterTurns: rtl ? 0 : 2,
                ),
              if (widget.showArrows)
                stepper(
                  name: widget.previousLabel ?? messages['previous']!,
                  to: current - 1,
                  inert: atStart,
                  glyph: NebaGlyphs.chevron,
                  quarterTurns: rtl ? 3 : 1,
                ),
              // Positional, never keyed by the page: the window recentres on the
              // page just chosen, and the button under the pointer has to stay
              // the button under the pointer.
              for (final int? page in pages)
                if (page == null)
                  ExcludeSemantics(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: side, minHeight: side, maxHeight: side),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          '…',
                          style: TextStyle(
                            fontSize: NebaScale.controlText[size],
                            color: tokens.mutedFg,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  MergeSemantics(
                    child: Semantics(
                      selected: page == current,
                      child: NebaButton(
                        variant: page == current ? NebaVariant.solid : variant,
                        size: size,
                        color: widget.color,
                        density: density,
                        elevation: widget.elevation,
                        disabled: widget.disabled,
                        semanticLabel: pageName(page),
                        onPressed: () => _go(page),
                        child: Text(
                          '$page',
                          style: const TextStyle(
                            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
              if (widget.showArrows)
                stepper(
                  name: widget.nextLabel ?? messages['next']!,
                  to: current + 1,
                  inert: atEnd,
                  glyph: NebaGlyphs.chevron,
                  quarterTurns: rtl ? 1 : 3,
                ),
              if (widget.showEdges)
                stepper(
                  name: widget.lastLabel ?? messages['last']!,
                  to: count,
                  inert: atEnd,
                  glyph: NebaGlyphs.doubleChevron,
                  quarterTurns: rtl ? 2 : 0,
                ),
            ],
          ),
          // Where the reader is, as a sentence: the buttons say which page is
          // chosen, this says how many there are.
          NebaLiveRegion(
            role: SemanticsRole.status,
            child: Semantics(
              label: fillNebaMessage(messages['status']!, <String, String>{
                'page': '$current',
                'total': '$count',
              }),
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
