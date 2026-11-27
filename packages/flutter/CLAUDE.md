# CLAUDE.md

Guidance for AI agents working in `packages/flutter`, the Flutter package published to pub.dev as [`neba`](https://pub.dev/packages/neba). The repository's own guide is [../../CLAUDE.md](../../CLAUDE.md): what the repository holds, the documentation site, releasing and the commit conventions. Every path in this file is relative to `packages/flutter` unless it says otherwise.

The package is a port of the React package in `../react`, not a second design. When the two disagree, the React package and [the design language](../../docs/ko/design/design-language.md) are right, and the port is what changes. [../../TODO.md](../../TODO.md) is the order the port is done in.

## Layout

| Path | Purpose |
| --- | --- |
| `lib/neba.dart` | The barrel. **Generated** by `tool/generate.dart`; never edit it by hand. |
| `lib/src/types.dart` | The shared prop vocabulary: `NebaSize`, `NebaColor`, `NebaDensity` and the rest, the React package's `src/types.ts` value for value. |
| `lib/src/theme/tokens.dart` | `NebaTokens`, `NebaColorFamily`, `NebaColorRoles`: the React stylesheet's tokens, computed rather than copied. |
| `lib/src/theme/scale.dart` | `NebaScale`: control heights, type sizes, icon sizes, padding, gaps, the sheet type ladder a card, an alert and a dialog share, and motion, from the React package's `src/internal/styles.ts`. |
| `lib/src/theme/theme.dart` | `NebaTheme` and `NebaDefaults`: how a widget finds its tokens and its defaults. |
| `lib/src/components/{name}/neba_{name}.dart` | One folder per component, named like the React folder with underscores (`text_field` for `text-field`). A sibling widget may share the folder. |
| `lib/src/internal/` | The library talking to itself. Never exported, and every module exists because two widgets would otherwise answer the same question twice. |
| `test/` | Widget tests, mirroring `lib/src/`. `test/package/` holds the contracts the whole package keeps, and `test/support/` the helpers. |
| `tool/generate.dart` | Writes the barrel and `example/lib/demos/registry.dart`. |
| `example/` | The gallery. It is the package's pub.dev example and, built for the web, the renderer behind every Flutter preview on the documentation site. |

## Rules the package holds itself to

- **`package:flutter/widgets.dart` only.** Nothing under `lib/` imports `material.dart` or `cupertino.dart`, and `test/package/framework_surface_test.dart` fails if anything does. A Neba widget has to sit in a Material app, a Cupertino app or a bare `WidgetsApp` without bringing a second design system along, and Material and Cupertino are moving out of the framework. This is the one place the house Flutter conventions, which say "Material by default", do not apply: they are written for apps, and this is a library whose whole job is to be the design system. Build what Material would have given you — a ripple-free press, a focus ring, a scrollbar — from the widgets layer.
- **No dependencies** but the Flutter SDK, checked by the same test. Ask before adding one; the answer is almost always to write the few lines in `lib/src/internal/`.
- **The `Neba` prefix on every public name**: `NebaButton`, `NebaSize`, `NebaTokens`. React's components are unprefixed, but `Button`, `Card`, `Checkbox` and half the rest are already Material's names, and a consumer's app imports both.
- **The Dart conventions of the house**: explicit types rather than `var`, `final` and `const` wherever they apply, braces around every control body, named parameters from three arguments up, no `print`. `analysis_options.yaml` enforces most of it, including `public_member_api_docs`: every exported symbol is documentation for somebody.
- **`dart format` at a page width of 100**, and `flutter analyze` with no issue at all, info included.
- **Dev dependencies are pinned to an exact version** (`flutter_lints: 6.0.0`), as the house rules ask. The package's own constraint on the SDK stays a range, because a library's constraints are its consumers' constraints.

## One design language, in widget terms

The React guide states each rule of [the design language](../../docs/ko/design/design-language.md) in CSS. Here is what each one means for a widget.

- **Tokens come from `NebaTheme.of(context)`, sizes from `NebaScale`.** Never write a colour, a radius or a height into a widget. A widget with nothing above it still works: `NebaTheme.of` falls back to the platform's brightness, as the stylesheet follows `prefers-color-scheme`.
- **A widget resolves each axis as its argument, then its group, then `NebaTheme.defaultsOf(context)`, then its own default.** So every style argument is nullable, and a constructor never bakes a default in (`this.size = NebaSize.md` would make `NebaProvider` powerless).
- **No transform on a control, ever.** No `Transform.scale` on a press, no `AnimatedScale`, no slide. State is colour and depth. The indicator inside a control is the exception, as it is in React: a switch's thumb, a checkbox's tick, a radio's dot, a rating's fill.
- **Press is instant, release is slow.** The fill goes to its pressed colour in zero time and drains back over `NebaScale.durationFill`; edges, shadows and ink over `NebaScale.duration`, on `NebaScale.ease`.
- **Elevation `0` is no shadow at all**, and `NebaTokens.elevation(level)` is the only shadow there is: neutral, never tinted with the control's colour, with the CSS blur converted to Flutter's by `shadowBlurRadius`.
- **Translucency is a `BackdropFilter`** with `NebaTokens.blurSigma` and `saturation`, over the sheet colour the tokens give. A sheet or fill is mixed into `NebaTokens.backing`, never written with a bare alpha, so `withReducedTransparency` makes every one of them opaque at once; a high-contrast setting on the platform asks for exactly that.
- **No dark bottom bevel.** The plate is the top light edge and the full white hairline, `plateTop` and `plateEdge`, and there is no plate at all on a checkbox, a radio or a switch.
- **The focus ring shows for keyboard focus only**, as `:focus-visible` does, and a ring never changes the widget's size.
- **Don't express state with opacity.** A disabled control takes `disabledBg`, `disabledFg` and `disabledBorder`.

## Internal modules

`lib/src/internal/` is where a widget gets everything another widget also needs, so that two controls never answer the same question twice. Reach for these before writing a widget's own version:

| Module | What it holds |
| --- | --- |
| `color.dart` | `oklch()`, `color-mix()` in sRGB and OKLab, the CSS shadow blur, WCAG contrast |
| `motion.dart` | `nebaDuration`: zero on a press and for a reader who asked for less motion |
| `surface.dart` | `NebaSheet`: the blur and saturation behind, the fill, the grain, the 148° sheen, the plate, the edge and the elevation shadow, with the plate drawn over the content for a sheet a picture fills (`plateOnTop`); and `tintPlate`, the opaque bed of a `text` mark that may land on any sheet |
| `interaction.dart` | `NebaInteractive`: hover, press on the pointer going down, keyboard focus, Enter and Space, and the pointer's position as a listenable. `focusable` keeps a busy or read-only control in the focus order while it takes no input |
| `glow.dart` | `NebaGlow`: the 88-pixel spotlight and the 72-pixel afterglow, and which colours a variant lights with |
| `focus_ring.dart` | `NebaFocusRing`: two pixels, two pixels off, eased in colour and never in width |
| `ink.dart` | `NebaInk`: a label's and an icon's colour, eased with the fill |
| `animate.dart` | `NebaEntrance`: what a `transition` plays, every effect on one tree of opacity, translation, transform and clip, and every pass of a repeat on one clock |
| `button_group.dart` | `NebaButtonGroupScope`, which a button reads between its own argument and the provider; `NebaJoin` and `NebaJoinScope`, the sides of a control that face a neighbour; `NebaJoinedRun`, the run that squares those corners, overlaps outline hairlines and paints the hovered or focused control on top, with each member's `NebaRunIndex`; and `NebaToggleGroupScope`, the value, the one focus stop and the arrow keys a toggle group shares with its toggles |
| `breakpoint.dart` | `nebaShownAt` and `NebaWidthGate`: whether a window width is in a range of breakpoints, and the children a container leaves out because a `NebaShow` among them is hidden. A container that lays out a list of children passes it through `nebaPresentChildren` |
| `ring.dart` | `NebaRingScope` and `NebaRing`: the ring a ringed pile asks for, drawn by the first widget below it that draws a shape, around that shape. Every widget with a shape of its own wraps it in `NebaRing` |
| `scroll_fade.dart` | `NebaEdgeFade`: a scrolling box's content masked out at each edge that has more beyond it, for ScrollArea and the Tabs bar |
| `initials.dart` | `initialsOf`: the first character of a name's first word and of its last, for Avatar and AppLogo |
| `messages.dart` | `NebaLocale`, `registerNebaMessages`, `nebaMessages` and `fillNebaMessage`: the words a widget says on its own behalf, by namespace, in the React package's namespaces |
| `svg_path.dart`, `glyphs.dart` | The React package's SVG glyphs, read from the same path data: ×, chevron, tick, minus, plus, dot, the turning ring and the severity set, and `NebaSpinner`, the ring turning at 900 milliseconds a turn |

The pointer's position is a `ValueListenable` rather than state, because it changes every frame the pointer moves and only the light needs it, which is why the React package writes it to two custom properties instead of re-rendering. Hover is tracked with a `MouseRegion` of its own, not the focus detector's hover highlight, which only reports while the focus manager is in keyboard mode.

**The message tables are generated, never written.** `messages_en.dart`, `lib/src/locales/*.dart` and `lib/locales.dart` come out of the React package's `src/internal/i18n.ts` and `src/locales/*.ts` through `tool/generate.dart`. A widget that needs a new word gets it added on the React side first, in English and in every language that has it, and then the generator brings it over; `test/internal/messages_test.dart` fails on a key or a placeholder a language has and English does not.

## Porting a component

One component is one commit, `[dart] feat: port NebaX to Flutter, with its tests, demos, docs and props table`, and it holds all of these:

1. `lib/src/components/{name}/neba_{name}.dart`, with the React props under the same names. A difference is allowed only where Flutter's idiom demands it — `onPressed` for `onClick`, `child` for `children`, `semanticLabel` for `aria-label`, a controlled `value` with `onChanged` — and each one is written on the docs page.
2. `dart run tool/generate.dart`, which adds the export to the barrel. `test/package/generated_test.dart` fails until it is run.
3. `test/components/{name}/neba_{name}_test.dart`, covering what the React test for the same component covers, asked the way Flutter asks it: a laid-out size instead of a class name, the `BoxDecoration` actually built instead of a CSS variable, semantics instead of ARIA. Pump it with `host()` from `test/support/host.dart`, never inside a `MaterialApp`.
4. Demos under `example/lib/demos/{name}/`, one file per React demo, named after it: `docs/.vitepress/demos/button/variants.tsx` becomes `example/lib/demos/button/variants.dart` declaring `ButtonVariants`, registered as `button/variants`. The registry takes the class the path names and fails on a file that declares none, so a helper widget such as an icon can sit anywhere in the file. A demo that holds a photograph, a face or a logo takes a copy of the docs' own file under `example/assets/samples/`, at the same path it has under `docs/public/samples/`, and loads it with `Image.asset`; `example/test/samples_test.dart` fails when the two differ. Then `dart run tool/generate.dart` again, and quote the file under the page's preview in a `::: fw flutter` block; `cd ../../docs && npm run flutter:demos -- --force` rebuilds the previews to look at it.
5. The component's documentation page in both locales: what differs between the packages inside `::: fw react` and `::: fw flutter`, the Flutter props table in `../../docs/.vitepress/data/props-flutter/{page}.ts`, and `flutter: true` in the frontmatter, which takes the "not in the Flutter package yet" note off the page. The root guide's Documentation section says how each works.
6. An entry in `CHANGELOG.md` under `vNext`, and its box ticked in `../../TODO.md`.

## Tests

`flutter test` runs everything, headless, with no device. Besides the component tests:

- `test/package/framework_surface_test.dart` — no Material, no Cupertino, no mirrors, no dependency.
- `test/package/generated_test.dart` — the barrel and the demo registry are up to date.
- `test/package/pub_limits_test.dart` — `CHANGELOG.md`, `README.md` and `LICENSE` stay under the 256 KiB pub.dev accepts. The React changelog is already past it, so when this one approaches it, older sections move to a `CHANGELOG.archive.md` that `.pubignore` leaves out.
- `test/theme/tokens_parity_test.dart` — reads `../react/src/styles.css`, evaluates every token the way a browser does, and compares it with `NebaTokens` in both themes and under reduced transparency. It also fails when a colour family gains a derived role the Dart side does not have.
- `test/internal/` — the arithmetic, checked directly: the colour conversions against values a browser gives.

A test that reads a file of the React package does so by a path relative to this folder, which is where `flutter test` runs.

## Commands

```bash
flutter pub get
flutter analyze
dart format lib test tool
flutter test
dart run tool/generate.dart            # after adding a component or a demo
dart run tool/generate.dart --check    # what the test runs
cd example && flutter run -d chrome    # the gallery
```

A desktop run of the gallery opens a window, so a test of it runs headless (`flutter test`) or in a browser, never as a desktop app in front of whoever is working on the machine.
