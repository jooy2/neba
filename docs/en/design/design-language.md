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

That rule is about a **dyed** fill. `--neba-glass-bg` — the base under the outline and text variants, and the default surface of Card, Box and TextField — has no colour in it, so alpha is the only axis there is. Here alpha does not decide whether the backdrop is legible; it decides **whether the sheet reads as white**.

In the light theme, 42% let through more of the page than of the sheet itself. On any backdrop that is not pure white, that backdrop's grey came straight up through it and the whole surface went dull. **That is why it is 66%** — the blur is still 9px, so the backdrop is just as unreadable as before. The dark theme went 5% → 7% for the same reason.

### Container surfaces are never dyed

Box, Card and TextField draw their surface from `--neba-panel` / `-hover` / `-press` — **three strengths of an undyed white sheet**, not from the family's own `--neba-{color}-panel`.

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

So `Checkbox`, `Radio` and `Switch` keep the acrylic — the grain, the sheen and the backdrop blur are what make the box a sheet of something — and drop `--neba-plate-glass` and `--neba-plate-solid` entirely. They are the only controls in the library that do.

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

Every colour is defined in `oklch()`, because its lightness axis matches perception — which is what lets all six families be pinned to the same number.

### Only five values are hand-picked per family

```
--neba-{color}-solid          the fill's base colour
--neba-{color}-solid-hover    −4.5 lightness
--neba-{color}-solid-active   −12 lightness
--neba-{color}-on-solid       text on the fill
--neba-{color}-accent         readable on a surface (for the text/outline variants)
```

The rest (`-fill`, `-panel`, `-soft`, `-line`, `-ring`) are computed with `color-mix()` in the derived block. **Adding a colour family is two edits** — one entry in the `NebaColor` union and five lines in `styles.css`.

### Chroma goes to the gamut edge; lightness goes as far as contrast allows

When a family looks muddy, the cause is usually not its lightness but its **chroma**. The `oklch()` chroma ceiling in sRGB differs per hue and per lightness, and a colour sitting well under that ceiling reads as grey at the very same brightness. Neba's chroma is held at roughly **90% of the maximum** for each family's lightness — vivid, with enough margin that the browser never has to clip.

Lightness is not nearly as free. With a white `on-solid` and a fill at 88%, holding 4.5:1 over a white page pins the fill to the high 40s / low 50s. **A brighter fill means a darker ink** — which is exactly what `warning`, the one family that does it, is doing. Every step is checked against this, hover and active included.

> **Moving the hue a few degrees is also an option.** `success` went 152 → 148 and `info` 218 → 223. Both sit where sRGB is unusually narrow at mid lightness, and a few degrees to the side buys chroma that no amount of tuning at the original hue could.

> **The derived block is repeated per theme root.** A custom property resolves its `var()`s **on the element that declares it**. Declared only on `:root`, the derived tokens would freeze to their light-theme values inside a `.dark` subtree. That is why the selector is `:root, .dark, .light, [data-theme='dark'], [data-theme='light']`.

### Do not lighten the fill in dark mode

Pastel fills with dark text on them are a common dark-theme approach, but on a dark screen the fill itself becomes the light source and it hurts to look at. Neba keeps fills mid-tone in dark mode and keeps the text white. The only thing that lightens is `accent`, the colour that has to read on a surface.

### `warning` has dark text

White on amber does not reach 4.5:1 at any lightness. `--neba-warning-on-solid` is the one dark brown in the set. Changing the text colour is the right answer; distorting the family to preserve contrast is not.

---

## 3. Size and density

### `size` — height and type scale

|        | xs   | sm   | md       | lg   | xl   |
| ------ | ---- | ---- | -------- | ---- | ---- |
| Height | 22px | 26px | **32px** | 40px | 48px |
| Text   | 11px | 12px | **13px** | 15px | 17px |
| Radius | 10px | 12px | **14px** | 18px | 22px |

The uneven steps are deliberate. `md` is the desktop workhorse, `xs`/`sm` are for toolbars and table rows, and `lg`/`xl` are for the one action a screen is about. Marching up in equal 4px increments would make five steps look like two.

`xl` at 48px clears the 44px mobile touch target.

### The radius is 45% of the height

At 50% it is a pill. Stopping at 45% leaves a flat run along the top and bottom edge, and that flat run is what reads as a plate with its corners cut off.

### `density` — padding, and only padding

```
default   10 / 12 / 16 / 20 / 24px
compact    6 /  8 / 10 / 12 / 16px
```

**Density touches neither the height nor the type scale.** Two controls of the same `size` are the same height whatever their density, so a row of mixed-density controls keeps its baseline. The two tracks are roughly 2:1, so the difference is legible at a glance.

---

## 4. Elevation

```ts
type NebaElevation = 0 | 1 | 2 | 3;
```

**The default is 0, and 0 means no shadow at all.** What separates a surface from the page is the acrylic edge, not a drop shadow. Raise it only for surfaces that genuinely float above the content around them.

Hovering adds a level and pressing removes one, so a control at elevation 0 still answers a press without growing a shadow. Level 4 is only reachable by hovering a level-3 surface.

**Never tint a shadow with the control's own colour.** A coloured glow is the loudest thing a small control can do. Every `--neba-shadow-*` is neutral.

---

## 5. Motion

### Controls do not move

**Do not use `transform`.** Scaling a control resamples its label, and text that shimmers under the cursor undoes every other bit of restraint. State changes are expressed **in colour and depth only**.

### Press is instant, release is slow

This asymmetry is the house interaction signature. The same principle drives two things.

**The fill** — per-property durations, with `:active` overriding all of them to 0ms.

```
transition-property: background-color, border-color, box-shadow, color;
transition-duration: var(--neba-duration-fill), var(--neba-duration), …;  /* 340ms, 160ms… */
```

```
&:active { transition-duration: 0ms }
```

The colour lands on the frame of the press and then takes 340ms to drain back out.

**The afterglow layer** — the same trick applied to `opacity`. No JavaScript, no ripple element, no timers.

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

### The pointer spotlight

`.neba-glow::before` is a soft bloom trailing the cursor. The component writes `--n-mx`/`--n-my` straight to the element's inline style on `pointermove`.

**Do not hold this in React state.** The event fires at pointer rate, so a `setState` would re-render the tree on every mouse move. The coordinates are read from `offsetX`/`offsetY` rather than `getBoundingClientRect()`, so nothing forces a reflow. Icons carry `pointer-events: none`, so the offsets are always relative to the control.

Both layers respect `@media (hover: hover)` and `prefers-reduced-motion`.

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

> **Don't express state with opacity.** `opacity: 0.5` reads as "blurry" whatever the state is. Give each state its own axis — saturation, colour family, flatness.

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
focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2
```
