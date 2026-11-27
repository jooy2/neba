/// `NebaChatBubble`, one message in a conversation.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which side of the conversation a [NebaChatBubble] is on.
enum NebaChatBubbleSide {
  /// Someone else's, at the start of the line.
  start,

  /// The reader's own, at the end of the line.
  end,
}

/// How far a message has got.
enum NebaChatBubbleStatus {
  /// On its way.
  sending,

  /// The server has it.
  sent,

  /// It reached the other side.
  delivered,

  /// The other side has read it.
  read,

  /// It did not go.
  failed,
}

/// What a link inside a message unfurls to.
@immutable
class NebaChatBubbleLinkPreview {
  /// A preview of [url].
  const NebaChatBubbleLinkPreview({
    required this.url,
    this.onPressed,
    this.title,
    this.description,
    this.image,
    this.site,
    this.newTab = false,
  });

  /// Where the card goes, told to a screen reader and, on the web, the
  /// browser.
  final Uri url;

  /// What a press on the card does. The package opens nothing itself; left
  /// out, the card is not a link.
  final VoidCallback? onPressed;

  /// The page's title.
  final Widget? title;

  /// Its summary, clamped to two lines.
  final Widget? description;

  /// The share image, drawn across the top of the card.
  final ImageProvider? image;

  /// Who published it: a domain, a site name.
  final Widget? site;

  /// Whether the card opens somewhere else, which a screen reader is told.
  final bool newTab;
}

