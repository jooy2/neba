// The pointer's light goes on a surface the pointer acts on as a whole and on
// nothing else, as the design language rules: both layers on what is pressed
// and held, the spotlight alone on what is only entered, and no light at all
// on a row of someone else's content or on anything too small for an
// 88-pixel bloom to say where the pointer is.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glow.dart';

import '../support/host.dart';

void _noop() {}

/// What is pressed and held: the spotlight and the afterglow.
final Map<String, Widget> _pressed = <String, Widget>{
  'NebaButton': const NebaButton(onPressed: _noop, child: Text('Save')),
  'NebaIconButton': const NebaIconButton(
    onPressed: _noop,
    label: 'Add',
    icon: SizedBox.square(dimension: 12),
  ),
  'NebaToggle': const NebaToggle(child: Text('Bold')),
  'NebaSegmentedButton': const NebaSegmentedButton<String>(
    defaultValue: 'day',
    children: <NebaSegment<String>>[
      NebaSegment<String>(value: 'day', child: Text('Day')),
      NebaSegment<String>(value: 'week', child: Text('Week')),
    ],
  ),
};

/// What is only entered: the spotlight alone.
final Map<String, Widget> _entered = <String, Widget>{
  'NebaTabs': const NebaTabs<String>(
    defaultValue: 'one',
    children: <Widget>[
      NebaTab<String>(value: 'one', child: Text('One')),
      NebaTab<String>(value: 'two', child: Text('Two')),
    ],
  ),
  'NebaTextField': const NebaTextField(label: Text('Email')),
};

/// What takes no light.
final Map<String, Widget> _unlit = <String, Widget>{
  'NebaCard': const NebaCard(title: Text('Plan'), child: Text('Body')),
  'NebaListItem': const NebaList(
    children: <Widget>[NebaListItem(onPressed: _noop, child: Text('One'))],
  ),
  'NebaAccordion': const NebaAccordion(
    children: <Widget>[NebaAccordionItem(title: Text('Shipping'), child: Text('Body'))],
  ),
  'NebaChip': const NebaChip(onPressed: _noop, child: Text('Draft')),
  'NebaCheckbox': const NebaCheckbox(label: Text('Remember me')),
  'NebaSwitch': const NebaSwitch(label: Text('Email alerts')),
  'NebaSlider': const NebaSlider(semanticLabel: 'Volume', defaultValue: 40),
  'NebaOtpField': const NebaOtpField(),
  'NebaTextLink': const NebaTextLink(onPressed: _noop, child: Text('Docs')),
};

void main() {
  Future<List<NebaGlow>> lights(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(host(Overlay.wrap(child: Center(child: widget))));

    return tester.widgetList<NebaGlow>(find.byType(NebaGlow)).toList();
  }

  for (final MapEntry<String, Widget> entry in _pressed.entries) {
    testWidgets('${entry.key} takes the spotlight and the afterglow', (WidgetTester tester) async {
      final List<NebaGlow> found = await lights(tester, entry.value);

      expect(found, isNotEmpty);
      expect(found.every((NebaGlow glow) => glow.spotlight && glow.afterglow), isTrue);
    });
  }

  for (final MapEntry<String, Widget> entry in _entered.entries) {
    testWidgets('${entry.key} takes the spotlight and no afterglow', (WidgetTester tester) async {
      final List<NebaGlow> found = await lights(tester, entry.value);

      expect(found, isNotEmpty);
      expect(found.every((NebaGlow glow) => glow.spotlight && !glow.afterglow), isTrue);
    });
  }

  for (final MapEntry<String, Widget> entry in _unlit.entries) {
    testWidgets('${entry.key} takes no light', (WidgetTester tester) async {
      expect(await lights(tester, entry.value), isEmpty);
    });
  }
}
