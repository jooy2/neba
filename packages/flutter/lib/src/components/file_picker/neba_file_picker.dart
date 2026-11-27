/// `NebaFilePicker`, a box files are dropped on or picked into.
library;

import 'dart:ui' show PathMetric, SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A file a [NebaFilePicker] holds: what it says about the file, and the
/// app's own handle on it.
///
/// The widgets layer has no file of its own, and a picker reads only the
/// three things it checks and lists: the [name], the [size] and the [type].
/// Whatever the app picked or was dropped, a path, the bytes or a plugin's
/// file object, travels along as [data].
@immutable
class NebaFile {
  /// A file called [name], [size] bytes long.
  const NebaFile({
    required this.name,
    required this.size,
    this.type = '',
    this.lastModified,
    this.data,
  }) : assert(size >= 0);

  /// The file's name, with its extension.
  final String name;

  /// How long the file is, in bytes.
  final int size;

  /// The file's media type, `image/png`, or empty when it is not known.
  final String type;

  /// When the file was last changed, when that is known.
  final DateTime? lastModified;

  /// The app's own handle on the file. The picker never reads it.
  final Object? data;

  @override
  String toString() => 'NebaFile($name, $size bytes)';
}

/// Why a file was turned away. One reason per file, in the order they are
/// checked.
enum NebaFileRejectionReason {
  /// It does not match `accept`.
  type,

  /// It is larger than `maxSize`.
  size,

  /// The picker already holds as many files as it may.
  count,
}

/// A file a [NebaFilePicker] turned away, and why.
@immutable
class NebaFileRejection {
  /// [file], turned away for [reason].
  const NebaFileRejection({required this.file, required this.reason});

  /// The file.
  final NebaFile file;

  /// Why it was turned away.
  final NebaFileRejectionReason reason;

  @override
  String toString() => 'NebaFileRejection(${file.name}, ${reason.name})';
}

/// `1.4 MB`, in the units a person reading a file list expects: base 1000
/// rather than 1024, and `MB` rather than `MiB`, the number every operating
/// system's file browser shows.
String nebaFormatFileSize(int bytes) {
  if (bytes < 1000) {
    return '$bytes B';
  }

  const List<String> units = <String>['kB', 'MB', 'GB', 'TB'];
  double value = bytes / 1000;
  int unit = 0;

  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit += 1;
  }

  return '${value < 10 ? value.toStringAsFixed(1) : value.round()} ${units[unit]}';
}

/// Whether [file] matches an `accept` string: `.ext`, `type/subtype` or
/// `type/*`, comma-separated, as the attribute takes them.
bool _matchesAccept(NebaFile file, String accept) {
  final String name = file.name.toLowerCase();
  final String type = file.type.toLowerCase();

  return accept
      .split(',')
      .map((String entry) => entry.trim().toLowerCase())
      .where((String entry) => entry.isNotEmpty)
      .any((String entry) {
        if (entry.startsWith('.')) {
          return name.endsWith(entry);
        }

        if (entry.endsWith('/*')) {
          return type.startsWith(entry.substring(0, entry.length - 1));
        }

        return type == entry;
      });
}

/// The upload glyph, the React package's, in its 16-unit box.
const List<NebaGlyphPart> _upload = <NebaGlyphPart>[
  NebaGlyphPart.stroke(
    'M8 10.5V2.75m0 0L5.25 5.5M8 2.75 10.75 5.5',
    cap: StrokeCap.round,
    join: StrokeJoin.round,
  ),
  NebaGlyphPart.stroke(
    'M2.75 9.75v1.75a1.75 1.75 0 0 0 1.75 1.75h7a1.75 1.75 0 0 0 1.75-1.75V9.75',
    cap: StrokeCap.round,
  ),
];

/// The box's inner padding: its own ladder, because a drop target is sized by
/// the gesture it has to catch rather than by what is written in it.
const Map<NebaDensity, Map<NebaSize, double>> _zonePadding = <NebaDensity, Map<NebaSize, double>>{
  NebaDensity.standard: <NebaSize, double>{
    NebaSize.xs: 16,
    NebaSize.sm: 20,
    NebaSize.md: 24,
    NebaSize.lg: 32,
    NebaSize.xl: 40,
  },
  NebaDensity.compact: <NebaSize, double>{
    NebaSize.xs: 8,
    NebaSize.sm: 12,
    NebaSize.md: 16,
    NebaSize.lg: 20,
    NebaSize.xl: 24,
  },
};

/// The dashed edge's width.
const double _edgeWidth = 2;

