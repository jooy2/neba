/// What a finger gets on a control drawn smaller than one: the React
/// package's `neba-hit`.
///
/// WCAG 2.5.8 asks a target to be 24 pixels across in both directions. The ×
/// on an alert and on a chip, a tick and a switch are drawn against the text
/// beside them, which is smaller than that, so the target grows past the box
/// they are drawn in without taking any room: [NebaHitTarget] goes around the
/// control and [NebaHitArea] around the box the growth may reach into, such
/// as a sheet with its padding. The React package grows a pseudo-element; a
/// render box is only ever hit inside its own size, so here the area asks its
/// targets once nothing inside it took the press.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// How far a target reaches in each direction at the least: `--n-hit`, 24
/// pixels.
const double nebaHitExtent = 24;

/// The box the [NebaHitTarget]s below it may grow their targets into.
///
/// A press inside the area that nothing below it takes goes to the target
/// whose grown box holds it, at the target's centre, so a press there is the
/// press on the control. Anything that is hit on its own comes first, so a
/// target never takes a press from a neighbour it reaches over.
class NebaHitArea extends SingleChildRenderObjectWidget {
  /// An area around [child].
  const NebaHitArea({required super.child, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHitArea();
}

/// A control whose target is at least [extent] across, centred on it.
///
/// It takes no more room than [child]. The growth reaches only as far as the
/// nearest [NebaHitArea] above it; with none, the target is the child's box.
class NebaHitTarget extends SingleChildRenderObjectWidget {
  /// A target around [child].
  const NebaHitTarget({required super.child, this.extent = nebaHitExtent, super.key});

  /// The least width and height of the target.
  final double extent;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHitTarget(extent);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderHitTarget).extent = extent;
  }
}

class _RenderHitArea extends RenderProxyBox {
  /// In the order they were attached, which is the order they are painted in
  /// along a row.
  final List<_RenderHitTarget> _targets = <_RenderHitTarget>[];

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }

    if (!size.contains(position)) {
      return false;
    }

    // The last one first, as the one painted over the others would be.
    for (final _RenderHitTarget target in _targets.reversed) {
      if (!target.hasSize || !target.attached) {
        continue;
      }

      final Rect drawn = MatrixUtils.transformRect(
        target.getTransformTo(this),
        Offset.zero & target.size,
      );
      final Rect grown = Rect.fromCenter(
        center: drawn.center,
        width: math.max(drawn.width, target.extent),
        height: math.max(drawn.height, target.extent),
      );

      if (!grown.contains(position)) {
        continue;
      }

      final Offset centre = target.size.center(Offset.zero);
      final bool hit = result.addWithRawTransform(
        transform: MatrixUtils.forceToPoint(centre),
        position: centre,
        hitTest: (BoxHitTestResult result, Offset position) {
          return target.hitTest(result, position: centre);
        },
      );

      if (hit) {
        result.add(BoxHitTestEntry(this, position));

        return true;
      }
    }

    return false;
  }
}

class _RenderHitTarget extends RenderProxyBox {
  _RenderHitTarget(this.extent);

  /// Read on each hit test, so a change needs no layout and no paint.
  double extent;
  _RenderHitArea? _area;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    RenderObject? node = parent;

    while (node != null && node is! _RenderHitArea) {
      node = node.parent;
    }

    _area = node as _RenderHitArea?;
    _area?._targets.add(this);
  }

  @override
  void detach() {
    _area?._targets.remove(this);
    _area = null;
    super.detach();
  }
}
