/// `NebaSources` and `NebaSourceItem`, the numbered list of things an answer
/// was built out of.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/text_link/neba_text_link.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One thing an answer was built out of: a row of a [NebaSources], and what a
/// `NebaInlineCitation` previews.
@immutable
class NebaSourceItem {
  /// A source called [title].
  const NebaSourceItem({
    required this.title,
    this.href,
    this.onPressed,
    this.description,
    this.site,
    this.icon,
    this.index,
    this.newTab = false,
  });

  /// Its name, usually a [Text]: the link's words.
  final Widget title;

  /// Where it points, for a screen reader and, on the web, the browser. A
  /// scheme other than `http`, `https`, `mailto` or `tel` leaves the row
  /// without a link, because an address in a search result was not written
  /// by the app's author.
  final Uri? href;

  /// What a press on the title does. The package opens nothing itself; left
  /// out, the row is plain text.
  final VoidCallback? onPressed;

  /// The line under the title: the passage that matched, the publisher, a
  /// date.
  final Widget? description;

  /// Where it came from, set beside the title: a domain, a publication.
  final Widget? site;

  /// A favicon or a thumbnail, in the square between the number and the
  /// title.
  final Widget? icon;

  /// The number it is cited by, over its place in the list: for a list of
  /// only the sources actually cited, out of a longer set.
  final int? index;

  /// Whether the link leaves the app. A screen reader is told so; opening it
  /// somewhere else is [onPressed]'s.
  final bool newTab;
}

/// The list of things an answer was built out of.
///
/// A `NebaList` would draw the rows. What makes this a widget is that the
/// rows are numbered, and the numbers are what a `NebaInlineCitation` in the
/// body points at, drawn as the same mark. Folded behind its heading by
/// default, because what a reader wants from a list of sources most of the
/// time is to know how many there were, which the heading says.
///
/// ```dart
/// NebaSources(
///   items: <NebaSourceItem>[
///     NebaSourceItem(title: const Text('The design language'), onPressed: open),
///   ],
/// )
/// ```
class NebaSources extends StatefulWidget {
  /// A list of [items].
  const NebaSources({
    required this.items,
    this.title,
    this.collapsible = true,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.keepMounted = true,
    this.numbered = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.locale,
    this.labels,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The sources, in the order they are numbered.
  final List<NebaSourceItem> items;

  /// The heading, usually a [Text]. Defaults to the [locale]'s word for it.
  final Widget? title;

  /// Folds the list behind the heading. Off, the heading is a plain line and
  /// the list is open.
  final bool collapsible;

  /// Whether the list is showing, for a controlled Sources. Leave it `null`
  /// and it keeps its own state, starting from [defaultOpen].
  final bool? open;

  /// Where an uncontrolled Sources starts.
  final bool defaultOpen;

  /// Called with the new state when the heading opens or closes the list.
  final ValueChanged<bool>? onOpenChange;

  /// Whether a folded list keeps its rows built.
  final bool keepMounted;

  /// Numbers the rows, so a citation in the body has something to point at.
  final bool numbered;

  /// The sheet's weight: `text`, the default, for a list under an answer, or
  /// `outline` and `solid`. The sheet itself is never dyed. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.text].
  final NebaVariant? variant;

  /// The padding, the corners and the type. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The family of the numbers, the hairline, the hover wash and the ring.
  /// Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// How much padding the heading and the list have at their [size].
  /// Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// The language of the heading and of a link's new-tab notice. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Those words, written out over the [locale]'s, by the React package's
  /// keys: `title`.
  final Map<String, String>? labels;

  /// The square a favicon or a thumbnail lands in, at each size.
  static const Map<NebaSize, double> iconSizes = <NebaSize, double>{
    NebaSize.xs: 14,
    NebaSize.sm: 16,
    NebaSize.md: 18,
    NebaSize.lg: 20,
    NebaSize.xl: 24,
  };

  @override
  State<NebaSources> createState() => _NebaSourcesState();
}

class _NebaSourcesState extends State<NebaSources> with NebaFoldState<NebaSources> {
  @override
  bool? get controlledOpen => widget.open;

  @override
  ValueChanged<bool>? get onFoldChange => widget.onOpenChange;

  @override
  void initState() {
    super.initState();
    foldOpen = widget.defaultOpen;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaColorRoles roles = tokens.roles(color);
    final Locale? locale = widget.locale ?? defaults.locale;
    final Map<String, String> messages = nebaMessages(context, 'sources', locale: locale);
    final double padding = NebaBox.padding[density]![size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;
    final double metaSize = NebaScale.metaText[size]!;
    final bool open = !widget.collapsible || isOpen;

    final Widget heading = DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: titleSize,
        height: NebaScale.sheetTitleLeading[size]! / titleSize,
        fontWeight: FontWeight.w600,
      ),
      child: Row(
        spacing: NebaScale.gap[size]!,
        children: <Widget>[
          Flexible(
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: widget.title ?? Text(widget.labels?['title'] ?? messages['title']!),
            ),
          ),
          // The count is the whole point of the closed state: most readers
          // want to know how many there were rather than which.
          Text(
            '${widget.items.length}',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: tokens.mutedFg,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          if (widget.collapsible) ...<Widget>[
            const Spacer(),
            NebaDisclosureChevron(open: open, color: tokens.mutedFg, size: titleSize * 1.2),
          ],
        ],
      ),
    );

    final Widget list = Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, NebaDisclosureBody.bottom(density)),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: tokens.fg,
          fontSize: bodySize,
          height: NebaScale.sheetBodyLeading[size]! / bodySize,
        ),
        child: Semantics(
          container: true,
          role: SemanticsRole.list,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              for (int at = 0; at < widget.items.length; at++)
                _Row(
                  item: widget.items[at],
                  number: widget.items[at].index ?? at + 1,
                  numbered: widget.numbered,
                  size: size,
                  roles: roles,
                  metaSize: metaSize,
                  locale: locale,
                ),
            ],
          ),
        ),
      ),
    );

    final Widget header = widget.collapsible
        ? NebaFoldTrigger(
            open: open,
            onToggle: toggleFold,
            roles: roles,
            padding: EdgeInsets.all(padding),
            child: heading,
          )
        : Padding(padding: EdgeInsets.all(padding), child: heading);

    return NebaDisclosureSheet(
      variant: variant,
      color: color,
      size: size,
      elevation: widget.elevation ?? 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          header,
          if (widget.collapsible)
            NebaDisclosurePanel(open: open, keepMounted: widget.keepMounted, child: list)
          else
            list,
        ],
      ),
    );
  }
}

