/// `NebaInlineCitation`, a numbered footnote in the body of an answer.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/hover_card/neba_hover_card.dart';
import 'package:neba/src/components/text_link/neba_text_link.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A numbered footnote in the body of an answer, with the source behind it a
/// hover away.
///
/// The mark is the same square a `NebaSources` row draws, so a reader sees
/// `2` in a sentence and finds `2` in the list underneath. [index] is the
/// caller's rather than counted here: a citation sits in a paragraph, the
/// list it points at is somewhere else, and a mark that numbered itself by
/// the order it was built in would renumber the answer whenever a sentence
/// moved.
///
/// It is sized by the type around it, so in running text it goes in a
/// [WidgetSpan]:
///
/// ```dart
/// Text.rich(
///   TextSpan(
///     children: <InlineSpan>[
///       const TextSpan(text: 'A control never moves under the pointer'),
///       WidgetSpan(
///         alignment: PlaceholderAlignment.middle,
///         child: NebaInlineCitation(index: 1, title: const Text('The design language')),
///       ),
///     ],
///   ),
/// )
/// ```
class NebaInlineCitation extends StatelessWidget {
  /// The mark for source [index].
  const NebaInlineCitation({
    required this.index,
    this.title,
    this.description,
    this.site,
    this.href,
    this.onPressed,
    this.newTab = false,
    this.preview = true,
    this.size,
    this.color,
    this.locale,
    this.labels,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Which source this is, and the only thing the mark itself says.
  final int index;

  /// The heading of the preview. Without it there is nothing to preview.
  final Widget? title;

  /// The line under it: the passage that was used, the publisher, a date.
  final Widget? description;

  /// Where it came from, set under the title in the preview.
  final Widget? site;

  /// Where the citation points, for a screen reader and, on the web, the
  /// browser. A scheme other than `http`, `https`, `mailto` or `tel` leaves
  /// the mark without a link.
  final Uri? href;

  /// What a press on the mark, or on the preview's title, does. The package
  /// opens nothing itself; left out, the mark is not a link, and takes the
  /// focus only when it has a preview to open.
  final VoidCallback? onPressed;

  /// Whether the link leaves the app. A screen reader is told so; opening it
  /// somewhere else is [onPressed]'s.
  final bool newTab;

  /// Shows the preview when the pointer rests on the mark and on keyboard
  /// focus. Off, the mark is bare, and the reader has the list at the bottom
  /// of the answer.
  final bool preview;

  /// The type scale of the preview. The mark itself follows the type around
  /// it. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the mark's wash, its number and its ring. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The language the mark's name is said in. Defaults to `NebaProvider`'s,
  /// then the app's.
  final Locale? locale;

  /// Those words, written out over the [locale]'s, by the React package's
  /// keys: `citation`, with an `{index}` in it.
  final Map<String, String>? labels;

  /// The mark's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the mark takes the focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = this.color ?? NebaColor.primary;
    final NebaColorRoles roles = tokens.roles(color);
    final Locale? locale = this.locale ?? defaults.locale;
    final Map<String, String> messages = nebaMessages(context, 'sources', locale: locale);
    final String name = fillNebaMessage(
      labels?['citation'] ?? messages['citation']!,
      <String, String>{'index': '$index'},
    );
    final Uri? href = this.href;
    final bool linked = onPressed != null && (href == null || nebaSafeHref(href) != null);
    final Widget? title = this.title;
    final bool previews = preview && title != null;
    // The name is the whole of what is read, so the words that say the link
    // leaves the app go into it rather than beside it.
    final String label = linked && newTab
        ? '$name ${nebaMessages(context, 'link', locale: locale)['newTab']}'
        : name;

    final Widget mark = Semantics(
      container: true,
      link: linked,
      linkUrl: linked ? nebaSafeHref(href) : null,
      label: label,
      child: NebaInteractive(
        enabled: linked || previews,
        focusable: linked || previews,
        onTap: onPressed,
        focusNode: focusNode,
        autofocus: autofocus,
        activatesOnSpace: false,
        cursor: linked ? SystemMouseCursors.click : SystemMouseCursors.basic,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          final double em = DefaultTextStyle.of(context).style.fontSize ?? 14;

          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: roles.ring,
            borderRadius: BorderRadius.circular(em * 0.8 * 0.3),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: interaction.hovered ? roles.softHover : roles.soft),
              duration: nebaDuration(context, NebaScale.duration),
              curve: NebaScale.ease,
              builder: (BuildContext context, Color? wash, Widget? _) {
                return ExcludeSemantics(
                  child: NebaCitationMark(index: index, roles: roles, wash: wash),
                );
              },
            ),
          );
        },
      ),
    );

    if (!previews) {
      return mark;
    }

    final Widget? description = this.description;

    return NebaHoverCard(
      size: size,
      color: color,
      trigger: mark,
      title: linked
          ? NebaTextLink(
              onPressed: onPressed,
              href: href,
              underline: NebaTextLinkUnderline.hover,
              newTab: newTab,
              showIcon: false,
              locale: locale,
              child: title,
            )
          : title,
      description: site,
      child: description == null
          ? null
          : DefaultTextStyle.merge(
              style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
              child: description,
            ),
    );
  }
}