/// A box files are dropped on, or pressed to pick them.
///
/// The widgets layer has neither a file dialog nor a drop target for files
/// from outside the app, and the package takes no plugin, so the files reach
/// the picker from the app: a press on the box calls [onPick], which opens
/// whatever dialog the app uses and hands back what was chosen; a
/// `Draggable` of a [NebaFile] or a list of them, from elsewhere in the app,
/// is taken when it is dropped on the box; and a drop target of the app's own
/// passes what lands on it to [NebaFilePickerState.drop]. Every file is
/// checked the same way whichever way it came, against [accept], [maxSize] and
/// [maxFiles], and what is turned away goes to [onReject].
///
/// ```dart
/// NebaFilePicker(
///   multiple: true,
///   label: const Text('Attachments'),
///   accept: 'image/*,.pdf',
///   onPick: pickWithTheAppsDialog,
///   onFilesChange: (List<NebaFile> files) => attachments = files,
/// )
/// ```
class NebaFilePicker extends StatefulWidget {
  /// A file picker.
  const NebaFilePicker({
    this.onPick,
    this.accept,
    this.multiple = false,
    this.maxSize,
    this.maxFiles,
    this.value,
    this.defaultValue = const <NebaFile>[],
    this.onFilesChange,
    this.onReject,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.title,
    this.hint,
    this.icon,
    this.showIcon = true,
    this.showList = true,
    this.removeLabel,
    this.locale,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.fullWidth = true,
    this.disabled = false,
    this.readOnly = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(maxSize == null || maxSize >= 0),
       assert(maxFiles == null || maxFiles >= 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// Opens the app's file dialog and hands back what was chosen, or `null`
  /// or nothing when it was dismissed. A press on the box, Enter or Space
  /// call it. Without it the box takes only dropped files and is not in the
  /// focus order.
  final Future<List<NebaFile>?> Function()? onPick;

  /// Which files are taken, in the `accept` grammar: `'image/*,.pdf'`. Every
  /// file is checked against it, picked or dropped; hand the same string to
  /// the dialog [onPick] opens so it offers only those.
  final String? accept;

  /// Whether more than one file may be held.
  final bool multiple;

  /// The largest a single file may be, in bytes.
  final int? maxSize;

  /// How many files may be held at once, counted only when [multiple] is on,
  /// and checked against what is already held rather than against one drop.
  final int? maxFiles;

  /// The files, when the caller holds them. Leave it out and the picker
  /// keeps its own, starting from [defaultValue].
  final List<NebaFile>? value;

  /// The files an uncontrolled picker starts with.
  final List<NebaFile> defaultValue;

  /// Called with every file the picker now holds, each time that changes.
  final ValueChanged<List<NebaFile>>? onFilesChange;

  /// Called with everything that was turned away, and why. Without it a
  /// rejected file disappears silently, which is the single worst thing a
  /// drop target does.
  final ValueChanged<List<NebaFileRejection>>? onReject;

  /// Above the box, usually a [Text]. A screen reader hears it before what
  /// the box says, so two pickers on one form are told apart.
  final Widget? label;

  /// Helper text under the box, usually a [Text].
  final Widget? description;

  /// An error under the box, usually a [Text]. Its presence also turns the
  /// picker invalid.
  final Widget? error;

  /// Forces the invalid state without a message. Defaults to whether there
  /// is an [error].
  final bool? invalid;

  /// The line inside the box, usually a [Text]. Defaults to the [locale]'s
  /// sentence.
  final Widget? title;

  /// The line under it, what is accepted, how big and how many.
  final Widget? hint;

  /// The glyph above the title, in place of the upload arrow.
  final Widget? icon;

  /// Whether the box draws a glyph above its title at all: React's
  /// `icon={null}`.
  final bool showIcon;

  /// Lists the held files under the box, each with a way to remove it.
  final bool showList;

  /// What a screen reader names a file's remove button, handed the file's
  /// name. Overrides the [locale]'s words.
  final String Function(String name)? removeLabel;

  /// The language of the box's own words, the line inside it and the remove
  /// buttons. Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The weight of the box. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The type scale and the box's padding. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring, the glyph and the light.
  /// Defaults to [NebaColor.primary]; an invalid picker is
  /// [NebaColor.danger].
  final NebaColor? color;

  /// The box's padding, and nothing else. Defaults to `NebaProvider`'s,
  /// then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the picker is as wide as
  /// what the box says.
  final bool fullWidth;

  /// Grey, out of the focus order, and taking no file.
  final bool disabled;

  /// Shows the files and takes no more, and none can be removed.
  final bool readOnly;

  /// The box's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the box takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaFilePicker> createState() => NebaFilePickerState();
}

/// What a [NebaFilePicker] keeps, and the way into it for a drop target of
/// the app's own.
class NebaFilePickerState extends State<NebaFilePicker> {
  late List<NebaFile> _own = List<NebaFile>.of(widget.defaultValue);
  bool _dragging = false;
  bool _picking = false;
  FocusNode? _ownZoneNode;
  final List<FocusNode> _removeNodes = <FocusNode>[];

  FocusNode get _zoneNode {
    return widget.focusNode ?? (_ownZoneNode ??= FocusNode(debugLabel: 'NebaFilePicker'));
  }

  /// The files the picker holds.
  List<NebaFile> get files => widget.value ?? _own;

  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  bool get _inert => _disabled || widget.readOnly;

  /// Whether a drag carrying files is over the box, which lights its edge.
  /// A drop target of the app's own sets it as a drag enters and leaves; a
  /// [drop] puts it out.
  bool get dragging => _dragging;

  set dragging(bool value) {
    if (value != _dragging) {
      setState(() => _dragging = value);
    }
  }

  /// Takes [dropped], checked as a pick is, and puts the lit edge out. Does
  /// nothing while the picker is disabled or read-only.
  void drop(List<NebaFile> dropped) {
    dragging = false;

    if (!_inert) {
      _add(dropped);
    }
  }

  @override
  void dispose() {
    _ownZoneNode?.dispose();

    for (final FocusNode node in _removeNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _commit(List<NebaFile> next) {
    if (widget.value == null) {
      setState(() => _own = next);
    }

    widget.onFilesChange?.call(next);
  }

  /// Sorts an incoming batch into kept and rejected. The count is checked
  /// against what is already held rather than against the batch: `maxFiles`
  /// is how many the picker may end up with, not how many may arrive at once.
  void _add(List<NebaFile> incoming) {
    final List<NebaFile> held = files;
    final List<NebaFile> kept = <NebaFile>[];
    final List<NebaFileRejection> rejections = <NebaFileRejection>[];
    final int room = widget.multiple ? (widget.maxFiles ?? -1) : 1;
    final int already = widget.multiple ? held.length : 0;
    final String? accept = widget.accept;
    final int? maxSize = widget.maxSize;

    for (final NebaFile file in incoming) {
      if (accept != null && !_matchesAccept(file, accept)) {
        rejections.add(NebaFileRejection(file: file, reason: NebaFileRejectionReason.type));
      } else if (maxSize != null && file.size > maxSize) {
        rejections.add(NebaFileRejection(file: file, reason: NebaFileRejectionReason.size));
      } else if (room >= 0 && already + kept.length >= room) {
        rejections.add(NebaFileRejection(file: file, reason: NebaFileRejectionReason.count));
      } else {
        kept.add(file);
      }
    }

    if (rejections.isNotEmpty) {
      widget.onReject?.call(rejections);
    }

    if (kept.isNotEmpty) {
      _commit(widget.multiple ? <NebaFile>[...held, ...kept] : kept);
    }
  }

  Future<void> _pick() async {
    final Future<List<NebaFile>?> Function()? onPick = widget.onPick;

    if (onPick == null || _inert || _picking) {
      return;
    }

    _picking = true;

    try {
      final List<NebaFile>? picked = await onPick();

      if (mounted && picked != null && picked.isNotEmpty && !_inert) {
        _add(picked);
      }
    } finally {
      _picking = false;
    }
  }

  /// Takes the file out at [index]. The remove button the focus was on goes
  /// with its row, so the focus moves to the button now in that place, the
  /// one before it when the last went, and the box once nothing is left.
  void _remove(int index) {
    final bool hadFocus = index < _removeNodes.length && _removeNodes[index].hasFocus;
    final List<NebaFile> next = <NebaFile>[...files]..removeAt(index);

    _commit(next);

    if (!hadFocus) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      final int left = files.length;

      if (left == 0) {
        _zoneNode.requestFocus();
      } else {
        _removeNodes[index < left ? index : left - 1].requestFocus();
      }
    });
  }

  /// The files a drag from inside the app carries, or `null` for anything
  /// else.
  static List<NebaFile>? _carried(Object? data) {
    return switch (data) {
      final NebaFile file => <NebaFile>[file],
      final List<NebaFile> list => list,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool invalid = widget.invalid ?? widget.error != null;
    // Invalid re-points the whole family at danger, so the edge, the ring and
    // the message turn over together.
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final Map<String, String> words = nebaMessages(context, 'file', locale: widget.locale);
    final String Function(String name) removeLabel =
        widget.removeLabel ??
        (String name) => fillNebaMessage(words['remove']!, <String, String>{'name': name});
    final List<NebaFile> held = files;
    final double meta = NebaScale.metaText[size]!;

    while (_removeNodes.length < held.length) {
      _removeNodes.add(FocusNode(debugLabel: 'NebaFilePicker remove'));
    }

    while (_removeNodes.length > held.length) {
      // Disposed once the frame that drops the row is done with it.
      final FocusNode gone = _removeNodes.removeLast();

      SchedulerBinding.instance.addPostFrameCallback((Duration _) => gone.dispose());
    }

    final Widget? label = widget.label;
    final Widget? description = widget.description;
    final Widget? error = widget.error;
    final Widget title = widget.title ?? Text(words['title']!);
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      description: description,
      error: error,
    );
    final List<String> named = <String>[?nebaPlainText(label), ?nebaPlainText(title)];

    final Widget zone = DragTarget<Object>(
      onWillAcceptWithDetails: (DragTargetDetails<Object> details) {
        return !_inert && _carried(details.data) != null;
      },
      onAcceptWithDetails: (DragTargetDetails<Object> details) {
        _add(_carried(details.data)!);
      },
      builder: (BuildContext context, List<Object?> candidates, List<dynamic> rejected) {
        return _Zone(
          variant: variant,
          size: size,
          density: density,
          roles: roles,
          elevation: widget.elevation ?? 0,
          disabled: disabled,
          readOnly: readOnly,
          over: !_inert && (_dragging || candidates.isNotEmpty),
          pressable: widget.onPick != null,
          focusNode: _zoneNode,
          autofocus: widget.autofocus,
          onPressed: _pick,
          semanticLabel: named.isEmpty ? null : named.join(' '),
          semanticHint: semantics.hint,
          icon: widget.showIcon ? widget.icon ?? const NebaGlyph(_upload) : null,
          title: title,
          hint: widget.hint,
        );
      },
    );

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: NebaScale.stackGap[size]!,
      children: <Widget>[
        if (label != null)
          ExcludeSemantics(
            excluding: nebaPlainText(label) != null,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: meta,
                fontWeight: FontWeight.w500,
                color: disabled ? tokens.disabledFg : tokens.fg,
              ),
              child: label,
            ),
          ),
        zone,
        if (widget.showList && held.isNotEmpty)
          _FileList(
            files: held,
            size: size,
            roles: roles,
            removable: !_inert,
            removeLabel: removeLabel,
            focusNodes: _removeNodes,
            onRemove: _remove,
          ),
        if (description != null && error == null)
          ExcludeSemantics(
            excluding: semantics.descriptionTaken,
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: meta, color: tokens.mutedFg),
              child: description,
            ),
          ),
        if (error != null)
          ExcludeSemantics(
            excluding: semantics.errorTaken,
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: meta, color: roles.accent),
              child: error,
            ),
          ),
      ],
    );

    return widget.fullWidth ? column : IntrinsicWidth(child: column);
  }
}

