---
title: Design language
order: 1
---

# Design language

A Neba surface is **a sheet of cut acrylic, not a moulded plastic key**. That one sentence is the reason for every rule below. When a new component leaves you unsure, come back to it.

What that sentence takes, and what it leaves out:

- **Taken**: light catching the top edge of a surface, translucency over a blurred backdrop, an elevation scale with distinct steps.
- **Dropped**: the dark bevel underneath, gloss and refraction, bulk, and shadows that are always on.

---

## 1. The surface

Every filled surface is four layers, in this order and at these strengths.

| Layer    | Token                 | Job                                                   |
| -------- | --------------------- | ----------------------------------------------------- |
| Fill     | `--neba-{color}-fill` | The colour, opaque to `--neba-fill-alpha` (88%)       |
| Backdrop | `--neba-blur`         | `blur(9px) saturate(1.5)`                             |
| Grain    | `--neba-grain`        | A noise tile composited in `overlay`                  |
| Edge     | `--neba-plate-solid`  | A bright top line plus a 1px white hairline all round |

### Translucency is tuned with the blur, not just the alpha

Lowering the alpha does not by itself make glass. **The blur radius is what decides whether the backdrop is legible.** At 16px a grid line behind the control smears into flat colour and the surface reads opaque again. Held at 9px, the backdrop is present but never resolves into something you could read.

88% is the floor for 4.5:1 white-on-fill over a white page. **Fill lightness was picked against that number, not against opaque.** Lower the alpha and the lightness has to come down with it.

### The undyed sheet (`--neba-glass-bg`) is the exception

That rule is about a **dyed** fill. `--neba-glass-bg` (the base under the outline and text variants, and the default surface of Card, Box and TextField) has no colour in it, so alpha is the only axis there is. Here alpha does not decide whether the backdrop is legible; it decides **whether the sheet reads as white**.

In the light theme, 42% let through more of the page than of the sheet itself. On any backdrop that is not pure white, that backdrop's grey came straight up through it and the whole surface went dull. **That is why it is 66%**: the blur is still 9px, so the backdrop is just as unreadable as before. The dark theme went the other way, from 7% to 5%: on a near-black page every step of opacity lightens the sheet the ink is read on, and [colour](./color) measures the ink there.

### Container surfaces are never dyed

Box, Card and TextField draw their surface from `--neba-panel` / `-hover` / `-press`: **three strengths of an undyed white sheet**, not from the family's own `--neba-{color}-panel`.

What a container holds is other people's content, and it arrives with its own colours: body text, links, buttons, fields. Tinting the sheet underneath puts every one of them on a background they were not chosen against. So **the family stops at the hairline, the focus ring and the caret, and the sheet stays white.**

Controls are the opposite case and keep the tinted `--neba-{color}-panel`, because a Button's surface _is_ the thing being coloured.

It is also why the three steps rise in **opacity** rather than lightness: as a surface is engaged it holds more light, instead of turning grey.

> **One consequence.** On a `solid` Box or Card, which has no border, `color` has nothing left to reach and makes no visible difference. On a container, `color` is effectively the prop that picks the edge.

### The grain is what makes it acrylic

Translucency plus blur alone gives you polished glass. Noise is what makes it sandblasted acrylic. One 120px `feTurbulence` tile (fractalNoise, three octaves) goes in as a data URI and sits over the fill in `background-blend-mode: overlay`. The tile is 12% alpha, decoded once, and reused by every surface on the page.

### No dark bevel on the edge

`inset 0 -1px 0 black` turns a surface into injection-moulded plastic immediately. Use only the bright top line (`--neba-plate-top`) and the white hairline around the whole plate (`--neba-plate-edge`).

### A tick wears no plate at all

The plate is a 1px line, so how much of a surface it is depends on how big that surface is. On a 32px button it is light catching a cut edge. On an 18px checkbox, an 18px radio or a 20px switch track it is a bevel drawn at a fifteenth of the object, and a bevel that heavy on something that small reads as a toolbar icon from 2008.

