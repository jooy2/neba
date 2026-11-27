/// `NebaGallery`, a set of pictures arranged as a contact sheet, a masonry, a
/// justified library or a quilt, with a viewer a press away.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/components/image/neba_image.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/picture.dart';
import 'package:neba/src/internal/viewer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How a [NebaGallery]'s tiles are arranged. Four answers to four different
/// questions rather than four looks.
enum NebaGalleryLayout {
  /// A contact sheet: every tile the gallery's own `ratio`, whatever shape
  /// the files are.
  grid,

  /// Each picture in its own proportion, dealt into the shortest of the
  /// columns.
  masonry,

  /// Each picture in its own proportion, every row filled to the edge at a
  /// common height: nothing cropped and no space left over.
  justified,

  /// A grid whose tiles may take more than one cell.
  quilted,
}

/// What a [NebaGallery] tile does under the pointer, and under the keyboard
/// focus.
enum NebaGalleryHover {
  /// Nothing.
  none,

  /// The tile rises to elevation 2.
  lift,

  /// The picture darkens.
  dim,

  /// The photograph scales up inside a frame that clips it and never moves.
  zoom,
}

/// Where a [NebaGallery] tile's words go.
enum NebaGalleryCaption {
  /// Nowhere: they are still in the viewer, and the `alt` is the tile's name.
  none,

  /// Under the picture.
  below,

  /// Across the foot of the picture, on a gradient.
  overlay,

  /// [overlay], arriving with the pointer or the keyboard focus, and always
  /// there on a screen with no mouse to hover with.
  hover,
}

/// One picture in a [NebaGallery], and the metadata that came with it.
@immutable
class NebaGalleryItem {
  /// A picture of [image], described by [alt].
  const NebaGalleryItem({
    required this.image,
    required this.alt,
    this.id,
    this.title,
    this.description,
    this.full,
    this.ratio,
    this.rotate = 0,
    this.flip = NebaImageFlip.none,
    this.position,
    this.placeholder,
    this.cols = 1,
    this.rows = 1,
  }) : assert(ratio == null || ratio > 0),
       assert(cols >= 1 && rows >= 1);

  /// The picture.
  final ImageProvider image;

  /// What the picture says. Required for the reason `NebaImage` requires it.
  final String alt;

  /// A stable identity. Defaults to [image].
  final Object? id;

  /// The first line of the caption, and the viewer's heading.
  final String? title;

  /// The second line, one step down the scale and muted.
  final String? description;

  /// A larger file for the viewer, when [image] is a thumbnail.
  final ImageProvider? full;

  /// The picture's own proportion, width over height, as the file is stored.
  /// A masonry and a justified wall are laid out from it before anything has
  /// arrived, which is the whole reason it is data rather than a
  /// measurement. Without it the item takes the gallery's `ratio`.
  final double? ratio;

  /// Turns the picture clockwise, a quarter at a time, here and in the
  /// viewer. An item with a [ratio] is laid out on its side.
  final int rotate;

  /// Mirrors the picture, here and in the viewer.
  final NebaImageFlip flip;

  /// Which part of the picture a tile keeps when it crops, or where the
  /// space goes when it does not.
  final Alignment? position;

  /// What stands in while the tile's file arrives, instead of a Skeleton:
  /// usually a small copy of the picture.
  final NebaImagePlaceholder? placeholder;

  /// How many columns the tile takes in [NebaGalleryLayout.quilted].
  final int cols;

  /// How many rows the tile takes in [NebaGalleryLayout.quilted].
  final int rows;
}

/// Called with an item and where it is in the list.
typedef NebaGalleryItemCallback = void Function(NebaGalleryItem item, int index);