/// What the box looks like in one state.
class _ZoneLook {
  const _ZoneLook({
    required this.fill,
    required this.edge,
    required this.ink,
    required this.sheet,
    required this.elevation,
  });

  /// The React package's `zoneRestClasses`, `zoneHoverClasses`,
  /// `zoneOverClasses` and the disabled classes, decided in one place so the
  /// states cannot stack.
  factory _ZoneLook.of({
    required NebaTokens tokens,
    required NebaColorRoles roles,
    required NebaVariant variant,
    required NebaElevation elevation,
    required bool disabled,
    required bool readOnly,
    required bool hovered,
    required bool over,
  }) {
    const Color clear = Color(0x00000000);

    if (disabled) {
      return _ZoneLook(
        fill: variant == NebaVariant.solid ? tokens.disabledBg : clear,
        // A dashed border with no colour of its own takes the text's.
        edge: variant == NebaVariant.outline ? tokens.disabledBorder : tokens.disabledFg,
        ink: tokens.disabledFg,
        sheet: false,
        elevation: 0,
      );
    }

    final bool sheet = variant != NebaVariant.text;
    final bool lit = !readOnly && hovered;

    if (over && !readOnly) {
      return _ZoneLook(
        fill: roles.softPress,
        edge: roles.ring,
        ink: tokens.fg,
        sheet: sheet,
        elevation: sheet ? elevation : 0,
      );
    }

    final Color fill = switch (variant) {
      NebaVariant.solid => lit ? tokens.panelPress : tokens.panelHover,
      NebaVariant.outline => lit ? tokens.panelHover : tokens.panel,
      NebaVariant.text => lit ? roles.soft : clear,
    };

    return _ZoneLook(
      fill: fill,
      edge: lit ? roles.lineHover : roles.line,
      ink: tokens.fg,
      sheet: sheet,
      elevation: sheet ? elevation : 0,
    );
  }

