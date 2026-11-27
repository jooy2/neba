// NebaPortal: the suite the React package runs on Portal, asked the way
// Flutter asks it — where the child is laid out, what it still inherits from
// where it was written, and what it leaves in place.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  const Key box = Key('box');
  const Key banner = Key('banner');

  /// [portal] written inside a clipped 100-pixel box in the middle of an
  /// 800 × 600 overlay.
  Widget scene(Widget portal) {
    return host(
      Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(
            builder: (BuildContext context) => Center(
              child: ClipRect(
                child: SizedBox(key: box, width: 100, height: 100, child: portal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  const Widget pinned = Align(
    alignment: Alignment.topLeft,
    child: SizedBox(key: banner, width: 40, height: 20),
  );

  group('placement', () {
    testWidgets('lays the child out against the overlay, outside the clip it was written in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(const NebaPortal(child: pinned)));

      expect(tester.getTopLeft(find.byKey(banner)), Offset.zero);
      expect(
        tester.getRect(find.byKey(box)).contains(tester.getTopLeft(find.byKey(banner))),
        isFalse,
      );
    });

    testWidgets('takes no room where it was written', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(key: Key('a'), width: 10, height: 10),
                      NebaPortal(child: pinned),
                      SizedBox(key: Key('b'), width: 10, height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      expect(
        tester.getTopLeft(find.byKey(const Key('b'))).dx,
        tester.getTopRight(find.byKey(const Key('a'))).dx,
      );
    });

    testWidgets('draws in place when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaPortal(disabled: true, child: pinned)));

      expect(tester.getTopLeft(find.byKey(banner)), tester.getTopLeft(find.byKey(box)));
    });

    testWidgets('goes to the nearest overlay when asked to, not the root one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => Center(
                  child: SizedBox(
                    key: box,
                    width: 200,
                    height: 200,
                    child: Overlay(
                      initialEntries: <OverlayEntry>[
                        OverlayEntry(
                          builder: (BuildContext context) =>
                              const NebaPortal(rootOverlay: false, child: pinned),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      expect(tester.getTopLeft(find.byKey(banner)), tester.getTopLeft(find.byKey(box)));
    });

    testWidgets('goes to the root overlay by default, past a nested one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Overlay(
                      initialEntries: <OverlayEntry>[
                        OverlayEntry(
                          builder: (BuildContext context) => const NebaPortal(child: pinned),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      expect(tester.getTopLeft(find.byKey(banner)), Offset.zero);
    });
  });

  group('what the child keeps', () {
    testWidgets('keeps the defaults and the theme of where it was written', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaProvider(
            defaults: const NebaDefaults(size: NebaSize.xl),
            child: NebaPortal(
              child: Align(
                alignment: Alignment.topLeft,
                child: NebaButton(onPressed: () {}, child: const Text('Close')),
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(NebaButton)).height, 48);
    });

    testWidgets('is read where it is drawn', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaPortal(
            child: Align(alignment: Alignment.topLeft, child: Text('Announcement')),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Announcement'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('leaves the overlay when it is removed', (WidgetTester tester) async {
      final ValueNotifier<bool> shown = ValueNotifier<bool>(true);
      addTearDown(shown.dispose);

      await tester.pumpWidget(
        scene(
          ValueListenableBuilder<bool>(
            valueListenable: shown,
            builder: (BuildContext context, bool on, Widget? child) {
              return on ? const NebaPortal(child: pinned) : const SizedBox();
            },
          ),
        ),
      );
      expect(find.byKey(banner), findsOneWidget);

      shown.value = false;
      await tester.pump();
      expect(find.byKey(banner), findsNothing);
    });
  });
}