So `Checkbox`, `Radio` and `Switch` keep the acrylic (the grain, the sheen and the backdrop blur are what make the box a sheet of something), and drop `--neba-plate-glass` and `--neba-plate-solid` entirely. They are the only controls in the library that do.

### The sheen is off-vertical

`linear-gradient(148deg, …)`. A symmetric gradient falling straight down says nothing about where the light is coming from, which leaves the surface looking painted rather than cut. Tilting it a few degrees reads as light arriving from one side.

---

## 2. Colour

This section is the _why_. For what the tokens actually resolve to and how to override them, see [Colour](./color).

The base colour is `#4072cd`; everything else comes off its palette.

| Role        | Where it comes from                    |
| ----------- | -------------------------------------- |
| `primary`   | The base colour                        |
| `secondary` | Slate that keeps the base colour's hue |
| `success`   | A toned-down triadic green             |
| `warning`   | The complementary amber                |
| `danger`    | A split-complementary vermilion        |
| `info`      | The analogous cyan                     |

Every colour is defined in `oklch()`, because its lightness axis matches perception, and that is what lets all six families be pinned to the same number.

### Only five values are hand-picked per family

```
--neba-{color}-solid          the fill's base colour
--neba-{color}-solid-hover    −4.5 lightness
--neba-{color}-solid-active   −12 lightness
--neba-{color}-on-solid       text on the fill
--neba-{color}-accent         readable on a surface (for the text/outline variants)
```

