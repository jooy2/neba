/// SVG path data, read into a [Path].
///
/// The glyphs the React package draws are SVG paths in a 16-unit box, and
/// reading the same `d` strings here is what keeps a chevron the same chevron
/// on both packages: the shape is copied as data, not redrawn by eye. Every
/// command of the path grammar is read, relative and absolute, arcs included.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:ui' show Offset, Path, Radius;

/// The path [data] describes, in its own units.
///
/// Throws a [FormatException] on a command it cannot read, rather than
/// drawing part of a glyph.
Path parseSvgPath(String data) {
  final _Reader reader = _Reader(data);
  final Path path = Path();
  Offset current = Offset.zero;
  Offset start = Offset.zero;
  Offset? lastControl;
  String previous = '';
  String? command;

  while (reader.skipSeparators()) {
    final String? next = reader.command();

    final String? active = next ?? command;

    if (active == null) {
      throw FormatException('a path starts with a command', data);
    }

    command = active;
    final String op = active;
    final bool relative = op == op.toLowerCase();
    final Offset origin = relative ? current : Offset.zero;
    Offset? control;

    switch (op.toUpperCase()) {
      case 'M':
        current = origin + reader.point();
        start = current;
        path.moveTo(current.dx, current.dy);
        // Further pairs after a moveto are linetos, of the same relativity.
        command = relative ? 'l' : 'L';
      case 'L':
        current = origin + reader.point();
        path.lineTo(current.dx, current.dy);
      case 'H':
        current = Offset((relative ? current.dx : 0) + reader.number(), current.dy);
        path.lineTo(current.dx, current.dy);
      case 'V':
        current = Offset(current.dx, (relative ? current.dy : 0) + reader.number());
        path.lineTo(current.dx, current.dy);
      case 'C':
        final Offset first = origin + reader.point();
        control = origin + reader.point();
        current = origin + reader.point();
        path.cubicTo(first.dx, first.dy, control.dx, control.dy, current.dx, current.dy);
      case 'S':
        final Offset first = _reflect(lastControl, current, smooths: 'CS'.contains(previous));
        control = origin + reader.point();
        current = origin + reader.point();
        path.cubicTo(first.dx, first.dy, control.dx, control.dy, current.dx, current.dy);
      case 'Q':
        control = origin + reader.point();
        current = origin + reader.point();
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
      case 'T':
        control = _reflect(lastControl, current, smooths: 'QT'.contains(previous));
        current = origin + reader.point();
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
      case 'A':
        final double rx = reader.number().abs();
        final double ry = reader.number().abs();
        final double rotation = reader.number();
        final bool largeArc = reader.flag();
        final bool sweep = reader.flag();
        current = origin + reader.point();
        path.arcToPoint(
          current,
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: sweep,
        );
      case 'Z':
        path.close();
        current = start;
      default:
        throw FormatException('unknown path command "$op"', data);
    }

    lastControl = control;
    previous = op.toUpperCase();
  }

  return path;
}

/// The first control point of a smooth curve: the previous curve's second
/// control point mirrored through the current point when [smooths] says the
/// previous command was a curve of the same kind, and the current point
/// itself otherwise.
Offset _reflect(Offset? lastControl, Offset current, {required bool smooths}) {
  if (lastControl == null || !smooths) {
    return current;
  }

  return current * 2 - lastControl;
}

class _Reader {
  _Reader(this.data);

  final String data;
  int _at = 0;

  static final RegExp _number = RegExp(r'[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?');

  /// Skips whitespace and commas; `false` once the data is used up.
  bool skipSeparators() {
    while (_at < data.length && ' \t\r\n,'.contains(data[_at])) {
      _at++;
    }

    return _at < data.length;
  }

  String? command() {
    final String char = data[_at];

    if (RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(char)) {
      _at++;

      return char;
    }

    return null;
  }

  double number() {
    skipSeparators();
    final Match? match = _number.matchAsPrefix(data, _at);

    if (match == null) {
      throw FormatException('expected a number', data, _at);
    }

    _at = match.end;

    return double.parse(match.group(0)!);
  }

  /// An arc flag, which may be written with no separator before what follows.
  bool flag() {
    skipSeparators();
    final String char = data[_at];

    if (char != '0' && char != '1') {
      throw FormatException('expected an arc flag', data, _at);
    }

    _at++;

    return char == '1';
  }

  Offset point() => Offset(number(), number());
}