/// A set of pictures, arranged.
///
/// The four layouts are the widget: the captions, the pointer treatment and
/// the viewer are the same in all of them, and choosing between a contact
/// sheet, a masonry, a justified library and a quilt is one argument rather
/// than four widgets.
///
/// None of them measures a picture. A tile's shape comes from the item's own
/// `ratio`, so the whole arrangement is right in the first frame and does not
/// move as the files arrive.
///
/// ```dart
/// NebaGallery(
///   items: photos,
///   layout: NebaGalleryLayout.justified,
///   caption: NebaGalleryCaption.hover,
///   preview: true,
/// )
/// ```
class NebaGallery extends StatefulWidget {
  /// A gallery of [items].
  const NebaGallery({
    required this.items,
    this.layout = NebaGalleryLayout.grid,
    this.columns,
    this.gap,
    this.ratio = 1,
    this.rowHeight = 220,
    this.rounded = NebaSize.md,
    this.fit = BoxFit.cover,
    this.letterbox = NebaImageLetterbox.none,
    this.priority = 0,
    this.caption = NebaGalleryCaption.none,
    this.hover = NebaGalleryHover.lift,
    this.preview = false,
    this.onItemSelect,
    this.filter = NebaImageFilter.none,
    this.frame,
    this.watermark,
    this.protect = false,
    this.label,
    this.locale,
    this.empty,
    super.key,
  }) : assert(columns == null || columns > 0),
       assert(gap == null || gap >= 0),
       assert(ratio > 0),
       assert(rowHeight > 0),
       assert(priority >= 0);

  /// The pictures, in the order they are drawn, read and tabbed through.
  final List<NebaGalleryItem> items;

  /// How the tiles are arranged.
  final NebaGalleryLayout layout;

  /// How many tiles across, in a grid, a masonry and a quilt; a justified
  /// wall decides for itself, row by row. Defaults to two in a window below
  /// [NebaBreakpoint.sm], three from it and four from [NebaBreakpoint.lg].
  final int? columns;

  /// The space between tiles, in logical pixels. Defaults to the `md` step
  /// of [gaps], 8.
  final double? gap;

  /// The shape of a tile in a grid, width over height, and what an item with
  /// no ratio of its own falls back to everywhere else.
  final double ratio;

  /// How tall a justified row aims to be, and how tall one cell of a quilt
  /// is, in logical pixels.
  final double rowHeight;

  /// Rounds the tiles at this step of the radius ladder; `null` for square.
  final NebaSize? rounded;

  /// How a picture fills its tile.
  final BoxFit fit;

  /// What fills the space [fit] leaves, on every tile.
  final NebaImageLetterbox letterbox;

  /// How many tiles, counted from the first item, are pictures the screen is
  /// judged by: drawn with no fade and no Skeleton.
  final int priority;

  /// Where a tile's title and description go.
  final NebaGalleryCaption caption;

  /// What a tile does under the pointer and the keyboard focus.
  final NebaGalleryHover hover;

  /// Opens the picture full size when a tile is pressed, with the rest of the
  /// set an arrow key away. Needs an [Overlay] above it.
  final bool preview;

  /// Called when a tile is chosen, whether or not there is a viewer. It is
  /// what makes a tile something to press.
  final NebaGalleryItemCallback? onItemSelect;

  /// Passed to every tile's picture.
  final NebaImageFilter filter;

  /// Passed to every tile's picture.
  final NebaImageFrame? frame;

  /// Passed to every tile's picture, and to the viewer.
  final NebaImageWatermark? watermark;

  /// Passed to every tile's picture, and to the viewer.
  final bool protect;

  /// The list's name. Defaults to the [locale]'s word for a gallery.
  final String? label;

  /// The language the list, the tiles' places and the viewer's buttons are
  /// named in. Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// What is drawn when [items] is empty. Nothing at all by default.
  final Widget? empty;

  /// The gap ladder, the React package's `gap` steps, in logical pixels.
  static const Map<NebaSize, double> gaps = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 8,
    NebaSize.lg: 12,
    NebaSize.xl: 16,
  };

  /// How far a `zoom` scales the photograph.
  static const double zoomScale = 1.06;

  /// How far a `dim` darkens the picture, CSS `brightness(0.82)`.
  static const double dimBrightness = 0.82;

  @override
  State<NebaGallery> createState() => _NebaGalleryState();
}

