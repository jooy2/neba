/// `NebaApproval`, the agent asking permission, and the record of what was
/// decided.
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How much is at stake if the answer to a [NebaApproval] is wrong.
///
/// Three rather than a number, because what a reader does with it is decide
/// how carefully to read the rest of the card. Each takes over the card's
/// family, as the three families that already mean this everywhere else in
/// the library, and is written out as a word, never a colour alone.
enum NebaApprovalRisk {
  /// Info.
  low,

  /// Warning.
  medium,

  /// Danger.
  high,
}

/// One answer a [NebaApproval] offers.
@immutable
class NebaApprovalOption {
  /// The answer [value], drawn as [label].
  const NebaApprovalOption({
    required this.value,
    required this.label,
    this.description,
    this.color,
    this.variant,
    this.icon,
    this.disabled = false,
  });

  /// What is reported to `onDecide`, and what identifies the answer
  /// afterwards.
  final String value;

  /// The words on the button, usually a [Text].
  final Widget label;

  /// A line under the row of buttons, saying what this answer commits to.
  final Widget? description;

  /// The family of this one button, over the card's.
  final NebaColor? color;

  /// The weight of this one button. Every option is `outline` by default, and
  /// that is the decision rather than the absence of one: a request whose
  /// loudest button is "Allow" is answered by its layout.
  final NebaVariant? variant;

  /// A glyph before the label.
  final Widget? icon;

  /// Offered but not available: a permission the reader cannot grant.
  final bool disabled;
}