/// One message in a conversation.
///
/// Everything around the bubble is optional: the [avatar], the sender's
/// [name], the [time], the delivery [status], the [media] above the text and
/// the link [preview] below it are each drawn only when given. [side] decides
/// which way the row runs and which corner of the bubble is cut short;
/// [variant] is what tells the reader's own messages from everyone else's.
///
/// ```dart
/// const NebaChatBubble(name: Text('Farah'), time: Text('09:41'), child: Text('Still on?'))
/// ```
class NebaChatBubble extends StatefulWidget {
  /// A message of [child].
  const NebaChatBubble({
    this.child,
    this.side = NebaChatBubbleSide.start,
    this.name,
    this.time,
    this.avatar,
    this.status,
    this.statusLabel,
    this.typing = false,
    this.media,
    this.preview,
    this.actions,
    this.locale,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The message.
  final Widget? child;

  /// Whose message this is.
  final NebaChatBubbleSide side;

  /// Who sent it, above the bubble.
  final Widget? name;

  /// When it was sent, beside the name.
  final Widget? time;

  /// The sender's picture, a `NebaAvatar` at the size the thread uses. Left
  /// out, the bubble takes the whole row.
  final Widget? avatar;

  /// How far the message has got, drawn as a mark under the bubble.
  final NebaChatBubbleStatus? status;

  /// The word the [status] mark is read out as, in place of the locale's.
  final String? statusLabel;

  /// Whether three dots are drawn instead of [child], which is kept for when
  /// the message arrives.
  final bool typing;

  /// A picture, a video, a map: drawn edge to edge above the text, so the
  /// bubble's corners crop it.
  final Widget? media;

  /// A link in the message, unfurled into a card under the text.
  final NebaChatBubbleLinkPreview? preview;

  /// The message's own actions, usually a `NebaMenu` trigger, beside the
  /// bubble. Shown while the row is hovered or holds the focus, and always on
  /// a touch screen.
  final Widget? actions;

  /// The language the marks are read out in.
  final Locale? locale;

  /// The weight of the bubble. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline]; `solid` is the usual way to mark the reader's own.
  final NebaVariant? variant;

  /// The type and the padding. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the bubble.
  final NebaColor color;

  /// The padding inside the bubble. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The bubble's drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// The widest the column of a message grows.
  static const double maxWidth = 512;

  /// The room inside a bubble, horizontal then vertical, by density and size:
  /// tighter than a box's, because a bubble is a sentence with a surface
  /// behind it.
  static const Map<NebaDensity, Map<NebaSize, (double, double)>> padding =
      <NebaDensity, Map<NebaSize, (double, double)>>{
        NebaDensity.standard: <NebaSize, (double, double)>{
          NebaSize.xs: (8, 4),
          NebaSize.sm: (10, 6),
          NebaSize.md: (12, 8),
          NebaSize.lg: (14, 10),
          NebaSize.xl: (16, 12),
        },
        NebaDensity.compact: <NebaSize, (double, double)>{
          NebaSize.xs: (6, 2),
          NebaSize.sm: (8, 4),
          NebaSize.md: (10, 6),
          NebaSize.lg: (12, 6),
          NebaSize.xl: (14, 8),
        },
      };

  /// The radius of the corner nearest the speaker: a flat 4 pixels, so the
  /// cut reads at a glance in a column of forty messages.
  static const double tailRadius = 4;

  @override
  State<NebaChatBubble> createState() => _NebaChatBubbleState();
}

class _NebaChatBubbleState extends State<NebaChatBubble> {
  bool _hovered = false;
  bool _focused = false;

  void _hover(bool hovered) {
    if (hovered != _hovered) {
      setState(() => _hovered = hovered);
    }
  }

  void _focus(bool focused) {
    if (focused != _focused) {
      setState(() => _focused = focused);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final Locale? locale = widget.locale ?? defaults.locale;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final Map<String, String> messages = nebaMessages(context, 'chat', locale: locale);
    final bool end = widget.side == NebaChatBubbleSide.end;
    final double meta = NebaScale.metaText[size]!;
    final double body = NebaScale.sheetBodyText[size]!;
    final double radius = tokens.radius[size]!;
    final (double padX, double padY) = NebaChatBubble.padding[density]![size]!;
    final Widget? name = widget.name;
    final Widget? time = widget.time;
    final Widget? avatar = widget.avatar;
    final Widget? media = widget.media;
    final Widget? child = widget.child;
    final Widget? actions = widget.actions;
    final NebaChatBubbleLinkPreview? preview = widget.preview;
    final NebaChatBubbleStatus? status = widget.status;
    final bool hasBody = widget.typing || child != null || preview != null;

    // Filled, hairline, tinted. A bubble is the thing being coloured, so
    // `solid` floods it and the text turns to the family's ink on a fill.
    final (Color fill, Color? edge, NebaPlate plate, Color ink, bool frosted) = switch (variant) {
      NebaVariant.solid => (roles.fill, null, NebaPlate.solid, roles.onSolid, true),
      NebaVariant.outline => (roles.panel, roles.line, NebaPlate.glass, tokens.fg, true),
      NebaVariant.text => (roles.soft, null, NebaPlate.none, tokens.fg, false),
    };

    // The corner nearest the speaker is cut short, on the logical side, so a
    // thread laid out right to left squares the other corner.
    final BorderRadius corners = BorderRadiusDirectional.only(
      topStart: Radius.circular(end ? radius : NebaChatBubble.tailRadius),
      topEnd: Radius.circular(end ? NebaChatBubble.tailRadius : radius),
      bottomStart: Radius.circular(radius),
      bottomEnd: Radius.circular(radius),
    ).resolve(Directionality.of(context));

    final Widget bubble = NebaSheet(
      fill: fill,
      edge: edge,
      plate: plate,
      elevation: widget.elevation,
      borderRadius: corners,
      blur: frosted,
      texture: frosted,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: body,
          height: NebaScale.sheetBodyLeading[size]! / body,
          color: ink,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: ink),
          // As wide as what it holds, up to the room it has, with the media
          // and the card stretched across that width.
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Edge to edge: the bubble's own corners crop it, which is why
                // the padding is on the body rather than on the sheet.
                ?media,
                if (hasBody)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: <Widget>[
                        if (widget.typing)
                          _TypingDots(label: messages['typing']!, em: body, color: ink)
                        else
                          ?child,
                        if (preview != null)
                          _LinkPreview(
                            preview: preview,
                            ring: roles.ring,
                            ink: ink,
                            em: body,
                            locale: locale,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    // A pointer that cannot hover has nothing to reveal the actions with.
    final bool touch = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => true,
      TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows => false,
    };
    final bool showActions = touch || _hovered || _focused;
    final Widget? shownActions = actions == null
        ? null
        : AnimatedOpacity(
            opacity: showActions ? 1 : 0,
            duration: nebaDuration(context, NebaScale.duration),
            curve: NebaScale.ease,
            child: actions,
          );

    final Widget line = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        if (end) ?shownActions,
        Flexible(child: bubble),
        if (!end) ?shownActions,
      ],
    );

    final Widget column = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: NebaChatBubble.maxWidth),
      child: Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: NebaScale.sheetHeaderGap[size]!,
        children: <Widget>[
          if (name != null || time != null)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: meta, color: tokens.fg),
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: <Widget>[
                  if (name != null)
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      child: name,
                    ),
                  if (time != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: tokens.mutedFg),
                      child: time,
                    ),
                ],
              ),
            ),
          line,
          if (status != null)
            _StatusMark(
              status: status,
              size: meta * 1.15,
              color: switch (status) {
                NebaChatBubbleStatus.read => roles.accent,
                NebaChatBubbleStatus.failed => tokens.roles(NebaColor.danger).accent,
                NebaChatBubbleStatus.sending ||
                NebaChatBubbleStatus.sent ||
                NebaChatBubbleStatus.delivered => tokens.mutedFg,
              },
              label: widget.statusLabel ?? messages[status.name]!,
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (PointerEnterEvent event) => _hover(true),
      onExit: (PointerExitEvent event) => _hover(false),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: _focus,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            if (!end) ?avatar,
            Expanded(
              child: Align(
                alignment: end ? AlignmentDirectional.topEnd : AlignmentDirectional.topStart,
                heightFactor: 1,
                child: column,
              ),
            ),
            if (end) ?avatar,
          ],
        ),
      ),
    );
  }
}