  final Color fill;
  final Color edge;
  final Color ink;

  /// Whether the box is a frosted sheet with the glass plate, as `solid` and
  /// `outline` are, rather than a bare dashed outline.
  final bool sheet;
  final int elevation;
}

/// The box: a frosted sheet with a dashed edge, and the glyph, the title and
/// the hint on it.
class _Zone extends StatelessWidget {
  const _Zone({
    required this.variant,
    required this.size,
    required this.density,
    required this.roles,
    required this.elevation,
    required this.disabled,
    required this.readOnly,
    required this.over,
    required this.pressable,
    required this.focusNode,
    required this.autofocus,
    required this.onPressed,
    required this.semanticLabel,
    required this.semanticHint,
    required this.icon,
    required this.title,
    required this.hint,
  });

  final NebaVariant variant;
  final NebaSize size;
  final NebaDensity density;
  final NebaColorRoles roles;
  final NebaElevation elevation;
  final bool disabled;
  final bool readOnly;
  final bool over;
  final bool pressable;
  final FocusNode focusNode;
  final bool autofocus;
  final VoidCallback onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final Widget? icon;
  final Widget title;
  final Widget? hint;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final double titleSize = NebaScale.sheetTitleText[size]!;
    // 1.8 times the text around the picker, as the React package's `1.8em`
    // reads the font size the box inherits rather than its own.
    final double glyphSize = (DefaultTextStyle.of(context).style.fontSize ?? 14) * 1.8;
    final bool active = pressable && !disabled && !readOnly;
    final Duration duration = nebaDuration(context, NebaScale.duration);
    final Widget? icon = this.icon;
    final Widget? hint = this.hint;