class _NebaGalleryState extends State<NebaGallery> {
  /// Which picture the viewer shows, or `null` while it is closed.
  int? _openAt;

  /// The picture the viewer last showed, kept while it fades out.
  int _shownAt = 0;

  /// Whether a mouse has been seen, which a `hover` caption waits for on a
  /// phone or a tablet: on a screen with none it is simply an overlay.
  bool _mouse = RendererBinding.instance.mouseTracker.mouseIsConnected;

  /// Whether the screen can hover, CSS `(hover: hover)`: a desktop can from
  /// the first frame, before its mouse has moved, and a phone or a tablet
  /// can once a mouse or a trackpad is used on it.
  bool get _canHover {
    return _mouse ||
        switch (defaultTargetPlatform) {
          TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux => true,
          TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
        };
  }

  @override
  void initState() {
    super.initState();
    RendererBinding.instance.mouseTracker.addListener(_onMouse);
  }

  @override
  void dispose() {
    RendererBinding.instance.mouseTracker.removeListener(_onMouse);
    super.dispose();
  }

  void _onMouse() {
    final bool mouse = RendererBinding.instance.mouseTracker.mouseIsConnected;

    if (mouse != _mouse && mounted) {
      setState(() => _mouse = mouse);
    }
  }

  void _choose(int index) {
    widget.onItemSelect?.call(widget.items[index], index);

    if (widget.preview) {
      setState(() {
        _openAt = index;
        _shownAt = index;
      });
    }
  }

  void _go(int to) {
    if (to >= 0 && to < widget.items.length && _openAt != null) {
      setState(() {
        _openAt = to;
        _shownAt = to;
      });
    }
  }

  void _close() {
    if (_openAt != null) {
      setState(() => _openAt = null);
    }
  }

  int _columns(BuildContext context) {
    final int? columns = widget.columns;

    if (columns != null) {
      return columns;
    }

    final double width = MediaQuery.sizeOf(context).width;

    return width >= NebaBreakpoint.lg.width
        ? 4
        : width >= NebaBreakpoint.sm.width
        ? 3
        : 2;
  }

  @override
  Widget build(BuildContext context) {
    final List<NebaGalleryItem> items = widget.items;
    final Widget? empty = widget.empty;

    if (items.isEmpty && empty != null) {
      return empty;
    }

    final Map<String, String> messages = nebaMessages(context, 'gallery', locale: widget.locale);
    final double fallback = widget.ratio;
    // Each tile keyed by its item's identity, so a tile keeps its picture when
    // the list is reordered; a picture that is in the set twice is told apart
    // by how many times it has come up, rather than failing on a duplicate.
    final Map<Object, int> seen = <Object, int>{};
    final List<Key> keys = <Key>[
      for (final NebaGalleryItem item in items)
        ValueKey<(Object, int)>((
          item.id ?? item.image,
          seen.update(item.id ?? item.image, (int count) => count + 1, ifAbsent: () => 0),
        )),
    ];

    final Widget list = Semantics(
      container: true,
      role: SemanticsRole.list,
      label: widget.label ?? messages['label'],
      explicitChildNodes: true,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: _GalleryLayout(
          layout: widget.layout,
          columns: _columns(context),
          gap: widget.gap ?? NebaGallery.gaps[NebaSize.md]!,
          rowHeight: widget.rowHeight,
          ratios: <double>[for (final NebaGalleryItem item in items) _shownRatio(item, fallback)],
          spans: <(int, int)>[for (final NebaGalleryItem item in items) (item.cols, item.rows)],
          textDirection: Directionality.of(context),
          children: <Widget>[
            for (int index = 0; index < items.length; index++)
              _Tile(
                key: keys[index],
                gallery: widget,
                index: index,
                messages: messages,
                canHover: _canHover,
                onChoose: _choose,
              ),
          ],
        ),
      ),
    );

