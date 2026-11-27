/// The sections of a sheet that takes the page, a Drawer's and a Dialog's:
/// the heading with its description and the × beside them, the body, which
/// is the only part that scrolls, and the row of actions at the foot.
///
/// The React package writes the same arrangement twice, once in each
/// component; here it is written once.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The heading, the body and the actions of a sheet, one under the other, in
/// the sheet type ladder at [size].
///
/// Without [dividers] the sections are set apart by the sheet's section gap
/// inside one padding all round; with them each section takes the padding on
/// itself, so the hairline between two of them reaches both edges of the
/// sheet. The body scrolls, and keeps room inside itself at the top and the
/// bottom for a focus ring and a floated label, which it takes back from the
/// space around it.
class NebaSheetSections extends StatelessWidget {
  /// The sections of a sheet holding [child] as its body.
  const NebaSheetSections({
    required this.size,
    required this.density,
    required this.color,
    this.title,
    this.headingLevel = 2,
    this.namesRoute = false,
    this.description,
    this.close,
    this.actions = const <Widget>[],
    this.dividers = false,
    this.fill = false,
    this.bounded = true,
    this.insets = EdgeInsets.zero,
    this.child,
    super.key,
  });

  /// The type of every section and the padding.
  final NebaSize size;

  /// How much padding each section has at its [size].
  final NebaDensity density;

  /// The family of the dividers.
  final NebaColor color;

  /// The heading, one step above the body in semibold, heard as a heading at
  /// [headingLevel].
  final Widget? title;

  /// Which heading the [title] is, `1` to `6`.
  final int headingLevel;

  /// Whether the [title] names the route it is in: a sheet that is a dialog.
  final bool namesRoute;

  /// A line under the title, in the muted ink one step down the type scale.
  final Widget? description;

  /// The × beside the heading.
  final Widget? close;

  /// The bottom row, end-aligned and wrapping when it runs out of room.
  final List<Widget> actions;

  /// Draws a hairline between the sections instead of separating them with
  /// space.
  final bool dividers;

  /// Whether the sheet has a height of its own, which the body then takes
  /// what is left of, rather than being as tall as what is on it.
  final bool fill;

  /// Whether the sheet has a ceiling, which the body scrolls under. Without
  /// one the body is as tall as what is in it.
  final bool bounded;

  /// Room kept around every section, besides the padding: the system's
  /// insets, for a sheet that runs to the edge of the screen.
  final EdgeInsets insets;

  /// The body: the only part that scrolls.
  final Widget? child;

  /// The room above and below the body of a sheet without dividers, the
  /// React package's `sheetScrollRoomClasses`: a scroll view clips what is
  /// drawn past it, so the body keeps room inside for a focus ring and a
  /// floated label and takes it back from the space around it.
  static const Map<NebaSize, (double, double)> scrollRoom = <NebaSize, (double, double)>{
    NebaSize.xs: (6, 4),
    NebaSize.sm: (7, 4),
    NebaSize.md: (8, 4),
    NebaSize.lg: (8, 4),
    NebaSize.xl: (9, 4),
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(color);
    final double inset = NebaBox.padding[density]![size]!;
    final double gap = NebaScale.sheetSectionGap[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;

    final Widget? title = this.title;
    final Widget? description = this.description;
    final Widget? close = this.close;
    final Widget? body = child;
    final bool hasHeader = title != null || description != null || close != null;
    final bool hasActions = actions.isNotEmpty;
    final BorderSide line = BorderSide(color: roles.line);
    final (double roomTop, double roomBottom) = dividers ? (0.0, 0.0) : scrollRoom[size]!;

    Widget? header;

    if (hasHeader) {
      final double titleSize = NebaScale.sheetTitleText[size]!;

      header = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: NebaScale.sheetHeaderGap[size]!,
              children: <Widget>[
                if (title != null)
                  Semantics(
                    container: true,
                    header: true,
                    headingLevel: headingLevel,
                    namesRoute: namesRoute ? true : null,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: titleSize,
                        height: NebaScale.sheetTitleLeading[size]! / titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                      child: title,
                    ),
                  ),
                if (description != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
                    child: description,
                  ),
              ],
            ),
          ),
          ?close,
        ],
      );
    }

    Widget? scroller;

    if (body != null) {
      scroller = SingleChildScrollView(
        padding: dividers
            ? EdgeInsets.all(inset)
            : EdgeInsets.fromLTRB(inset, roomTop, inset, roomBottom),
        child: body,
      );

      if (dividers && hasHeader) {
        // A Container, because it adds the line's width to the padding as a
        // CSS border does, so the line never lies over the scrolled content.
        scroller = Container(
          decoration: BoxDecoration(border: Border(top: line)),
          child: scroller,
        );
      }
    }

    Widget? footer;

    if (hasActions) {
      footer = Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: actions,
      );
    }

    final List<Widget> sections = <Widget>[];

    if (dividers) {
      // The lines reach both edges, so each section takes the padding on
      // itself and the sheet gives its own up.
      if (header != null) {
        sections.add(Padding(padding: EdgeInsets.all(inset), child: header));
      }

      if (scroller != null) {
        sections.add(_flexible(scroller));
      }

      if (footer != null) {
        sections.add(
          Container(
            decoration: BoxDecoration(border: Border(top: line)),
            padding: EdgeInsets.all(inset),
            child: footer,
          ),
        );
      }
    } else {
      // Space between the sections, less the room the body keeps inside
      // itself on the side it faces.
      sections.add(SizedBox(height: header == null && scroller != null ? inset - roomTop : inset));

      if (header != null) {
        sections.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: header,
          ),
        );

        if (scroller != null || footer != null) {
          sections.add(SizedBox(height: scroller != null ? gap - roomTop : gap));
        }
      }

      if (scroller != null) {
        sections.add(_flexible(scroller));

        if (footer != null) {
          sections.add(SizedBox(height: gap - roomBottom));
        }
      }

      if (footer != null) {
        sections.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: inset),
            child: footer,
          ),
        );
      }

      sections.add(
        SizedBox(height: footer == null && scroller != null ? inset - roomBottom : inset),
      );
    }

    return DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.fg,
        fontSize: bodySize,
        height: NebaScale.sheetBodyLeading[size]! / bodySize,
      ),
      child: NebaHitArea(
        child: Padding(
          padding: insets,
          child: Column(
            mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: sections,
          ),
        ),
      ),
    );
  }

  Widget _flexible(Widget body) {
    if (!bounded) {
      return body;
    }

    return fill ? Expanded(child: body) : Flexible(child: body);
  }
}