    Widget zone = NebaInteractive(
      enabled: active,
      focusable: pressable && !disabled,
      focusNode: focusNode,
      autofocus: autofocus,
      onTap: onPressed,
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : active
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      builder:
          (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> pointer) {
            final _ZoneLook look = _ZoneLook.of(
              tokens: tokens,
              roles: roles,
              variant: variant,
              elevation: elevation,
              disabled: disabled,
              readOnly: readOnly,
              hovered: interaction.hovered && !disabled,
              over: over,
            );

            // As wide as the box, with what is on it in the middle.
            final Widget content = Container(
              width: double.infinity,
              padding: EdgeInsets.all(_zonePadding[density]![size]! + _edgeWidth),
              child: NebaInk(
                color: look.ink,
                child: DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: NebaScale.gap[size]!,
                    children: <Widget>[
                      if (icon != null)
                        IconTheme.merge(
                          data: IconThemeData(
                            size: glyphSize,
                            color: disabled ? tokens.disabledFg : roles.accent,
                          ),
                          child: ExcludeSemantics(child: icon),
                        ),
                      ExcludeSemantics(
                        excluding: semanticLabel != null,
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: titleSize,
                            height: NebaScale.sheetTitleLeading[size]! / titleSize,
                            fontWeight: FontWeight.w500,
                          ),
                          child: title,
                        ),
                      ),
                      if (hint != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: NebaScale.metaText[size],
                            color: tokens.mutedFg,
                          ),
                          child: hint,
                        ),
                    ],
                  ),
                ),
              ),
            );

            final Widget sheet = look.sheet
                ? NebaSheet(
                    fill: look.fill,
                    plate: NebaPlate.glass,
                    elevation: look.elevation,
                    borderRadius: radius,
                    child: content,
                  )
                : TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: look.fill),
                    duration: duration,
                    curve: NebaScale.ease,
                    builder: (BuildContext context, Color? fill, Widget? child) {
                      return DecoratedBox(
                        decoration: BoxDecoration(color: fill, borderRadius: radius),
                        child: child,
                      );
                    },
                    child: content,
                  );

            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              child: Stack(
                children: <Widget>[
                  sheet,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(end: look.edge),
                        duration: duration,
                        curve: NebaScale.ease,
                        builder: (BuildContext context, Color? edge, Widget? _) {
                          return CustomPaint(
                            painter: _DashedEdge(color: edge ?? look.edge, radius: radius),
                          );
                        },
                      ),
                    ),
                  ),
                  if (!disabled && !readOnly)
                    Positioned.fill(
                      child: NebaGlow(
                        // The spotlight alone: a press opens a dialog, and an
                        // afterglow draining behind it is light nobody sees.
                        interaction: interaction,
                        pointer: pointer,
                        colors: NebaGlowColors(glow: roles.soft, flash: const Color(0x00000000)),
                        borderRadius: radius,
                        afterglow: false,
                      ),
                    ),
                ],
              ),
            );
          },
    );

    if (readOnly) {
      zone = ColorFiltered(colorFilter: ColorFilter.matrix(saturationMatrix(0.55)), child: zone);
    }

    return Semantics(
      container: true,
      button: pressable,
      enabled: pressable ? active : null,
      label: semanticLabel,
      hint: semanticHint,
      child: zone,
    );
  }
}