    if (!widget.preview) {
      return list;
    }

    return NebaModalLayer(
      open: _openAt != null,
      onDismiss: _close,
      builder: (BuildContext context, Animation<double> arrival) {
        return _viewer(context, arrival, messages);
      },
      child: list,
    );
  }

  Widget _viewer(BuildContext context, Animation<double> arrival, Map<String, String> messages) {
    final List<NebaGalleryItem> items = widget.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final NebaTokens tokens = NebaTheme.of(context);
    final int index = math.min(_openAt ?? _shownAt, items.length - 1);
    final NebaGalleryItem item = items[index];
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool several = items.length > 1;
    final String name = item.title ?? item.alt;
    final String counter = fillNebaMessage(messages['item']!, <String, String>{
      'index': '${index + 1}',
      'total': '${items.length}',
    });
    final Map<String, String> image = nebaMessages(context, 'image', locale: widget.locale);

    Widget arrow({required bool forward}) {
      final bool inert = forward ? index >= items.length - 1 : index <= 0;
      final int turns = forward ? (rtl ? 1 : 3) : (rtl ? 3 : 1);

      return NebaIconButton(
        variant: NebaVariant.solid,
        elevation: 1,
        label: forward ? messages['next']! : messages['previous']!,
        disabled: inert,
        // A press that reaches the first picture runs the button out, and a
        // disabled button that let the focus go would hand it to nothing.
        focusableWhenDisabled: true,
        icon: RotatedBox(quarterTurns: turns, child: NebaGlyph(NebaGlyphs.chevron)),
        onPressed: () => _go(index + (forward ? 1 : -1)),
      );
    }

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: <Widget>[
        // At least as tall as the arrows, so they can be pressed before the
        // picture is in, or when it never arrives.
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: NebaScale.controlHeight[NebaSize.md]!),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Center(
                child: NebaViewerPicture(
                  // Keyed on the picture, so moving to the next one starts its
                  // own arrival rather than showing the last file under a new
                  // heading.
                  key: ValueKey<Object>(item.id ?? item.image),
                  image: item.full ?? item.image,
                  alt: item.alt,
                  unavailableLabel: image['unavailable']!,
                  quarters: nebaQuarters(item.rotate),
                  flip: item.flip,
                  watermark: widget.watermark,
                  protect: widget.protect,
                  borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
                ),
              ),
              if (several)
                Positioned(
                  left: 4,
                  right: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[arrow(forward: false), arrow(forward: true)],
                  ),
                ),
            ],
          ),
        ),
        if (several)
          NebaLiveRegion(
            role: SemanticsRole.status,
            // Said when it changes, so an arrow key says where it landed and
            // what the picture is to a reader who cannot see it.
            child: Semantics(
              label: '$name, $counter',
              child: ExcludeSemantics(
                child: Text(
                  counter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: NebaScale.metaText[NebaSize.md],
                    color: tokens.mutedFg,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return nebaViewerSurface(
      arrival,
      // The arrows are bound on the sheet rather than on the buttons, because
      // the focus is wherever the reader last put it, and a key that worked
      // from one place only would look broken from the others. They point the
      // way they go, so under RTL the left arrow is the next picture.
      CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(index + (rtl ? 1 : -1)),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(index + (rtl ? -1 : 1)),
        },
        child: NebaViewerSheet(
          title: name,
          description: item.description,
          closeLabel: nebaMessages(context, 'action', locale: widget.locale)['close']!,
          onClose: _close,
          child: body,
        ),
      ),
    );
  }
}

/// Whether an item is turned onto its side.
bool _sideways(NebaGalleryItem item) => nebaQuarters(item.rotate).isOdd;

/// The shape an item is drawn in: its own ratio, on its side when it is
/// turned. An item with no ratio takes the gallery's, which is the layout's
/// shape and has nothing to turn.
double _shownRatio(NebaGalleryItem item, double fallback) {
  final double? own = item.ratio;

  if (own == null) {
    return fallback;
  }

  return _sideways(item) ? 1 / own : own;
}

