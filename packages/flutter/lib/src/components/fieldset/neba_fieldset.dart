/// `NebaFieldset`, a group of controls with a name on it.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A group of controls that answer one question together, with a name on it.
///
/// It draws no surface: a group of fields is a grouping and not a sheet, so it
/// goes inside a `NebaCard` or a `NebaBox` when one is wanted. What it owns is
/// the [legend], the gap the controls stand at, and [disabled], which reaches
/// every Neba control inside it, however deep, including those inside a
/// fieldset nested in this one.
///
/// ```dart
/// NebaFieldset(
///   legend: const Text('Billing address'),
///   children: <Widget>[
///     NebaTextField(label: const Text('Street')),
///     NebaTextField(label: const Text('City')),
///   ],
/// )
/// ```
class NebaFieldset extends StatelessWidget {
  /// A fieldset around [children].
  const NebaFieldset({
    this.legend,
    this.description,
    this.disabled = false,
    this.size,
    this.spacing,
    this.semanticLabel,
    this.children = const <Widget>[],
    super.key,
  }) : assert(spacing == null || spacing >= 0);

  /// What the group is called, usually a [Text]. A screen reader hears it as
  /// the group's name, so it has to be a phrase that still reads correctly in
  /// front of each control: "Billing address", not "Where should we send it?".
  final Widget? legend;

  /// A line under the legend, usually a [Text]. A screen reader hears it after
  /// the group's name, as its description rather than a part of the name.
  final Widget? description;

  /// Disables every control inside at once, the way a `<fieldset>` always has.
  /// A fieldset inside a disabled one is disabled too.
  final bool disabled;

  /// The type scale of the legend, and the gap between the controls when
  /// [spacing] is not given. It does not reach the controls themselves.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The gap between the controls on the spacing scale, `5` being 20 logical
  /// pixels. Takes over from the gap [size] picks and leaves the legend's type
  /// scale alone. Defaults to `NebaProvider`'s `spacing`.
  final double? spacing;

  /// What a screen reader names the group, in place of [legend]: for a group
  /// whose legend is not a [Text], or that has none.
  final String? semanticLabel;

  /// The controls, one under the other.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final double? spacing = this.spacing ?? defaults.spacing;
    final double gap = spacing == null
        ? NebaScale.sheetSectionGap[size]!
        : spacing * NebaScale.spacingUnit;
    // A group inside a disabled group is disabled too, as the browser says of
    // a nested `<fieldset>`, and the fields inside it have to hear the same.
    final bool off = nebaFieldsetDisabled(context, disabled);
    final Widget? legend = this.legend;
    final Widget? description = this.description;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: semanticLabel,
      label: legend,
      description: description,
    );
    final double titleSize = NebaScale.sheetTitleText[size]!;

    return NebaFieldsetScope(
      disabled: off,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semantics.label,
        hint: semantics.hint,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: <Widget>[
            if (legend != null || description != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: NebaScale.sheetHeaderGap[size]!,
                children: <Widget>[
                  if (legend != null)
                    ExcludeSemantics(
                      excluding: semantics.labelTaken,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: titleSize,
                          height: NebaScale.sheetTitleLeading[size]! / titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                        child: legend,
                      ),
                    ),
                  if (description != null)
                    ExcludeSemantics(
                      excluding: semantics.descriptionTaken,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
                        child: description,
                      ),
                    ),
                ],
              ),
            ...nebaPresentChildren(context, children),
          ],
        ),
      ),
    );
  }
}