The rest (`-fill`, `-panel`, `-soft`, `-line`, `-ring`) are computed with `color-mix()` in the derived block. **Adding a colour family** is an entry in the `NebaColor` union, the five base values in each theme block and the derived tokens that mix them; [colour](./color#adding-a-family) lists every edit.

### Chroma goes to the gamut edge; lightness goes as far as contrast allows

When a family looks muddy, the cause is usually not its lightness but its **chroma**. The `oklch()` chroma ceiling in sRGB differs per hue and per lightness, and a colour sitting well under that ceiling reads as grey at the very same brightness. Neba's chroma is held at roughly **90% of the maximum** for each family's lightness: vivid, with enough margin that the browser never has to clip.

Lightness is not nearly as free. With a white `on-solid` and a fill at 88%, holding 4.5:1 over a white page pins the fill to the high 40s / low 50s. **A brighter fill means a darker ink**, and `warning` is the one family that makes that trade. Every step is checked against this, hover and active included.

> **Moving the hue a few degrees is also an option.** `success` went 152 → 148 and `info` 218 → 223. Both sit where sRGB is unusually narrow at mid lightness, and a few degrees to the side buys chroma that no amount of tuning at the original hue could.

> **The derived block is repeated per theme root.** A custom property resolves its `var()`s **on the element that declares it**. Declared only on `:root`, the derived tokens would freeze to their light-theme values inside a `.dark` subtree. That is why the selector is `:root, .dark, .light, [data-theme='dark'], [data-theme='light']`.

### Do not lighten the fill in dark mode

Pastel fills with dark text on them are a common dark-theme approach, but on a dark screen the fill itself becomes the light source and it hurts to look at. Neba keeps fills mid-tone in dark mode and keeps the text white. The only thing that lightens is `accent`, the colour that has to read on a surface.

### In dark mode, ink is measured on the raised sheet

The panel ladder is opacity: `--neba-panel` and its two steps lay white over whatever is behind them. On a white page that changes nothing, so a light-theme value measured on `--neba-surface` still reads the same inside a Card, inside a popup, under a table header. On a near-black page every step multiplies the bed's luminance instead, and the steps compound: a Card is 2.1x the page, and a header band inside that Card is 4.9x. Ink picked against the bare sheet loses most of its contrast the moment it sits on a raised one.

`--neba-muted-fg`, `--neba-disabled-fg` and `--neba-border` are therefore solved against a table header inside a Card — the deepest bed the library composes for itself — and checked back down the ladder from there. Muted ink reads 5.05:1 there and 4.34:1 with a page shell around it as well, against the 4.33-4.64:1 the light theme reads everywhere.

> **The dark ladder is 5/7/9%, and it used to be 7/10/13%.** Those were picked for how a sheet reads against the page, and the page was all they were checked against; compounded they put a table header at 7.5x the sheet and squeezed the whole ink hierarchy into the top of its range. Lowering them costs less than it looks — the light ladder moves a sheet's lightness by nothing at all, and it is the hairline and the plate edge that say where a Card begins there.

> **The hairline inverts rather than merely weakening.** In light the border sits just below every bed it is drawn on. A dark value picked on the bare sheet ends up _darker_ than a raised one, so the edge that is supposed to catch the light reads as a black scratch — which is what a TreeView's rails and a chart's grid on a Card were doing. The dark hairline sits above the whole ladder instead, and is more present on a plain page than its light counterpart. One value cannot be a whisper across a ladder that moves.

### Text on a tinted bed is `on-tint`, not `accent`

`panel` and `soft` are both washes of the family's own `accent`, so writing the label in that accent puts a colour on a pale copy of itself. The ink and the bed move together, and no change to either one opens the gap: past a wash of about 9% the pair cannot reach 4.5:1, and `soft-press` is 25%. An `on` Toggle, a `text` Chip, a highlighted menu row and an `outline` Button under the pointer all sat between 3.4:1 and 4.5:1 — in **both** themes.

`--neba-{color}-on-tint` is the ink for those beds, the way `on-solid` is the ink for a fill. It is `accent` pulled 28% toward `--neba-fg`, so it flips with the theme on its own: toward near-black on a white page, toward near-white on a dark one. The family's hue survives, and every family clears 4.5:1 on every step of both ladders. `accent` itself is unchanged, so a TextLink, a Statistic's delta and an Alert's title on the bare sheet look exactly as they did.

### `warning` has dark text

White on amber does not reach 4.5:1 at any lightness. `--neba-warning-on-solid` is the one dark brown in the set. Changing the text colour is the right answer; distorting the family to preserve contrast is not.

---

## 3. Size and density

### `size`: height and type scale

|        | xs   | sm   | md       | lg   | xl   |
| ------ | ---- | ---- | -------- | ---- | ---- |
| Height | 22px | 26px | **32px** | 40px | 48px |
| Text   | 11px | 12px | **13px** | 15px | 17px |
| Radius | 10px | 12px | **14px** | 18px | 22px |

The uneven steps are deliberate. `md` is the desktop workhorse, `xs`/`sm` are for toolbars and table rows, and `lg`/`xl` are for the one action a screen is about. Marching up in equal 4px increments would make five steps look like two.

`xl` at 48px clears the 44px mobile touch target.

### What is drawn and what is pressed are two boxes

A tick, a switch and the × on a Chip are not on the height ladder. They are sized against the text beside them, and text is smaller than a finger: a `md` tick is 18px where WCAG 2.5.8 asks for 24.

So those controls carry `.neba-hit`. An empty `::before` grows the box that is pressed, and only on the axis that is short: a switch is already past 24px wide at every step, so it grows upward and downward only. **Nothing drawn moves by a pixel.**

It is not applied to the controls on the height ladder. An `xs` Button is 22px and equally short, but a Button stands in a row of other Buttons and its label is the target: growing it two pixels past its own edge would take the press off whatever it was next to.

### The radius is 45% of the height

At 50% it is a pill. Stopping at 45% leaves a flat run along the top and bottom edge, and that flat run is what reads as a plate with its corners cut off.

### `density`: padding, and only padding

```
default   10 / 12 / 16 / 20 / 24px
compact    6 /  8 / 10 / 12 / 16px
```

**Density touches neither the height nor the type scale.** Two controls of the same `size` are the same height whatever their density, so a row of mixed-density controls keeps its baseline. The two tracks are roughly 2:1, so the difference is legible at a glance.

DataTable is the one exception. A compact table lowers its default row height as well, because a table row is not a row of controls that has to share a baseline.

---

## 4. Elevation

```ts
type NebaElevation = 0 | 1 | 2 | 3;
```

**The default is 0, and 0 means no shadow at all.** What separates a surface from the page is the acrylic edge, not a drop shadow. Raise it only for surfaces that genuinely float above the content around them.

Hovering adds a level and pressing removes one, so a control at elevation 0 still answers a press without growing a shadow. Level 4 is only reachable by hovering a level-3 surface.

**Never tint a shadow with the control's own colour.** A coloured glow is the loudest thing a small control can do. Every `--neba-shadow-*` is neutral.

### Everything portalled sits on one z-index

A menu, a dialog, a drawer, a tooltip and a toast are drawn at the end of the document rather than where they were written, and all of them read `--neba-z-portal`, which is `50`.

That number is the library's guess, and it is the host's decision. A site whose own fixed header sits at 1200 raises it once:

```css
:root {
  --neba-z-portal: 1400;
}
```

Nothing in the library layers a popup against another popup, so one value covers all of them. Inside a surface — a sticky table header, a chart's tooltip — the small `z-index`es are local to that component and never leave it.

---

## 5. Motion

### Controls do not move

**Do not use `transform`.** Scaling a control resamples its label, and text that shimmers under the cursor undoes every other bit of restraint. State changes are expressed **in colour and depth only**.

### Press is instant, release is slow

This asymmetry is the house interaction signature. The same principle drives two things.

**The fill**: per-property durations, with `:active` overriding all of them to 0ms.

```
transition-property: background-color, border-color, box-shadow, color;
transition-duration: var(--neba-duration-fill), var(--neba-duration), …;  /* 340ms, 160ms… */
```

```
&:active { transition-duration: 0ms }
```

The colour lands on the frame of the press and then takes 340ms to drain back out.

**The afterglow layer**: the same trick applied to `opacity`. No JavaScript, no ripple element, no timers.

```css
.neba-glow::after {
  opacity: 0;
  transition: opacity 900ms cubic-bezier(0.22, 1, 0.36, 1);
}
.neba-glow:active::after {
  opacity: 1;
  transition-duration: 0ms;
}
```

### The indicator is the one thing inside a control that may travel

The rule above is about the control: the box with the label on it. The mark _inside_ it is a different object: it carries no text, nothing about it is resampled, and it is the whole of what the state says. Those are allowed to move, and they move on a real property rather than on a `transform`.

There are four of them, and they are the whole list. A Switch's thumb travels on `inset-inline-start`, so on and off swap ends under RTL. A Checkbox's tick draws itself along its own length, on `stroke-dashoffset` over a path normalised with `pathLength="1"`. A Radio's dot grows out of the centre of its ring, on `width` and `height`. A Rating's fill sweeps across the star the pointer is on, on `width`.

What none of them does is scale. A mark that arrived at 1.4× and settled would be resampled twice on the way, which is the same objection the control's own rule makes.

### A photograph in a frame that does not move is the one thing that may scale

`Gallery`'s `hover="zoom"` is the exception, and it is opt-in rather than the default. What it moves is a photograph inside a tile whose own edges stay exactly where they were: the frame is `overflow: hidden` and never changes size, so nothing on the page shifts and nothing beside it is pushed. The objection the rule is made of does not apply either: a photograph carries no label, so there is no text to resample and none to shimmer under the cursor.

The default is `lift`, which is depth, and `dim`, which is colour. Those are how everything else in the library answers a pointer, and a gallery that does not ask for a zoom does not get one.

`Image`'s `rotate` and `flip` are the other transforms a photograph takes, and they are not motion at all. The caller sets them once and nothing under the pointer changes them, and a quarter turn or a mirror moves every pixel onto another pixel rather than resampling it. They are written on the individual `rotate` and `scale` properties rather than on `transform`, so a zoom on the same photograph still applies on top.

### A floating surface arrives and leaves in opacity, and nothing else

Every popup, panel, sheet, backdrop and toast in the library fades. None of them slides, scales or wipes, and the reason is the rule above read one level up: a popup is _mostly text_ (a menu row the pointer was already reaching for, a dialog somebody has started reading, a calendar cell under a finger that is already moving), so a surface that travels drags all of it across the screen for the length of the journey.

It is one declaration and two state classes, written once in `internal/styles.ts` and read by every one of them. A component that defines its own is one more chance for a popup to behave unlike the rest.

The one thing that may travel besides opacity is the surface's own **size**, and only when the reader asked for it: a NavigationMenu's panel resizing between two menus of different heights is the panel staying still while its contents change, not the panel moving.

**A Drawer is the exception, and the exception is the whole of what a drawer is.** Every other floating surface appears where it will stay, so moving it drags text the reader's eye is already on. A drawer has a _home_: `side` is a prop, the panel is pinned to that edge, and until it opens it is not on the screen at all. Sliding it moves nothing that was being read, and fading it in throws away the only thing that distinguishes it from a Dialog. So the panel comes in from its edge and the scrim behind it fades: the pairing every platform uses, and the one place in the library where the motion carries the meaning rather than decorating it.

### The pointer spotlight

`.neba-glow::before` is a soft bloom trailing the cursor. `internal/glow.ts` writes `--n-mx`/`--n-my` straight to the element's inline style on `pointermove`.

**Do not hold this in React state.** The event fires at pointer rate, so a `setState` would re-render the tree on every mouse move. What actually changes is where a gradient is centred, which is a repaint of one box and not a layout; `pointermove` is already coalesced to one per frame; and only the hovered element paints at all. Both layers respect `@media (hover: hover)`, so a touch screen never paints one, and `prefers-reduced-motion`, which drops them entirely.

**Where the light goes is a rule, not a preference.** It is on a surface the pointer can act on _as a whole_ — a control, and a field's shell. It is not on a row of somebody else's content: a ListItem, an Accordion header, a Card are a layout the pointer lands _in_ rather than an object it lands _on_, and washing a caller's own content is not what the light is for. And it is not on anything the gradient is too big to describe — a tick, a slider's thumb, an OTP slot — where an eighty-eight pixel bloom over an eighteen pixel box is a flat wash that says nothing about where the pointer is.

**A press gets both layers; something that is merely entered gets the spotlight alone.** A Button, a Toggle, a Pill and a Segment are pressed and held, so they take the afterglow. A field is entered rather than pressed, a menu row is gone before a nine-hundred-millisecond flash is a third of the way out, and a tab that has been chosen has a panel already being read under it — all three take `spotlightSlot`, which leaves `--n-flash` unset and lets the afterglow fall back to `transparent`.

**Slots go on the surface that paints the light, never on a container of rows.** A custom property written on an element invalidates the style of everything under it, so a Menu lights its own rows, one at a time, and not the popup around them.

### The focus ring arrives, and on a field it is flush

The ring is declared at rest rather than not declared at all, at **no width and no colour**, and what the focus moves is the colour. `outline-style` is a discrete property, so a ring that exists only in the focused state has nothing to travel from; a colour has. It moves at the house duration, beside the hairline under it — the two are one edge, and an edge half of which is instant reads as two things happening.

It is the colour and deliberately not the width. A browser paints an outline at a whole device pixel, so a width travelling from 0 to 2px does not grow: it is a full 1px ring from the first frame after zero, holds there for the whole duration, and snaps to 2px at the end. Two jumps with a dead interval between them, which no easing can smooth.

The width stays at zero rather than sitting at 2px waiting to be coloured in, and that is what keeps a forced palette honest: a browser in forced colours replaces every colour it is given, `transparent` included, so a ring held at full width would be painted around every control on the page. What it costs is the way out — the ring fades in and then goes at once, which is the right way round for the one mark that says where the keyboard is.

On a **field's shell** the ring is flush with that edge rather than held two pixels off it. A field's hairline turns the ring's own colour the moment the focus lands, so an offset ring draws a second line with a stripe of page between the two — the shape that reads as a control wearing a halo instead of an edge that has thickened.

Everywhere else it keeps the offset, and the reason is contrast rather than taste: a ring flush against a **filled** control sits on a fill of its own family, and `--n-ring` over `--n-fill` is not something to rely on. A field's sheet is the undyed panel, which is what makes it the exception.

### A ceiling on the flourish

The light effects are **the highlight riding on top of the press, not the press itself**. The press is the fill going dark. That is why `--neba-flash-on-fill` is only a shade brighter than the spotlight it replaces.

---

## 6. States

The three states each have to speak on their own axis, and each has to be distinguishable from the default at a glance.

| State | How it is expressed | Why |
| --- | --- | --- |
| `disabled` | Drops the colour family entirely for neutral grey | A faded colour still reads as "this is the primary action, only blurrier" |
| `loading` | Unchanged, with a spinner in the `startIcon` slot | It is in progress, not unavailable |
| `readOnly` | Keeps the colour, goes flat, `saturate(0.55)` | A label that happens to be button-shaped |

Only `disabled` uses the native `disabled` attribute. `loading` and `readOnly` are marked with `aria-disabled`, keep focus, and stop activation in the handler.

> **Don't express state with opacity.** `opacity: 0.5` reads as "blurry" whatever the state is. Give each state its own axis: saturation, colour family, flatness.

---

## 7. Implementation rules

### Branch state in JS, not in CSS

Two Tailwind variants of equal specificity are resolved by **their order in the generated stylesheet**. That is not a property a component may depend on.

```ts
// like this
disabled ? disabledClasses[variant] : readOnly ? readOnlyClasses[variant] : restClasses[variant];

// not like this — the precedence of data-disabled: against data-readonly: is undefined
('data-disabled:bg-gray-200 data-readonly:bg-blue-500');
```

### Colour slots go in inline styles

Tailwind only ever sees **class names that appear literally in the source**. Hardcoding `[--n-fill:var(--neba-primary-fill)]` per family means dozens of classes for every colour added. Generate the `--n-*` slots as inline styles instead.

```ts
'--n-fill': `var(--neba-${color}-fill)`;
```

This is the only kind of reason to step outside Tailwind: **step outside only when Tailwind cannot express it.**

### Move it to CSS when it stops being readable

`.neba-glow` is a real class in `styles.css` rather than a set of Tailwind utilities because `[&::before]:[background:radial-gradient(…)]` is technically expressible and impossible to maintain. Styling that puts a gradient on a pseudo-element belongs in CSS.

### Never use `outline-none`

Tailwind v4's `outline-*` utilities route the style through `--tw-outline-style`. An `outline-none` anywhere on the element sets that variable to `none` and **the focus ring disappears entirely.** Use the shorthand.

```
[outline:0_solid_transparent] outline-offset-2 focus-visible:[outline:2px_solid_var(--n-ring)]
```

The resting declaration is what the focused one travels from, and the focused one carries the whole shorthand rather than the colour alone — a host stylesheet's `:focus-visible { outline: auto }`, which normalize and several site themes ship, is one selector, and a class alone would be decided against it by generation order.

An `[outline:none]` beside that is the same mistake in the other spelling: two `outline` declarations of equal specificity. The ring is already declared at no width, which is what takes the browser's own outline off.