/// One tile: the picture in a frame that clips it, its caption, and the
/// button it is when there is something to press.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.gallery,
    required this.index,
    required this.messages,
    required this.canHover,
    required this.onChoose,
    super.key,
  });

  final NebaGallery gallery;
  final int index;
  final Map<String, String> messages;
  final bool canHover;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaGalleryItem item = gallery.items[index];
    final NebaGalleryCaption caption = gallery.caption;
    final bool words = item.title != null || item.description != null;
    final bool shown = caption != NebaGalleryCaption.none && words;
    final bool over = caption == NebaGalleryCaption.overlay || caption == NebaGalleryCaption.hover;
    final bool pressable = gallery.preview || gallery.onItemSelect != null;
    final bool quilted = gallery.layout == NebaGalleryLayout.quilted;
    final BorderRadius radius = BorderRadius.circular(
      gallery.rounded == null ? 0 : tokens.radius[gallery.rounded]!,
    );
    final String place = fillNebaMessage(messages['item']!, <String, String>{
      'index': '${index + 1}',
      'total': '${gallery.items.length}',
    });

    // A grid is a contact sheet, so every tile takes the gallery's ratio
    // whatever shape the file is; a quilt takes neither, since the cells it
    // spans have already decided; the other two keep the picture's own.
    final double? ratio = switch (gallery.layout) {
      NebaGalleryLayout.grid => gallery.ratio,
      NebaGalleryLayout.quilted => null,
      _ => _shownRatio(item, gallery.ratio),
    };

    final Widget picture = NebaImage(
      image: item.image,
      alt: item.alt,
      ratio: ratio,
      fit: gallery.fit,
      position: item.position,
      letterbox: gallery.letterbox,
      rotate: item.rotate,
      flip: item.flip,
      placeholder: item.placeholder,
      priority: index < gallery.priority,
      filter: gallery.filter,
      frame: gallery.frame,
      watermark: gallery.watermark,
      protect: gallery.protect,
      locale: gallery.locale,
    );

    Widget tile = NebaInteractive(
      onTap: pressable ? () => onChoose(index) : null,
      focusable: pressable,
      cursor: pressable
          ? (gallery.preview ? SystemMouseCursors.zoomIn : SystemMouseCursors.click)
          : MouseCursor.defer,
      builder: (BuildContext context, NebaInteraction interaction, _) {
        // Every pointer treatment is a focus treatment too.
        final bool active = interaction.hovered || interaction.focusVisible;
        final NebaGalleryHover hover = gallery.hover;

        Widget treated = picture;

        if (hover == NebaGalleryHover.zoom || hover == NebaGalleryHover.dim) {
          treated = NebaPictureTreatment(
            scale: hover == NebaGalleryHover.zoom && active ? NebaGallery.zoomScale : 1,
            brightness: hover == NebaGalleryHover.dim && active ? NebaGallery.dimBrightness : 1,
            child: treated,
          );
        }

        // The frame the picture is clipped to, and the only thing a zoom is
        // allowed to move inside.
        Widget framed = Stack(
          fit: quilted ? StackFit.expand : StackFit.loose,
          children: <Widget>[
            treated,
            if (shown && over)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _Caption(
                  item: item,
                  over: true,
                  visible: caption == NebaGalleryCaption.overlay || active || !canHover,
                ),
              ),
          ],
        );

        framed = ClipRRect(borderRadius: radius, child: framed);

        if (hover == NebaGalleryHover.lift) {
          framed = AnimatedContainer(
            duration: nebaDuration(context, NebaScale.duration),
            curve: NebaScale.ease,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: tokens.elevation(active ? 2 : 0),
            ),
            child: framed,
          );
        }

        final Widget body = Column(
          mainAxisSize: quilted ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (quilted) Expanded(child: framed) else framed,
            if (shown && !over) _Caption(item: item, over: false, visible: true),
          ],
        );

        if (!pressable) {
          return body;
        }

        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: tokens.roles(NebaColor.primary).ring,
          borderRadius: radius,
          // The button says its own name, so what is drawn inside it is not
          // read a second time.
          child: ExcludeSemantics(child: body),
        );
      },
    );

    if (pressable) {
      // Named by the caption drawn on it and its place in the set when there
      // is one, so a voice-control user can say the words on the tile to
      // press it, and by the picture's own alt when there is none.
      final String name = shown
          ? '${item.title ?? item.description} $place'
          : '${item.alt} — $place';

      tile = FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: Semantics(
          container: true,
          button: true,
          label: name,
          hint: shown && item.title != null ? item.description : null,
          child: tile,
        ),
      );
    }

    return Semantics(
      container: true,
      role: SemanticsRole.listItem,
      // In the order the items were given, whichever column a masonry dealt
      // a tile into.
      sortKey: OrdinalSortKey(index.toDouble()),
      child: tile,
    );
  }
}

