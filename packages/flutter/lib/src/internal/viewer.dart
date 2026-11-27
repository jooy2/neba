/// The sheet a picture is shown full size on: an Image's preview and a
/// Gallery's viewer.
///
/// The React package opens both in its `Dialog` at `size="xl"`. The Flutter
/// package has no Dialog yet, so the sheet that Dialog draws is drawn here,
/// on `NebaModalLayer`, for the two of them, and the Dialog's port should
/// take this sheet over rather than draw a second one.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/internal/picture.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The widest the sheet gets: the React Dialog's `max-w-4xl` at `xl`.
const double nebaViewerMaxWidth = 896;

/// How much of the window's height a picture in the viewer may take, the
/// React package's `max-h-[70vh]`.
const double nebaViewerPictureHeight = 0.7;

/// [sheet] as a modal surface arrives with it: centred, held 16 pixels in
/// from the window's edges, and faded in by [arrival] and nothing else, as
/// every floating surface arrives.
Widget nebaViewerSurface(Animation<double> arrival, Widget sheet) {
  return FadeTransition(
    opacity: arrival,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: nebaViewerMaxWidth),
          child: SizedBox(width: double.infinity, child: sheet),
        ),
      ),
    ),
  );
}

/// The Dialog's sheet at `xl`: the frosted panel at elevation 3 with its
/// family's hairline, a [title] over a [description] with the × beside them,
/// and the body under them, the only part that scrolls.
class NebaViewerSheet extends StatelessWidget {
  /// A sheet titled [title] holding [child].
  const NebaViewerSheet({
    required this.title,
    required this.closeLabel,
    required this.onClose,
    required this.child,
    this.description,
    super.key,
  });

  /// The heading, which also names the surface.
  final String title;

  /// A line under the heading.
  final String? description;

  /// What a screen reader hears for the ×.
  final String closeLabel;

  /// Closes the surface.
  final VoidCallback onClose;

  /// The body.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(NebaColor.primary);
    const NebaSize size = NebaSize.xl;
    final double inset = NebaBox.padding[NebaDensity.standard]![size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;
    final String? description = this.description;

    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: NebaScale.sheetHeaderGap[size]!,
            children: <Widget>[
              Semantics(
                container: true,
                header: true,
                headingLevel: 2,
                namesRoute: true,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    height: NebaScale.sheetTitleLeading[size]! / titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (description != null)
                Text(
                  description,
                  style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
                ),
            ],
          ),
        ),
        NebaSheetClose(
          onPressed: onClose,
          label: closeLabel,
          em: MediaQuery.textScalerOf(context).scale(bodySize),
          color: NebaColor.primary,
        ),
      ],
    );

    return NebaSheet(
      fill: tokens.panelPress,
      edge: roles.line,
      plate: NebaPlate.glass,
      elevation: 3,
      borderRadius: BorderRadius.circular(tokens.radius[size]!),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: tokens.fg,
          fontSize: bodySize,
          height: NebaScale.sheetBodyLeading[size]! / bodySize,
        ),
        child: NebaHitArea(
          child: Padding(
            // The hairline takes its pixel, as a CSS border does.
            padding: EdgeInsets.all(inset + 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: NebaScale.sheetSectionGap[size]!,
              children: <Widget>[
                header,
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A picture as the viewer shows it: the file at its own size, never
/// enlarged, held to the width it is given and to [nebaViewerPictureHeight]
/// of the window, turned, mirrored and coloured the way it was on the page,
/// with its mark over it and its protection on it.
///
/// It fades up as it arrives through `Image.frameBuilder`, unless it was
/// already in the cache, and says it is unavailable through
/// `Image.errorBuilder` when it does not arrive.
class NebaViewerPicture extends StatelessWidget {
  /// [image], shown full size.
  const NebaViewerPicture({
    required this.image,
    required this.alt,
    required this.unavailableLabel,
    this.quarters = 0,
    this.flip = NebaImageFlip.none,
    this.filter,
    this.watermark,
    this.protect = false,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  /// The file.
  final ImageProvider image;

  /// What it says, for a screen reader.
  final String alt;

  /// What stands where it was when it does not arrive.
  final String unavailableLabel;

  /// Clockwise quarter turns.
  final int quarters;

  /// The mirror.
  final NebaImageFlip flip;

  /// The colour matrix.
  final List<double>? filter;

  /// The mark over it.
  final NebaImageWatermark? watermark;

  /// Whether the browser's menu is held off over it.
  final bool protect;

  /// Its corners.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double tallest = MediaQuery.sizeOf(context).height * nebaViewerPictureHeight;

    Widget picture = Image(
      image: image,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      gaplessPlayback: true,
      frameBuilder: (BuildContext context, Widget child, int? frame, bool synchronous) {
        if (synchronous) {
          return child;
        }

        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: MediaQuery.maybeDisableAnimationsOf(context) ?? false
              ? Duration.zero
              : NebaScale.durationFill,
          curve: NebaScale.ease,
          child: child,
        );
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return ColoredBox(
          color: tokens.disabledBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: Text(
              alt.isEmpty ? unavailableLabel : alt,
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.mutedFg, fontSize: 14, height: 20 / 14),
            ),
          ),
        );
      },
    );

    // The turn goes around the file at its own size, so a picture on its side
    // is held to the box on its side and the viewer takes its turned shape.
    picture = nebaPose(
      quarters: quarters,
      flip: flip,
      child: NebaColorTreated(matrix: filter, child: picture),
    );

    final NebaImageWatermark? mark = watermark;

    if (mark != null) {
      picture = Stack(
        children: <Widget>[
          picture,
          Positioned.fill(child: NebaWatermarkLayer(mark: mark)),
        ],
      );
    }

    picture = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: tallest),
      child: ClipRRect(borderRadius: borderRadius, child: picture),
    );

    return Semantics(
      container: true,
      image: alt.isNotEmpty,
      label: alt.isEmpty ? null : alt,
      child: ExcludeSemantics(
        excluding: alt.isNotEmpty,
        child: NebaPictureGuard(enabled: protect, child: picture),
      ),
    );
  }
}
