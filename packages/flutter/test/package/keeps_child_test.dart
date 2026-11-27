// A control's layers keep what is inside it while its state changes: the
// pointer arriving, a press going down and coming back up, the keyboard
// focus landing and leaving. A layer that came and went with the state would
// build the child again, and a child with state of its own, a field or an
// animation, would start over under the reader's finger.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../support/host.dart';

/// Counts the states made for it, so a test can tell a child that was kept
/// from one that was built again.
class _Probe extends StatefulWidget {
  const _Probe(this.made);

  final List<State<_Probe>> made;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.made.add(this);
  }

  @override
  // Painted, so a press over it lands on it rather than passing through.
  Widget build(BuildContext context) =>
      const ColoredBox(color: Color(0x00000000), child: SizedBox(width: 24, height: 12));
}

void _noop() {}

/// Every control that takes a press, each holding [probe] where its content
/// goes.
Map<String, Widget> _controls(Widget probe) {
  return <String, Widget>{
    'NebaButton': NebaButton(onPressed: _noop, child: probe),
    'NebaIconButton': NebaIconButton(onPressed: _noop, label: 'Add', icon: probe),
    'NebaToggle': NebaToggle(child: probe),
    'NebaChip': NebaChip(onPressed: _noop, child: probe),
    'NebaTextLink': NebaTextLink(onPressed: _noop, child: probe),
    'NebaListItem': NebaList(
      children: <Widget>[NebaListItem(onPressed: _noop, child: probe)],
    ),
    'NebaSegmentedButton': NebaSegmentedButton<String>(
      defaultValue: 'b',
      children: <NebaSegment<String>>[
        NebaSegment<String>(value: 'a', child: probe),
        const NebaSegment<String>(value: 'b', child: Text('Other')),
      ],
    ),
    'NebaTabs': NebaTabs<String>(
      defaultValue: 'b',
      children: <Widget>[
        NebaTab<String>(value: 'a', child: probe),
        const NebaTab<String>(value: 'b', child: Text('Other')),
      ],
    ),
  };
}

void main() {
  for (final String name in _controls(const SizedBox()).keys) {
    testWidgets('$name keeps its child through hover, press, release and focus', (
      WidgetTester tester,
    ) async {
      final List<State<_Probe>> made = <State<_Probe>>[];

      await tester.pumpWidget(
        host(Overlay.wrap(child: Center(child: _controls(_Probe(made))[name]!))),
      );
      expect(made, hasLength(1));

      final Offset at = tester.getCenter(find.byType(_Probe));
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);

      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(at);
      await tester.pump(const Duration(milliseconds: 50));
      await mouse.down(at);
      await tester.pump(const Duration(milliseconds: 50));
      await mouse.up();
      await tester.pump(const Duration(milliseconds: 50));
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 50));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(made, hasLength(1));
      expect(tester.state(find.byType(_Probe)), same(made.single));
    });
  }
}