/// A tile's title over its description: under the picture, or across the
/// foot of it on a gradient that keeps white words readable over a pale
/// photograph.
class _Caption extends StatelessWidget {
  const _Caption({required this.item, required this.over, required this.visible});

  final NebaGalleryItem item;
  final bool over;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final String? title = item.title;
    final String? description = item.description;
    final double titleSize = NebaScale.sheetTitleText[NebaSize.sm]!;

    final Widget words = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        if (title != null)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              height: NebaScale.sheetTitleLeading[NebaSize.sm]! / titleSize,
              fontWeight: FontWeight.w500,
              color: over ? const Color(0xFFFFFFFF) : tokens.fg,
            ),
          ),
        if (description != null)
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: NebaScale.metaText[NebaSize.md],
              color: over ? const Color(0xCCFFFFFF) : tokens.mutedFg,
            ),
          ),
      ],
    );

    if (!over) {
      return Padding(padding: const EdgeInsets.only(top: 6), child: words);
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: nebaDuration(context, NebaScale.durationFill),
        curve: NebaScale.ease,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[Color(0xB8000000), Color(0x00000000)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(width: double.infinity, child: words),
          ),
        ),
      ),
    );
  }
}

/// The four arrangements, laid out by one render object: a tile's width
/// comes from the gallery's width and its height from what is in it, which
/// a widget made of rows and columns could only learn by measuring twice.
class _GalleryLayout extends MultiChildRenderObjectWidget {
  const _GalleryLayout({
    required this.layout,
    required this.columns,
    required this.gap,
    required this.rowHeight,
    required this.ratios,
    required this.spans,
    required this.textDirection,
    required super.children,
  });

  final NebaGalleryLayout layout;
  final int columns;
  final double gap;
  final double rowHeight;
  final List<double> ratios;
  final List<(int, int)> spans;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGallery(
      layout: layout,
      columns: columns,
      gap: gap,
      rowHeight: rowHeight,
      ratios: ratios,
      spans: spans,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderGallery renderObject) {
    renderObject
      ..arrangement = layout
      ..columns = columns
      ..gap = gap
      ..rowHeight = rowHeight
      ..ratios = ratios
      ..spans = spans
      ..textDirection = textDirection;
  }
}

class _GalleryParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderGallery extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GalleryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GalleryParentData> {
  _RenderGallery({
    required NebaGalleryLayout layout,
    required int columns,
    required double gap,
    required double rowHeight,
    required List<double> ratios,
    required List<(int, int)> spans,
    required TextDirection textDirection,
  }) : _layout = layout,
       _columns = columns,
       _gap = gap,
       _rowHeight = rowHeight,
       _ratios = ratios,
       _spans = spans,
       _textDirection = textDirection;

  NebaGalleryLayout _layout;
  set arrangement(NebaGalleryLayout value) {
    if (value != _layout) {
      _layout = value;
      markNeedsLayout();
    }
  }