/// A 2-pixel dashed line inside a rounded rectangle, the CSS
/// `border: 2px dashed`: dashes three times the width long with gaps as long.
class _DashedEdge extends CustomPainter {
  const _DashedEdge({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect outline = radius.toRRect(Offset.zero & size).deflate(_edgeWidth / 2);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _edgeWidth;
    const double dash = _edgeWidth * 3;

    for (final PathMetric metric in (Path()..addRRect(outline)).computeMetrics()) {
      // Spread evenly round the whole edge, so the last gap is no shorter
      // than the others.
      final int count = (metric.length / (2 * dash)).round().clamp(1, 1 << 20);
      final double step = metric.length / count;

      for (int index = 0; index < count; index++) {
        final double start = index * step;

        canvas.drawPath(metric.extractPath(start, start + step / 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedEdge oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}

/// The held files under the box, each with its size and a remove button.
class _FileList extends StatelessWidget {
  const _FileList({
    required this.files,
    required this.size,
    required this.roles,
    required this.removable,
    required this.removeLabel,
    required this.focusNodes,
    required this.onRemove,
  });

  final List<NebaFile> files;
  final NebaSize size;
  final NebaColorRoles roles;
  final bool removable;
  final String Function(String name) removeLabel;
  final List<FocusNode> focusNodes;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.controlText[size]!;
    final double meta = NebaScale.metaText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.xs]!);

    return Semantics(
      role: SemanticsRole.list,
      explicitChildNodes: true,
      child: NebaHitArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: NebaScale.stackGap[size]!,
          children: <Widget>[
            for (int index = 0; index < files.length; index++)
              Semantics(
                role: SemanticsRole.listItem,
                container: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: roles.soft, borderRadius: radius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: text,
                        height: NebaScale.controlLeading[size]! / text,
                        color: tokens.fg,
                      ),
                      child: Row(
                        spacing: 8,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              files[index].name,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            nebaFormatFileSize(files[index].size),
                            style: TextStyle(
                              fontSize: meta,
                              color: tokens.mutedFg,
                              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                            ),
                          ),
                          if (removable)
                            _RemoveButton(
                              label: removeLabel(files[index].name),
                              ring: roles.ring,
                              extent: text * 1.3,
                              glyph: text * 0.9,
                              focusNode: focusNodes[index],
                              onPressed: () => onRemove(index),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A file's ×: drawn at the size of the name beside it, pressed at the size
/// of a finger.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({
    required this.label,
    required this.ring,
    required this.extent,
    required this.glyph,
    required this.focusNode,
    required this.onPressed,
  });

  final String label;
  final Color ring;
  final double extent;
  final double glyph;
  final FocusNode focusNode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: label,
      child: NebaHitTarget(
        child: NebaInteractive(
          onTap: onPressed,
          focusNode: focusNode,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            final bool lit = interaction.hovered || interaction.focusVisible;

            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: ring,
              offset: 1,
              borderRadius: BorderRadius.circular(extent),
              child: AnimatedOpacity(
                opacity: lit ? 1 : 0.7,
                duration: nebaDuration(context, NebaScale.duration),
                curve: NebaScale.ease,
                child: SizedBox.square(
                  dimension: extent,
                  child: Center(
                    child: NebaGlyph(
                      NebaGlyphs.close,
                      size: glyph,
                      color: lit ? tokens.fg : tokens.mutedFg,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