/// Three dots that light in turn, in colour only: they never move.
class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.label, required this.em, required this.color});

  final String label;
  final double em;
  final Color color;

  /// One pass of the keyframes.
  static const Duration period = Duration(milliseconds: 1250);

  /// One pass for a reader who asked for less motion: slower, and still
  /// lighting, since dots that hold still say nothing is happening.
  static const Duration reducedPeriod = Duration(milliseconds: 2600);

  /// How far behind the one before it each dot runs.
  static const Duration stagger = Duration(milliseconds: 160);

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  Duration? _period;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Duration period = reduced ? _TypingDots.reducedPeriod : _TypingDots.period;

    if (period != _period) {
      _period = period;
      _clock.repeat(period: period);
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  /// A dot's opacity at [phase] of its pass: 0.28, up to 1 at 30%, back down
  /// by 60%, and resting there to the end.
  static double _opacity(double phase) {
    final double t = phase - phase.floorToDouble();

    if (t < 0.3) {
      return 0.28 + 0.72 * Curves.easeInOut.transform(t / 0.3);
    }

    if (t < 0.6) {
      return 1 - 0.72 * Curves.easeInOut.transform((t - 0.3) / 0.3);
    }

    return 0.28;
  }

  @override
  Widget build(BuildContext context) {
    final double dot = widget.em * 0.45;
    final double lag =
        _TypingDots.stagger.inMicroseconds / (_period ?? _TypingDots.period).inMicroseconds;

    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.label,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: widget.em * 0.35),
          child: AnimatedBuilder(
            animation: _clock,
            builder: (BuildContext context, Widget? _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: <Widget>[
                  for (int index = 0; index < 3; index++)
                    SizedBox.square(
                      dimension: dot,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color.withValues(
                            alpha: widget.color.a * _opacity(_clock.value - index * lag),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// How far a message has got: a mark drawn, and a word read out.
class _StatusMark extends StatelessWidget {
  const _StatusMark({
    required this.status,
    required this.size,
    required this.color,
    required this.label,
  });

  final NebaChatBubbleStatus status;
  final double size;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Widget mark = switch (status) {
      NebaChatBubbleStatus.sending => NebaGlyph(NebaGlyphs.clock, size: size, color: color),
      NebaChatBubbleStatus.sent => NebaGlyph(NebaGlyphs.check, size: size, color: color),
      NebaChatBubbleStatus.delivered => NebaGlyph(NebaGlyphs.doubleCheck, size: size, color: color),
      NebaChatBubbleStatus.read => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _ReadPainter(color)),
      ),
      NebaChatBubbleStatus.failed => NebaGlyph(NebaGlyphs.danger, size: size, color: color),
    };

    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(child: mark),
    );
  }
}

/// The double tick cut out of a filled disc: read, said by a shape as well as
/// a colour.
class _ReadPainter extends CustomPainter {
  _ReadPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.shortestSide / 16;

    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..scale(unit)
      ..drawCircle(const Offset(8, 8), 7.25, Paint()..color = color)
      // The ticks at three quarters of their size, moved into the disc, as
      // the mask the stylesheet's glyph cuts with.
      ..translate(2.375, 1.25)
      ..scale(0.75);

    final Paint cut = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawPath(
        Path()
          ..moveTo(1.5, 8.5)
          ..lineTo(4.25, 11.25)
          ..lineTo(9.5, 6),
        cut,
      )
      ..drawPath(
        Path()
          ..moveTo(7, 10.75)
          ..lineTo(8.25, 12)
          ..lineTo(13.5, 6.75),
        cut,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_ReadPainter oldDelegate) => oldDelegate.color != color;
}

/// The unfurled link: an image, who published it, a title and two lines of
/// summary, on a wash of the bubble's own ink so it reads on a filled bubble
/// and a bare one alike.
class _LinkPreview extends StatelessWidget {
  const _LinkPreview({
    required this.preview,
    required this.ring,
    required this.ink,
    required this.em,
    required this.locale,
  });

  final NebaChatBubbleLinkPreview preview;
  final Color ring;
  final Color ink;
  final double em;
  final Locale? locale;

  /// The height of the share image.
  static const double imageHeight = 112;

  Color _ink(double amount) => ink.withValues(alpha: ink.a * amount);

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.sm]!);
    final Duration duration = nebaDuration(context, NebaScale.duration);
    final ImageProvider? image = preview.image;
    final Widget? site = preview.site;
    final Widget? title = preview.title;
    final Widget? description = preview.description;
    final bool enabled = preview.onPressed != null;
    final String? notice = preview.newTab
        ? nebaMessages(context, 'link', locale: locale)['newTab']
        : null;

    return Semantics(
      container: true,
      link: enabled,
      linkUrl: enabled ? nebaSafeHref(preview.url) : null,
      child: NebaInteractive(
        onTap: preview.onPressed,
        enabled: enabled,
        activatesOnSpace: false,
        builder: (BuildContext context, NebaInteraction interaction, _) {
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            borderRadius: radius,
            child: AnimatedContainer(
              duration: duration,
              curve: NebaScale.ease,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _ink(interaction.hovered ? 0.12 : 0.07),
                border: Border.all(color: _ink(0.18)),
                borderRadius: radius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (image != null)
                    SizedBox(
                      height: imageHeight,
                      // Decorative: what the picture says is written under it.
                      child: Image(image: image, fit: BoxFit.cover, excludeFromSemantics: true),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: <Widget>[
                        if (site != null)
                          DefaultTextStyle.merge(
                            style: TextStyle(fontSize: em * 0.85, color: _ink(0.7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: <Widget>[
                                ExcludeSemantics(
                                  child: NebaGlyph(
                                    NebaGlyphs.link,
                                    size: em * 0.85,
                                    color: _ink(0.7),
                                  ),
                                ),
                                Flexible(child: site),
                              ],
                            ),
                          ),
                        if (title != null)
                          DefaultTextStyle.merge(
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            child: title,
                          ),
                        if (description != null)
                          DefaultTextStyle.merge(
                            style: TextStyle(fontSize: em * 0.9, color: _ink(0.8)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            child: description,
                          ),
                        // Read to everybody and drawn for nobody.
                        if (notice != null)
                          Semantics(label: notice, child: const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