  int _columns;
  set columns(int value) {
    if (value != _columns) {
      _columns = value;
      markNeedsLayout();
    }
  }

  double _gap;
  set gap(double value) {
    if (value != _gap) {
      _gap = value;
      markNeedsLayout();
    }
  }

  double _rowHeight;
  set rowHeight(double value) {
    if (value != _rowHeight) {
      _rowHeight = value;
      markNeedsLayout();
    }
  }

  List<double> _ratios;
  set ratios(List<double> value) {
    if (!listEquals(value, _ratios)) {
      _ratios = value;
      markNeedsLayout();
    }
  }

  List<(int, int)> _spans;
  set spans(List<(int, int)> value) {
    if (!listEquals(value, _spans)) {
      _spans = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GalleryParentData) {
      child.parentData = _GalleryParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _arrange(constraints, ChildLayoutHelper.dryLayoutChild, place: false);
  }

  @override
  void performLayout() {
    size = _arrange(constraints, ChildLayoutHelper.layoutChild, place: true);
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) {
    return _arrange(
      BoxConstraints(maxWidth: width),
      ChildLayoutHelper.dryLayoutChild,
      place: false,
    ).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  /// Lays every tile out with [layoutChild] and, when [place] is set, writes
  /// where each one goes. Returns the gallery's size.
  Size _arrange(BoxConstraints constraints, ChildLayouter layoutChild, {required bool place}) {
    final List<RenderBox> children = getChildrenAsList();
    final double width = constraints.hasBoundedWidth ? constraints.maxWidth : 0;
    final int count = children.length;
    final double gap = _gap;
    final List<Rect> slots = List<Rect>.filled(count, Rect.zero);

    if (count == 0) {
      return constraints.constrain(Size(width, 0));
    }

    final int columns = math.max(1, _columns);
    final double cell = math.max(0, (width - gap * (columns - 1)) / columns);
    double height = 0;

    switch (_layout) {
      case NebaGalleryLayout.grid:
        double y = 0;

        for (int start = 0; start < count; start += columns) {
          double row = 0;

          for (int column = 0; column < columns && start + column < count; column++) {
            final Size size = layoutChild(
              children[start + column],
              BoxConstraints.tightFor(width: cell),
            );
            slots[start + column] = Offset(column * (cell + gap), y) & size;
            row = math.max(row, size.height);
          }

          y += row;
          height = y;
          y += gap;
        }

      case NebaGalleryLayout.masonry:
        // Dealt into the shortest column, by the ratios rather than anything
        // measured, so the first row is the first items in the order they
        // were given and nothing moves as the files arrive.
        final List<double> dealt = List<double>.filled(columns, 0);
        final List<double> drawn = List<double>.filled(columns, 0);
        final List<bool> started = List<bool>.filled(columns, false);

        for (int index = 0; index < count; index++) {
          int lane = 0;

          for (int other = 1; other < columns; other++) {
            if (dealt[other] < dealt[lane]) {
              lane = other;
            }
          }

          dealt[lane] += 1 / _ratioAt(index);

          final Size size = layoutChild(children[index], BoxConstraints.tightFor(width: cell));
          final double y = started[lane] ? drawn[lane] + gap : 0;
          slots[index] = Offset(lane * (cell + gap), y) & size;
          started[lane] = true;
          drawn[lane] = y + size.height;
          height = math.max(height, drawn[lane]);
        }

      case NebaGalleryLayout.justified:
        height = _justify(children, width, layoutChild, slots);

      case NebaGalleryLayout.quilted:
        final List<List<bool>> taken = <List<bool>>[];
        int rowsUsed = 0;

        bool free(int row, int column, int across, int down) {
          for (int r = row; r < row + down; r++) {
            while (taken.length <= r) {
              taken.add(List<bool>.filled(columns, false));
            }

            for (int c = column; c < column + across; c++) {
              if (taken[r][c]) {
                return false;
              }
            }
          }

          return true;
        }

        for (int index = 0; index < count; index++) {
          final int across = math.min(columns, math.max(1, _spanAt(index).$1));
          final int down = math.max(1, _spanAt(index).$2);
          int row = 0;
          int column = 0;

          // Dense: every tile takes the first place it fits, searching from
          // the start, so a small tile fills a hole a large one left.
          search:
          for (row = 0; ; row++) {
            for (column = 0; column + across <= columns; column++) {
              if (free(row, column, across, down)) {
                break search;
              }
            }
          }

          for (int r = row; r < row + down; r++) {
            for (int c = column; c < column + across; c++) {
              taken[r][c] = true;
            }
          }

          rowsUsed = math.max(rowsUsed, row + down);

          final Size size = Size(
            across * cell + (across - 1) * gap,
            down * _rowHeight + (down - 1) * gap,
          );
          layoutChild(children[index], BoxConstraints.tight(size));
          slots[index] = Offset(column * (cell + gap), row * (_rowHeight + gap)) & size;
        }

        height = rowsUsed == 0 ? 0 : rowsUsed * _rowHeight + (rowsUsed - 1) * gap;
    }

    if (place) {
      final bool rtl = _textDirection == TextDirection.rtl;

      for (int index = 0; index < count; index++) {
        final Rect slot = slots[index];
        final _GalleryParentData data = children[index].parentData! as _GalleryParentData;
        data.offset = rtl ? Offset(width - slot.right, slot.top) : slot.topLeft;
      }
    }

    return constraints.constrain(Size(width, height));
  }

  double _ratioAt(int index) {
    final double ratio = index < _ratios.length ? _ratios[index] : 1;

    return ratio > 0 ? ratio : 1;
  }

  (int, int) _spanAt(int index) => index < _spans.length ? _spans[index] : (1, 1);

  /// Rows filled to the edge, the way a CSS row that wraps fills them: each
  /// tile starts at the row height in its own proportion, as many as fit go
  /// in a row, and the row grows each of them by its proportion until it
  /// reaches the edge, which keeps every tile in it the same height. The last
  /// row keeps its tiles at the row height unless it is already as full as
  /// the others, so two pictures left over are not stretched across the page.
  double _justify(
    List<RenderBox> children,
    double width,
    ChildLayouter layoutChild,
    List<Rect> slots,
  ) {
    final int count = children.length;
    final double gap = _gap;
    final List<List<int>> lines = <List<int>>[];
    List<int> line = <int>[];
    double used = 0;

    double basis(int index) => math.min(_ratioAt(index) * _rowHeight, width);

    for (int index = 0; index < count; index++) {
      final double next = (line.isEmpty ? 0 : used + gap) + basis(index);

      if (line.isNotEmpty && next > width) {
        lines.add(line);
        line = <int>[];
        used = 0;
      }

      used = (line.isEmpty ? 0 : used + gap) + basis(index);
      line.add(index);
    }

    // What React's empty last item does: it fits beside the last row when
    // there is a gap's room left, and then takes all the row's free space.
    final bool lastHeld = line.isNotEmpty && used + gap <= width;

    if (line.isNotEmpty) {
      lines.add(line);
    }

    double y = 0;
    double height = 0;

    for (int which = 0; which < lines.length; which++) {
      final List<int> row = lines[which];
      final bool grows = !(which == lines.length - 1 && lastHeld);
      double taken = gap * (row.length - 1);
      double weight = 0;

      for (final int index in row) {
        taken += basis(index);
        weight += _ratioAt(index);
      }

      final double free = grows ? math.max(0, width - taken) : 0;
      double x = 0;
      double tallest = 0;

      for (final int index in row) {
        final double tileWidth = math.min(width, basis(index) + free * _ratioAt(index) / weight);
        final Size size = layoutChild(children[index], BoxConstraints.tightFor(width: tileWidth));
        slots[index] = Offset(x, y) & size;
        x += tileWidth + gap;
        tallest = math.max(tallest, size.height);
      }

      y += tallest;
      height = y;
      y += gap;
    }

    return height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
