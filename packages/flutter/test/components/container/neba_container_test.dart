// NebaContainer: the gutters, the measure and the centring, measured on the
// laid-out box.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  const Key content = Key('content');

  Future<void> pump(
    WidgetTester tester,
    NebaContainer container, {
    TextDirection textDirection = TextDirection.ltr,
    NebaDefaults? defaults,
  }) {
    // A window wide enough for the widest step but one of the ladder.
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final Widget child = defaults == null
        ? container
        : NebaProvider(defaults: defaults, child: container);

    return tester.pumpWidget(
      host(
        Align(alignment: Alignment.topLeft, child: child),
        width: 1200,
        height: 800,
        textDirection: textDirection,
      ),
    );
  }

  Rect contentRect(WidgetTester tester) => tester.getRect(find.byKey(content));

  testWidgets('pads its content by the gutter, and only horizontally', (WidgetTester tester) async {
    await pump(tester, const NebaContainer(child: SizedBox(key: content, height: 20)));

    expect(contentRect(tester).left, 16);
    expect(contentRect(tester).width, 1200 - 32);
    expect(contentRect(tester).top, 0);
  });

  testWidgets('takes its gutter from size and density, and drops it when not padded', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const NebaContainer(
        size: NebaSize.xl,
        child: SizedBox(key: content, height: 20),
      ),
    );
    expect(contentRect(tester).left, 24);

    await pump(
      tester,
      const NebaContainer(
        density: NebaDensity.compact,
        child: SizedBox(key: content, height: 20),
      ),
    );
    expect(contentRect(tester).left, 10);

    await pump(
      tester,
      const NebaContainer(padded: false, child: SizedBox(key: content, height: 20)),
    );
    expect(contentRect(tester).left, 0);
    expect(contentRect(tester).width, 1200);
  });

  testWidgets('holds the content to a step of the measure ladder and centres it', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const NebaContainer(
        maxWidth: NebaMeasure.size(NebaSize.lg),
        padded: false,
        child: SizedBox(key: content, height: 20),
      ),
    );

    expect(contentRect(tester).width, 1024);
    expect(contentRect(tester).left, (1200 - 1024) / 2);
  });

  testWidgets('takes a width of its own, and stays at the start when not centred', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      const NebaContainer(
        maxWidth: NebaMeasure.width(640),
        centered: false,
        padded: false,
        child: SizedBox(key: content, height: 20),
      ),
    );
    expect(contentRect(tester).left, 0);
    expect(contentRect(tester).width, 640);

    await pump(
      tester,
      const NebaContainer(
        maxWidth: NebaMeasure.width(640),
        centered: false,
        padded: false,
        child: SizedBox(key: content, height: 20),
      ),
      textDirection: TextDirection.rtl,
    );
    expect(contentRect(tester).right, 1200);
  });

  testWidgets('takes size and density from the provider', (WidgetTester tester) async {
    await pump(
      tester,
      const NebaContainer(child: SizedBox(key: content, height: 20)),
      defaults: const NebaDefaults(size: NebaSize.lg, density: NebaDensity.compact),
    );

    expect(contentRect(tester).left, 12);
  });

  test('reads the measure ladder', () {
    expect(const NebaMeasure.size(NebaSize.xs).maxWidth, 480);
    expect(const NebaMeasure.size(NebaSize.xl).maxWidth, 1280);
    expect(const NebaMeasure.width(600).maxWidth, 600);
    expect(NebaMeasure.none.maxWidth, double.infinity);
    expect(const NebaMeasure.size(NebaSize.md), const NebaMeasure.size(NebaSize.md));
  });
}