/// The agent asking permission, and the record of what was decided.
///
/// A `NebaConfirm` and a `NebaPopconfirm` are opened by the reader, offer two
/// answers, and are gone the moment one is taken. This is opened by the
/// agent, offers as many answers as the agent has, allow once, always allow,
/// deny, and stays: once answered, the row of buttons becomes a line saying
/// which answer was given, so the transcript can be read back to find out
/// what was agreed to.
///
/// No option is emphasised by default. Every button is `outline` in the
/// card's family, and an option's own `variant` is how one is singled out.
///
/// ```dart
/// NebaApproval(
///   risk: NebaApprovalRisk.high,
///   title: const Text('Run a shell command?'),
///   details: const Text('rm -rf ./dist'),
///   options: const <NebaApprovalOption>[
///     NebaApprovalOption(value: 'once', label: Text('Allow once')),
///     NebaApprovalOption(value: 'deny', label: Text('Deny'), color: NebaColor.danger),
///   ],
///   onDecide: (String value) => answer(value),
/// )
/// ```
class NebaApproval extends StatefulWidget {
  /// A request offering [options].
  const NebaApproval({
    required this.options,
    this.title,
    this.description,
    this.details,
    this.risk,
    this.decision,
    this.controlled = false,
    this.onDecide,
    this.icon,
    this.showIcon = true,
    this.disabled = false,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.locale,
    this.labels,
    this.child,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The answers. At least one; three is the usual shape.
  final List<NebaApprovalOption> options;

  /// What is being asked, usually a [Text]. Defaults to the [locale]'s
  /// "Permission needed", because a request with nothing written on it still
  /// has to say what kind of thing it is.
  final Widget? title;

  /// The sentence under the heading, saying why.
  final Widget? description;

  /// What the agent is asking to do: a command, a payload, a file path. A
  /// plain [Text] is drawn as preformatted text with its own line breaks
  /// kept; any other widget as it is, which is where an editable form of the
  /// arguments goes.
  final Widget? details;

  /// How much is at stake: a word on a chip beside the heading, and the
  /// card's family, `info`, `warning` or `danger`.
  final NebaApprovalRisk? risk;

  /// Which option was taken, by its value. A value always shows that answer;
  /// `null` shows the buttons, and the card then remembers the one pressed,
  /// unless [controlled].
  final String? decision;

  /// Whether [decision] is the whole truth, `null` included: the card shows
  /// the buttons until its caller hands it an answer, which is React's
  /// `decision={null}`.
  final bool controlled;

  /// Called with an option's value when its button is pressed.
  final ValueChanged<String>? onDecide;

  /// The glyph at the start, in place of the severity mark of the family.
  final Widget? icon;

  /// Whether a glyph is drawn at all; `false` drops it, React's
  /// `icon={false}`.
  final bool showIcon;

  /// Every option stops answering. The card stays exactly as it is otherwise.
  final bool disabled;

  /// The sheet's weight: `outline`, `solid`, or `text`, a wash of the family
  /// with no edge. The sheet itself is never dyed. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The padding, the corners, the type and the buttons. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family when there is no [risk], which takes it over. Defaults to
  /// [NebaColor.warning]: an approval is a question about whether to go ahead.
  final NebaColor? color;

  /// How much padding the card has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// The language of the default heading, the record line and the risk chip.
  /// Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Those words, written out over the [locale]'s, by the React package's
  /// keys: `request`, `answered`, `low`, `medium` and `high`.
  final Map<String, String>? labels;

  /// Anything else the body needs, under the details and above the answers.
  final Widget? child;

  /// The tallest a block of preformatted details gets before it scrolls.
  static const double detailsMaxHeight = 224;

  /// The family each risk takes.
  static const Map<NebaApprovalRisk, NebaColor> riskColors = <NebaApprovalRisk, NebaColor>{
    NebaApprovalRisk.low: NebaColor.info,
    NebaApprovalRisk.medium: NebaColor.warning,
    NebaApprovalRisk.high: NebaColor.danger,
  };

  @override
  State<NebaApproval> createState() => _NebaApprovalState();
}

class _NebaApprovalState extends State<NebaApproval> {
  String? _taken;
  bool _pressed = false;
  final FocusNode _record = FocusNode(debugLabel: 'NebaApproval record');

  String? get _decision {
    return widget.controlled || widget.decision != null ? widget.decision : _taken;
  }

  @override
  void dispose() {
    _record.dispose();
    super.dispose();
  }

  void _decide(String value) {
    _pressed = true;

    if (!widget.controlled && widget.decision == null) {
      setState(() => _taken = value);
    }

    widget.onDecide?.call(value);
    // The answer replaces the buttons, so the one that was pressed leaves
    // with the focus on it. The record line takes it instead, but only when
    // the press is what put it there and the focus has not gone elsewhere.
    SchedulerBinding.instance.addPostFrameCallback((Duration _) => _handOver());
  }

  void _handOver() {
    if (!mounted || !_pressed || _answer == null) {
      return;
    }

    _pressed = false;

    final FocusNode? now = FocusManager.instance.primaryFocus;

    if (now == null || now is FocusScopeNode) {
      _record.requestFocus();
    }
  }

  NebaApprovalOption? get _answer {
    final String? decision = _decision;

    if (decision == null) {
      return null;
    }

    for (final NebaApprovalOption option in widget.options) {
      if (option.value == decision) {
        return option;
      }
    }

    return null;
  }

  @override
  void didUpdateWidget(NebaApproval oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A controlled answer arrives on a later build than the press.
    if (_pressed && _answer != null) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => _handOver());
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaApprovalRisk? risk = widget.risk;
    final NebaColor family = risk == null
        ? widget.color ?? NebaColor.warning
        : NebaApproval.riskColors[risk]!;
    final NebaColorRoles roles = tokens.roles(family);
    final Map<String, String> messages = nebaMessages(
      context,
      'approval',
      locale: widget.locale ?? defaults.locale,
    );
    String word(String key) => widget.labels?[key] ?? messages[key]!;

    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;
    final double metaSize = NebaScale.metaText[size]!;
    final double em = bodySize;
    final double line = NebaScale.sheetBodyLeading[size]!;
    final Widget title = widget.title ?? Text(word('request'));
    final String? name = nebaPlainText(title);
    final Widget? description = widget.description;
    final Widget? details = widget.details;
    final Widget? child = widget.child;
    final NebaApprovalOption? answer = _answer;
    final Widget? glyph = widget.showIcon
        ? widget.icon ?? NebaGlyph(NebaGlyphs.severity(family))
        : null;

    Widget onLine(Widget child) {
      return SizedBox(
        height: line,
        child: Center(widthFactor: 1, child: child),
      );
    }

    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        if (glyph != null)
          onLine(
            IconTheme.merge(
              data: IconThemeData(color: roles.accent, size: em * 1.2),
              child: glyph,
            ),
          ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: NebaScale.sheetHeaderGap[size]!,
            children: <Widget>[
              // The card is named after its heading, which is then not read a
              // second time.
              ExcludeSemantics(
                excluding: name != null,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: titleSize,
                    height: NebaScale.sheetTitleLeading[size]! / titleSize,
                    fontWeight: FontWeight.w600,
                    color: roles.accent,
                  ),
                  child: title,
                ),
              ),
              if (description != null)
                Semantics(
                  container: true,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: tokens.mutedFg),
                    child: description,
                  ),
                ),
            ],
          ),
        ),
        if (risk != null)
          // A node of its own, so the card's name stays its heading.
          Semantics(
            container: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: ShapeDecoration(color: roles.soft, shape: const StadiumBorder()),
              child: Text(
                word(risk.name),
                style: TextStyle(
                  fontSize: metaSize,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: roles.onTint,
                ),
              ),
            ),
          ),
      ],
    );

    final Widget actions;

    if (answer != null) {
      actions = Focus(
        focusNode: _record,
        child: Builder(
          builder: (BuildContext context) {
            final bool focused = Focus.of(context).hasPrimaryFocus;

            return NebaFocusRing(
              visible: focused,
              color: roles.ring,
              borderRadius: BorderRadius.circular(tokens.radius[NebaSize.xs]!),
              child: Semantics(
                container: true,
                child: Row(
                  spacing: 8,
                  children: <Widget>[
                    onLine(NebaGlyph(NebaGlyphs.check, size: em * 1.2, color: roles.accent)),
                    Text(
                      word('answered'),
                      style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
                    ),
                    Flexible(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(fontWeight: FontWeight.w500, color: tokens.fg),
                        child: answer.label,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      final List<NebaApprovalOption> described = <NebaApprovalOption>[
        for (final NebaApprovalOption option in widget.options)
          if (option.description != null) option,
      ];

      actions = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final NebaApprovalOption option in widget.options)
                NebaButton(
                  size: size,
                  variant: option.variant ?? NebaVariant.outline,
                  color: option.color ?? family,
                  startIcon: option.icon,
                  disabled: widget.disabled || option.disabled,
                  onPressed: () => _decide(option.value),
                  child: option.label,
                ),
            ],
          ),
          if (described.isNotEmpty)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
              child: Semantics(
                container: true,
                role: SemanticsRole.list,
                explicitChildNodes: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 2,
                  children: <Widget>[
                    for (final NebaApprovalOption option in described)
                      Semantics(
                        container: true,
                        role: SemanticsRole.listItem,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            DefaultTextStyle.merge(
                              style: TextStyle(fontWeight: FontWeight.w500, color: tokens.fg),
                              child: option.label,
                            ),
                            const Text(' — '),
                            Flexible(child: option.description!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    final Widget content = Padding(
      padding: EdgeInsets.all(NebaBox.padding[density]![size]!),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg, fontSize: bodySize, height: line / bodySize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: NebaScale.sheetSectionGap[size]!,
          children: <Widget>[
            header,
            if (details != null)
              Semantics(
                container: true,
                child: switch (nebaPreformattedText(details)) {
                  final String text => NebaPreformatted(
                    text: text,
                    maxHeight: NebaApproval.detailsMaxHeight,
                  ),
                  null => details,
                },
              ),
            if (child != null) Semantics(container: true, child: child),
            actions,
          ],
        ),
      ),
    );

    final Widget sheet = variant == NebaVariant.text
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: roles.soft,
              borderRadius: BorderRadius.circular(tokens.radius[size]!),
            ),
            child: content,
          )
        : NebaDisclosureSheet(
            variant: variant,
            color: family,
            size: size,
            elevation: widget.elevation ?? 0,
            // Behind rather than around, so a button's focus ring near the
            // edge is not clipped.
            clip: false,
            child: content,
          );

    // A group named by its heading, so a screen reader's list of elements says
    // which permission is being asked about.
    return Semantics(container: true, explicitChildNodes: true, label: name, child: sheet);
  }
}