/// One source: its number, its picture, its linked title with the site
/// beside it, and the line under them.
class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.number,
    required this.numbered,
    required this.size,
    required this.roles,
    required this.metaSize,
    required this.locale,
  });

  final NebaSourceItem item;
  final int number;
  final bool numbered;
  final NebaSize size;
  final NebaColorRoles roles;
  final double metaSize;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Uri? href = item.href;
    // A link only with something to do on a press, and never to an address
    // whose scheme was refused.
    final bool linked = item.onPressed != null && (href == null || nebaSafeHref(href) != null);
    final Widget? icon = item.icon;
    final Widget? site = item.site;
    final Widget? description = item.description;
    final double iconSize = NebaSources.iconSizes[size]!;

    final Widget title = DefaultTextStyle.merge(
      style: const TextStyle(fontWeight: FontWeight.w500),
      child: linked
          ? NebaTextLink(
              onPressed: item.onPressed,
              href: href,
              underline: NebaTextLinkUnderline.hover,
              newTab: item.newTab,
              showIcon: false,
              locale: locale,
              child: item.title,
            )
          : item.title,
    );

    return Semantics(
      container: true,
      role: SemanticsRole.listItem,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          if (numbered)
            // The number is drawn for the eye; the row is read by its title.
            ExcludeSemantics(
              child: NebaCitationMark(index: number, roles: roles),
            ),
          if (icon != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox.square(dimension: iconSize, child: icon),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: <Widget>[
                    title,
                    if (site != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
                        child: site,
                      ),
                  ],
                ),
                if (description != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
                    child: description,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
