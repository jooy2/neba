// NebaMenu and NebaContextMenu: the suite the React package runs on Menu and
// ContextMenu, asked the way Flutter asks it — the rows it builds and what a
// screen reader is told about them, where the focus is, which row is tinted,
// and what a press, a key and the pointer do — rather than the elements, the
// classes and the ARIA it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/menu.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [child] in the middle of an 800 × 600 overlay, with [before] and
  /// [after] beside it.
  Widget scene(
    Widget child, {
    Widget? before,
    Widget? after,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return host(
      Overlay.wrap(
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[?before, child, ?after]),
        ),
      ),
      textDirection: textDirection,
    );
  }

  Widget actions({VoidCallback? onPressed}) {
    return NebaButton(onPressed: onPressed ?? () {}, child: const Text('Actions'));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder sheet() =>
      find.descendant(of: find.byType(NebaMenuSheet), matching: find.byType(NebaSheet));

  /// The focus node a row holds the highlight with.
  FocusNode rowNode(WidgetTester tester, String label) {
    return Focus.of(tester.element(find.text(label)));
  }

  bool highlighted(WidgetTester tester, String label) => rowNode(tester, label).hasPrimaryFocus;

  /// The tint a row is drawn on.
  Color? tint(WidgetTester tester, String label) {
    final Finder box = find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is DecoratedBox && widget.decoration is BoxDecoration,
      ),
    );

    return (tester.widget<DecoratedBox>(box.first).decoration as BoxDecoration).color;
  }

  /// A row of a menu as a screen reader hears it.
  Matcher row(
    String label, {
    SemanticsRole role = SemanticsRole.menuItem,
    bool enabled = true,
    bool? checked,
    bool radio = false,
    bool? expanded,
    bool link = false,
    bool focused = false,
  }) {
    return matchesSemantics(
      role: role,
      label: label,
      hasEnabledState: true,
      isEnabled: enabled,
      isFocusable: true,
      hasFocusAction: true,
      hasTapAction: enabled,
      hasCheckedState: checked != null,
      isChecked: checked ?? false,
      isInMutuallyExclusiveGroup: radio,
      hasExpandedState: expanded != null,
      isExpanded: expanded ?? false,
      isLink: link,
      isFocused: focused,
    );
  }

  /// The trigger, a button that says whether the menu is open.
  Matcher trigger({required bool expanded}) {
    return matchesSemantics(
      label: 'Actions',
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      isFocusable: true,
      hasFocusAction: true,
      hasTapAction: true,
      hasExpandedState: true,
      isExpanded: expanded,
    );
  }

  Future<TestGesture> mouseAt(WidgetTester tester, Offset position) async {
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: position);
    addTearDown(mouse.removePointer);
    await tester.pump();

    return mouse;
  }

  group('rendering', () {
    testWidgets('renders nothing until it is open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );

      expect(find.text('Rename'), findsNothing);
      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('renders a menu of its rows when open', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            trigger: actions(),
            children: const <Widget>[
              NebaMenuItem(child: Text('Rename')),
              NebaMenuItem(child: Text('Duplicate')),
            ],
          ),
        ),
      );
      await tester.pump();

      final SemanticsNode menu = tester.getSemantics(
        find.descendant(of: find.byType(NebaMenuSheet), matching: find.byType(Semantics)).first,
      );
      expect(menu.getSemanticsData().role, SemanticsRole.menu);
      expect(tester.getSemantics(find.text('Rename')), row('Rename'));
      expect(
        tester.getSemantics(find.text('Duplicate')).getSemanticsData().role,
        SemanticsRole.menuItem,
      );
      semantics.dispose();
    });

    testWidgets('opens when the trigger is pressed, and a second press closes it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );

      await tester.tap(find.text('Actions'));
      await settle(tester);
      expect(find.text('Rename'), findsOneWidget);

      // Through the modal barrier, which leaves the trigger out.
      await tester.tap(find.text('Actions'));
      await settle(tester);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('says on its trigger whether it is open', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );

      expect(tester.getSemantics(find.text('Actions')), trigger(expanded: false));

      await tester.tap(find.text('Actions'));
      await settle(tester);
      expect(tester.getSemantics(find.text('Actions')), trigger(expanded: true));
      semantics.dispose();
    });

    testWidgets('renders without a trigger, for a menu something else opens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(const NebaMenu(open: true, children: <Widget>[NebaMenuItem(child: Text('Rename'))])),
      );
      await tester.pump();

      expect(find.text('Rename'), findsOneWidget);
      expect(find.byType(NebaButton), findsNothing);
    });

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[NebaMenuItem(child: Text('Before'))],
          ),
        ),
      );
      await tester.pumpWidget(
        scene(
          const NebaMenu(defaultOpen: true, children: <Widget>[NebaMenuItem(child: Text('After'))]),
        ),
      );

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('hangs below the trigger at its start, and is as wide as its widest row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[
              NebaMenuItem(child: Text('Cut')),
              NebaMenuItem(child: Text('Move to another workspace')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Actions'));
      await settle(tester);

      final Rect trigger = tester.getRect(find.byType(NebaButton));
      final Rect popup = tester.getRect(sheet());
      expect(popup.top, moreOrLessEquals(trigger.bottom + 6));
      expect(popup.left, moreOrLessEquals(trigger.left));
      expect(
        popup.width,
        greaterThan(tester.getSize(find.text('Move to another workspace')).width),
      );
      // A row is as wide as the popup's inside.
      expect(
        tester.getSize(find.byType(NebaMenuRow).first).width,
        moreOrLessEquals(popup.width - 2 - 2 * nebaMenuPadding),
      );
    });

    testWidgets('is never narrower than 160 pixels', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(defaultOpen: true, children: <Widget>[NebaMenuItem(child: Text('Cut'))]),
        ),
      );
      await tester.pump();

      expect(tester.getSize(sheet()).width, 160);
    });

    testWidgets('scrolls past 384 pixels', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[for (int i = 0; i < 30; i++) NebaMenuItem(child: Text('Row $i'))],
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSize(sheet()).height, 384);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('rows', () {
    testWidgets('calls the handler when a row is picked, and closes', (WidgetTester tester) async {
      int renamed = 0;
      bool? open;

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            onOpenChange: (bool value) => open = value,
            children: <Widget>[
              NebaMenuItem(onPressed: () => renamed += 1, child: const Text('Rename')),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Rename'));
      await settle(tester);

      expect(renamed, 1);
      expect(open, isFalse);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('stays open when a row is picked with closeOnPress off', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(closeOnPress: false, onPressed: () {}, child: const Text('Rename')),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Rename'));
      await settle(tester);
      expect(find.text('Rename'), findsOneWidget);
    });

    // A menu of links that are not links tells a screen reader the wrong
    // thing about every one of them.
    testWidgets('is a link to a screen reader when it is given an href', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                href: Uri.parse('#settings'),
                onPressed: () {},
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSemantics(find.text('Settings')), row('Settings', link: true));
      expect(
        tester.getSemantics(find.text('Settings')).getSemanticsData().linkUrl,
        Uri.parse('#settings'),
      );
      semantics.dispose();
    });

    testWidgets('stops being a link while it is disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                href: Uri.parse('#billing'),
                disabled: true,
                onPressed: () {},
                child: const Text('Billing'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSemantics(find.text('Billing')), row('Billing', enabled: false));
      expect(tester.getSemantics(find.text('Billing')).getSemanticsData().linkUrl, isNull);
      semantics.dispose();
    });

    testWidgets('writes no address it should not hand on', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                href: Uri.parse('javascript:alert(1)'),
                onPressed: () {},
                child: const Text('Run'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSemantics(find.text('Run')).getSemanticsData().linkUrl, isNull);
      semantics.dispose();
    });

    testWidgets('says that a row opens elsewhere', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                href: Uri.parse('https://example.com'),
                newTab: true,
                onPressed: () {},
                child: const Text('Docs'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Docs')).getSemanticsData().label,
        'Docs\n(opens in a new tab)',
      );
      semantics.dispose();
    });

    testWidgets('does not fire a disabled row, and keeps it listed', (WidgetTester tester) async {
      int renamed = 0;

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                disabled: true,
                onPressed: () => renamed += 1,
                child: const Text('Rename'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Rename'));
      await settle(tester);

      expect(renamed, 0);
      expect(find.text('Rename'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Rename'))).style.color,
        tokens.disabledFg,
      );
    });

    testWidgets('renders a shortcut and a description, muted', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                shortcut: Text('⌘R'),
                description: Text('Give it another name'),
                child: Text('Rename'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final TextStyle shortcut = DefaultTextStyle.of(tester.element(find.text('⌘R'))).style;
      final TextStyle description = DefaultTextStyle.of(
        tester.element(find.text('Give it another name')),
      ).style;
      expect(shortcut.color, tokens.mutedFg);
      expect(shortcut.fontSize, NebaScale.metaText[NebaSize.md]);
      expect(description.color, tokens.mutedFg);
      expect(
        tester.getRect(find.text('Give it another name')).top,
        greaterThanOrEqualTo(tester.getRect(find.text('Rename')).bottom),
      );
      // At the end of the row, after the label.
      expect(
        tester.getRect(find.text('⌘R')).left,
        greaterThan(tester.getRect(find.text('Rename')).right),
      );
    });

    testWidgets('puts a start icon in a slot 1.2 times the text wide', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(
                startIcon: SizedBox.square(key: Key('icon'), dimension: 4),
                child: Text('Copy'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final double text = NebaScale.controlText[NebaSize.md]!;
      final Finder slot = find
          .ancestor(of: find.byKey(const Key('icon')), matching: find.byType(SizedBox))
          .first;
      expect(tester.getSize(slot), Size(text * 1.2, NebaScale.controlLeading[NebaSize.md]!));
      expect(IconTheme.of(tester.element(find.byKey(const Key('icon')))).color, tokens.mutedFg);
      expect(
        tester.getRect(find.byKey(const Key('icon'))).right,
        lessThan(tester.getRect(find.text('Copy')).left),
      );
    });

    // The label carries the family's ink on a tint, not the accent: an
    // accent on a pale copy of itself does not clear 4.5:1.
    testWidgets('re-points a row at its own colour family', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(color: NebaColor.danger, child: Text('Delete')),
              NebaMenuItem(child: Text('Rename')),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        DefaultTextStyle.of(tester.element(find.text('Delete'))).style.color,
        tokens.roles(NebaColor.danger).onTint,
      );
      expect(DefaultTextStyle.of(tester.element(find.text('Rename'))).style.color, tokens.fg);
    });

    testWidgets('renders a group with its heading, and a separator', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuGroup(
                label: Text('Danger'),
                children: <Widget>[NebaMenuItem(child: Text('Delete'))],
              ),
              NebaMenuSeparator(),
              NebaMenuItem(child: Text('Rename')),
            ],
          ),
        ),
      );
      await tester.pump();

      // Drawn in capitals, named as written.
      expect(find.text('DANGER'), findsOneWidget);
      expect(find.bySemanticsLabel('Danger'), findsOneWidget);
      expect(find.byType(NebaMenuSeparator), findsOneWidget);

      // The hairline is a pixel, across the popup's padding.
      final Rect line = tester.getRect(
        find.descendant(of: find.byType(NebaMenuSeparator), matching: find.byType(CustomPaint)),
      );
      expect(line.height, 1);
      expect(
        tester.getRect(find.text('Rename')).top,
        greaterThan(line.bottom + NebaMenuSeparator.gap - 1),
      );
      semantics.dispose();
    });
  });

  group('rows that hold state', () {
    testWidgets('ticks and unticks a checkbox row, and stays open', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuCheckboxItem(onCheckedChange: changes.add, child: const Text('Show grid')),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Show grid')),
        row('Show grid', role: SemanticsRole.menuItemCheckbox, checked: false),
      );
      expect(find.byType(NebaGlyph), findsNothing);

      await tester.tap(find.text('Show grid'));
      await settle(tester);

      expect(changes, <bool>[true]);
      expect(find.text('Show grid'), findsOneWidget);
      expect(find.byType(NebaGlyph), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Show grid')),
        row('Show grid', role: SemanticsRole.menuItemCheckbox, checked: true),
      );
      expect(
        IconTheme.of(tester.element(find.byType(NebaGlyph))).color,
        tokens.roles(NebaColor.primary).family.accent,
      );

      await tester.tap(find.text('Show grid'));
      await settle(tester);
      expect(changes, <bool>[true, false]);
      semantics.dispose();
    });

    testWidgets('keeps the slot of an unticked row, so labels line up', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuCheckboxItem(defaultChecked: true, child: Text('Status')),
              NebaMenuCheckboxItem(child: Text('Owner')),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.getRect(find.text('Status')).left, tester.getRect(find.text('Owner')).left);
    });

    testWidgets('chooses one radio row out of a set', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> changes = <String>[];

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuRadioGroup<String>(
                defaultValue: 'list',
                onValueChange: changes.add,
                children: const <Widget>[
                  NebaMenuRadioItem<String>(value: 'list', child: Text('List')),
                  NebaMenuRadioItem<String>(value: 'grid', child: Text('Grid')),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.text('List')),
        row('List', role: SemanticsRole.menuItemRadio, checked: true, radio: true),
      );

      await tester.tap(find.text('Grid'));
      await settle(tester);

      expect(changes, <String>['grid']);
      expect(
        tester.getSemantics(find.text('List')),
        row('List', role: SemanticsRole.menuItemRadio, checked: false, radio: true),
      );
      expect(
        tester.getSemantics(find.text('Grid')),
        row('Grid', role: SemanticsRole.menuItemRadio, checked: true, radio: true),
      );
      expect(find.text('Grid'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('disables every row of a disabled set', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuRadioGroup<String>(
                value: 'list',
                disabled: true,
                onValueChange: changes.add,
                children: const <Widget>[
                  NebaMenuRadioItem<String>(value: 'list', child: Text('List')),
                  NebaMenuRadioItem<String>(value: 'grid', child: Text('Grid')),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Grid'));
      await settle(tester);
      expect(changes, isEmpty);
    });
  });

  group('submenus', () {
    Widget share({TextDirection textDirection = TextDirection.ltr}) {
      return scene(
        NebaMenu(
          trigger: actions(),
          children: const <Widget>[
            NebaMenuSubmenu(
              label: Text('Share'),
              children: <Widget>[
                NebaMenuItem(child: Text('Copy link')),
                NebaMenuSubmenu(
                  label: Text('Export'),
                  children: <Widget>[NebaMenuItem(child: Text('As PDF'))],
                ),
              ],
            ),
            NebaMenuItem(child: Text('Rename')),
          ],
        ),
        textDirection: textDirection,
      );
    }

    testWidgets('renders the row that opens a submenu, with the submenu closed', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(share());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Copy link'), findsNothing);

      expect(tester.getSemantics(find.text('Share')), row('Share', expanded: false));
      semantics.dispose();
    });

    testWidgets('opens a submenu when its row is hovered, and marks the row', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(share());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      final TestGesture mouse = await mouseAt(tester, tester.getCenter(find.text('Share')));
      await mouse.moveBy(const Offset(1, 0));
      await tester.pump(nebaSubmenuDelay);
      await settle(tester);

      expect(find.text('Copy link'), findsOneWidget);
      // The highlight stays on the row the pointer is resting on.
      expect(tester.getSemantics(find.text('Share')), row('Share', expanded: true, focused: true));
      // Beside the row, at its inline end, with its first row level with it.
      expect(
        tester.getRect(find.text('Copy link')).left,
        greaterThan(tester.getRect(find.byType(NebaMenuRow).first).right),
      );
      semantics.dispose();
    });

    testWidgets('points the chevron and opens the submenu towards the inline end under RTL', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(share(textDirection: TextDirection.rtl));
      await tester.tap(find.text('Actions'));
      await settle(tester);

      final Finder chevron = find.descendant(
        of: find.ancestor(of: find.text('Share'), matching: find.byType(NebaMenuRow)).first,
        matching: find.byType(RotatedBox),
      );
      expect(tester.widget<RotatedBox>(chevron).quarterTurns, 1);

      final TestGesture mouse = await mouseAt(tester, tester.getCenter(find.text('Share')));
      await mouse.moveBy(const Offset(-1, 0));
      await tester.pump(nebaSubmenuDelay);
      await settle(tester);

      final Rect row = tester.getRect(
        find.ancestor(of: find.text('Share'), matching: find.byType(NebaMenuRow)).first,
      );
      expect(tester.getRect(find.text('Copy link')).right, lessThanOrEqualTo(row.left + 1));
    });

    testWidgets('nests a submenu inside a submenu', (WidgetTester tester) async {
      await tester.pumpWidget(share());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      final TestGesture mouse = await mouseAt(tester, tester.getCenter(find.text('Share')));
      await mouse.moveBy(const Offset(1, 0));
      await tester.pump(nebaSubmenuDelay);
      await settle(tester);

      await mouse.moveTo(tester.getCenter(find.text('Export')));
      await tester.pump(nebaSubmenuDelay);
      await settle(tester);

      expect(find.text('As PDF'), findsOneWidget);

      // A press in the deepest popup counts as inside every one of them.
      await tester.tap(find.text('As PDF'));
      await settle(tester);
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('closes when the pointer rests on another row', (WidgetTester tester) async {
      await tester.pumpWidget(share());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      final TestGesture mouse = await mouseAt(tester, tester.getCenter(find.text('Share')));
      await mouse.moveBy(const Offset(1, 0));
      await tester.pump(nebaSubmenuDelay);
      await settle(tester);
      expect(find.text('Copy link'), findsOneWidget);

      await mouse.moveTo(tester.getCenter(find.text('Rename')));
      await tester.pump();
      // Not at once: the pointer may be on its way into the submenu.
      expect(find.text('Copy link'), findsOneWidget);
      expect(highlighted(tester, 'Rename'), isTrue);

      await tester.pump(nebaSubmenuDelay);
      await settle(tester);
      expect(find.text('Copy link'), findsNothing);
    });

    testWidgets('opens on the arrow that points at it, and closes on the one that points back', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(share());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Share'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(find.text('Copy link'), findsOneWidget);
      expect(highlighted(tester, 'Copy link'), isTrue);

      // Down walks the submenu, not the menu under it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Export'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await settle(tester);
      expect(find.text('Copy link'), findsNothing);
      expect(highlighted(tester, 'Share'), isTrue);
    });

    testWidgets('closes on Escape alone, and gives the focus back to its row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(share());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(highlighted(tester, 'Copy link'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('Copy link'), findsNothing);
      expect(find.text('Share'), findsOneWidget);
      expect(highlighted(tester, 'Share'), isTrue);
    });

    testWidgets('opens nothing when it is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuSubmenu(
                label: Text('Share'),
                disabled: true,
                children: <Widget>[NebaMenuItem(child: Text('Copy link'))],
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Share'));
      await settle(tester);
      expect(find.text('Copy link'), findsNothing);
    });
  });

  group('the keyboard', () {
    Widget two({VoidCallback? onRename, bool loopFocus = true}) {
      return scene(
        NebaMenu(
          trigger: actions(),
          loopFocus: loopFocus,
          children: <Widget>[
            NebaMenuItem(onPressed: onRename, child: const Text('Rename')),
            const NebaMenuItem(child: Text('Duplicate')),
            const NebaMenuItem(disabled: true, child: Text('Delete')),
          ],
        ),
        after: NebaButton(onPressed: () {}, child: const Text('After')),
      );
    }

    testWidgets('walks the rows with the arrow keys, disabled rows included', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(two());
      await tester.tap(find.text('Actions'));
      await settle(tester);

      // Opened by a press: nothing is highlighted until a key is.
      expect(highlighted(tester, 'Rename'), isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Rename'), isTrue);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tint(tester, 'Rename'), tokens.roles(NebaColor.primary).softHover);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Duplicate'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Delete'), isTrue);

      // Round to the top.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Rename'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(highlighted(tester, 'Delete'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(highlighted(tester, 'Rename'), isTrue);
    });

    testWidgets('stops at the ends when loopFocus is off', (WidgetTester tester) async {
      await tester.pumpWidget(two(loopFocus: false));
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(highlighted(tester, 'Delete'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(highlighted(tester, 'Delete'), isTrue);
    });

    testWidgets('picks the highlighted row with Enter', (WidgetTester tester) async {
      int renamed = 0;

      await tester.pumpWidget(two(onRename: () => renamed += 1));
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(renamed, 1);
      expect(find.text('Rename'), findsNothing);
      // Back on the trigger.
      expect(Focus.of(tester.element(find.text('Actions'))).hasPrimaryFocus, isTrue);
    });

    testWidgets('opens from the trigger on Enter at the first row, and on Up at the last', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(two());
      Focus.of(tester.element(find.text('Actions'))).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(highlighted(tester, 'Rename'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('Rename'), findsNothing);
      expect(Focus.of(tester.element(find.text('Actions'))).hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await settle(tester);
      expect(highlighted(tester, 'Delete'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(highlighted(tester, 'Rename'), isTrue);
    });

    testWidgets('closes on Escape', (WidgetTester tester) async {
      bool? open;

      await tester.pumpWidget(
        scene(
          NebaMenu(
            defaultOpen: true,
            onOpenChange: (bool value) => open = value,
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(open, isFalse);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('moves to the row that starts with what was typed', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[
              NebaMenuItem(child: Text('Rename')),
              NebaMenuItem(child: Text('Duplicate')),
              NebaMenuItem(child: Text('Delete')),
              NebaMenuItem(label: 'Archive', child: SizedBox(width: 40, height: 10)),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.pump();
      expect(highlighted(tester, 'Duplicate'), isTrue);

      // The same letter again walks on through the rows it starts.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.pump();
      expect(highlighted(tester, 'Delete'), isTrue);

      await tester.pump(nebaTypeaheadReset);

      // `label` is what a row that is not a Text is found by.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      final FocusNode archive = Focus.of(
        tester.element(find.byWidgetPredicate((Widget w) => w is SizedBox && w.width == 40)),
      );
      expect(archive.hasPrimaryFocus, isTrue);
    });

    testWidgets('closes on Tab and moves on from the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(two());
      Focus.of(tester.element(find.text('Actions'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(highlighted(tester, 'Rename'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await settle(tester);

      expect(find.text('Rename'), findsNothing);
      expect(Focus.of(tester.element(find.text('After'))).hasPrimaryFocus, isTrue);
    });
  });

  group('the pointer', () {
    testWidgets('highlights the row under it, and lets go when it leaves', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[
              NebaMenuItem(child: Text('Rename')),
              NebaMenuItem(child: Text('Duplicate')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Actions'));
      await settle(tester);

      final TestGesture mouse = await mouseAt(tester, tester.getCenter(find.text('Duplicate')));
      await mouse.moveBy(const Offset(1, 0));
      await tester.pump();
      expect(highlighted(tester, 'Duplicate'), isTrue);

      // The keys go on from where the pointer is.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(highlighted(tester, 'Rename'), isTrue);

      await mouse.moveTo(const Offset(5, 5));
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Duplicate')));
      await tester.pump();
      await mouse.moveTo(const Offset(5, 5));
      await tester.pump();
      expect(highlighted(tester, 'Duplicate'), isFalse);
      expect(highlighted(tester, 'Rename'), isFalse);
    });

    testWidgets('takes the page behind away, and closes on a press on it', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          NebaMenu(
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
          before: NebaButton(onPressed: () => pressed += 1, child: const Text('Behind')),
        ),
      );
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.tap(find.text('Behind'), warnIfMissed: false);
      await settle(tester);

      expect(pressed, 0);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('leaves the page behind pressable when it is not modal', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          NebaMenu(
            modal: false,
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
          before: NebaButton(onPressed: () => pressed += 1, child: const Text('Behind')),
        ),
      );
      await tester.tap(find.text('Actions'));
      await settle(tester);

      await tester.tap(find.text('Behind'));
      await settle(tester);

      expect(pressed, 1);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('opens on hover with openOnHover', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            openOnHover: true,
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );

      final TestGesture mouse = await mouseAt(tester, const Offset(5, 5));
      await mouse.moveTo(tester.getCenter(find.text('Actions')));
      await tester.pump(nebaSubmenuDelay);
      await settle(tester);

      expect(find.text('Rename'), findsOneWidget);
    });

    testWidgets('opens nothing when it is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaMenu(
            disabled: true,
            trigger: actions(),
            children: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );

      await tester.tap(find.text('Actions'));
      await settle(tester);
      expect(find.text('Rename'), findsNothing);
    });
  });

  group('what the row inherits', () {
    EdgeInsets padding(WidgetTester tester, String label) {
      final Finder pad = find.ancestor(of: find.text(label), matching: find.byType(Padding));

      return tester
          .widgetList<Padding>(pad)
          .map((Padding p) => p.padding)
          .whereType<EdgeInsets>()
          .firstWhere((EdgeInsets e) => e.left > 0 && e.top > 0);
    }

    testWidgets('takes its size from the menu rather than from itself', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            size: NebaSize.xl,
            children: <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );
      await tester.pump();

      expect(padding(tester, 'Rename'), const EdgeInsets.symmetric(horizontal: 14, vertical: 10));
      expect(
        DefaultTextStyle.of(tester.element(find.text('Rename'))).style.fontSize,
        NebaScale.controlText[NebaSize.xl],
      );
    });

    testWidgets('takes its density from the menu, and both from the provider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            density: NebaDensity.compact,
            children: <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );
      await tester.pump();
      expect(padding(tester, 'Rename'), const EdgeInsets.symmetric(horizontal: 8, vertical: 4));

      await tester.pumpWidget(
        scene(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.sm),
            child: NebaMenu(
              defaultOpen: true,
              children: <Widget>[NebaMenuItem(child: Text('Rename'))],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(padding(tester, 'Rename'), const EdgeInsets.symmetric(horizontal: 8, vertical: 4));
    });

    testWidgets('keeps the popup undyed while colouring the edge', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            color: NebaColor.success,
            children: <Widget>[NebaMenuItem(child: Text('Rename'))],
          ),
        ),
      );
      await tester.pump();

      final NebaSheet surface = tester.widget<NebaSheet>(sheet());
      expect(surface.fill, tokens.panelPress);
      expect(surface.edge, tokens.roles(NebaColor.success).line);
      expect(surface.elevation, 3);
      expect(surface.plate, NebaPlate.glass);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaMenu(
            defaultOpen: true,
            children: <Widget>[
              NebaMenuItem(shortcut: Text('⌘R'), child: Text('Rename')),
              NebaMenuSubmenu(
                label: Text('Share'),
                children: <Widget>[NebaMenuItem(child: Text('Copy'))],
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(of: find.byType(NebaMenuSheet), matching: find.byType(Transform)),
        findsNothing,
      );
    });
  });

  group('NebaContextMenu', () {
    Widget area({bool disabled = false, NebaSize? size}) {
      return scene(
        NebaContextMenu(
          disabled: disabled,
          size: size,
          content: const <Widget>[NebaMenuItem(child: Text('Rename'))],
          child: const Focus(
            child: SizedBox(width: 300, height: 120, child: Center(child: Text('Right-click me'))),
          ),
        ),
      );
    }

    testWidgets('renders the area it wraps, with the menu closed', (WidgetTester tester) async {
      await tester.pumpWidget(area());

      expect(find.text('Right-click me'), findsOneWidget);
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('lays the area out as it would be without it', (WidgetTester tester) async {
      await tester.pumpWidget(area());

      expect(tester.getSize(find.byType(NebaContextMenu)), const Size(300, 120));
    });

    testWidgets('opens on a right-click, where the pointer is', (WidgetTester tester) async {
      await tester.pumpWidget(area());

      final Offset at = tester.getTopLeft(find.byType(NebaContextMenu)) + const Offset(40, 30);
      final TestGesture mouse = await tester.startGesture(
        at,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await mouse.up();
      await settle(tester);

      expect(find.text('Rename'), findsOneWidget);
      final Rect popup = tester.getRect(sheet());
      // At the pointer, which the slide that keeps a popup facing its anchor
      // holds it to.
      expect(popup.left, inInclusiveRange(at.dx, at.dx + NebaContextMenu.pointerOffset.dx));
      expect(popup.top, moreOrLessEquals(at.dy + NebaContextMenu.pointerOffset.dy));
    });

    testWidgets('opens on a long press', (WidgetTester tester) async {
      await tester.pumpWidget(area());

      await tester.longPress(find.text('Right-click me'));
      await settle(tester);

      expect(find.text('Rename'), findsOneWidget);
    });

    testWidgets('opens from the keyboard with Shift+F10, at its first row', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(area());

      Focus.of(tester.element(find.text('Right-click me'))).requestFocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await settle(tester);

      expect(highlighted(tester, 'Rename'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('Rename'), findsNothing);
      expect(Focus.of(tester.element(find.text('Right-click me'))).hasPrimaryFocus, isTrue);
    });

    testWidgets('opens nothing when it is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(area(disabled: true));

      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(find.text('Right-click me')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await mouse.up();
      await settle(tester);

      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('hands its size down to the rows, exactly as NebaMenu does', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const NebaContextMenu(
            defaultOpen: true,
            size: NebaSize.xl,
            content: <Widget>[NebaMenuItem(child: Text('Rename'))],
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pump();

      expect(
        DefaultTextStyle.of(tester.element(find.text('Rename'))).style.fontSize,
        NebaScale.controlText[NebaSize.xl],
      );
    });
  });

  testWidgets('fails with a message when a row is used outside a menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(const NebaMenuItem(child: Text('Lost'))));

    expect(tester.takeException(), isA<FlutterError>());
  });
}
