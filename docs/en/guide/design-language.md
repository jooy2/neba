---
title: Design language
order: 2
---

# Design language

A Neba surface is **a sheet of cut acrylic, not a moulded plastic key**. That one sentence is the reason for every rule below. When a new component leaves you unsure, come back to it.

It borrows the depth of Fluent UI, the elegance of Liquid Glass and the order of Material — and deliberately drops what each of them overdoes.

- **Taken** from Fluent: light catching the top edge of a surface. **Dropped**: the dark bevel underneath.
- **Taken** from Liquid Glass: translucency and a blurred backdrop. **Dropped**: gloss and refraction.
- **Taken** from Material: a clear elevation scale. **Dropped**: the bulk, and shadows that are always on.

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

### The grain is what makes it acrylic

Translucency plus blur alone gives you polished glass. Noise is what makes it sandblasted acrylic. One 120px `feTurbulence` tile (fractalNoise, three octaves) goes in as a data URI and sits over the fill in `background-blend-mode: overlay`. The tile is 12% alpha, decoded once, and reused by every surface on the page.

### No dark bevel on the edge

`inset 0 -1px 0 black` turns a surface into injection-moulded plastic immediately. Use only the bright top line (`--neba-plate-top`) and the white hairline around the whole plate (`--neba-plate-edge`).

### The sheen is off-vertical

`linear-gradient(148deg, …)`. The symmetric top-down gradient is what every framework ships, and it was the single biggest reason Neba used to look like Bootstrap.

---

## 2. Colour

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

> **The derived block is repeated per theme root.** A custom property resolves its `var()`s **on the element that declares it**. Declared only on `:root`, the derived tokens would freeze to their light-theme values inside a `.dark` subtree. That is why the selector is `:root, .dark, .light, [data-theme='dark'], [data-theme='light']`.

### Do not lighten the fill in dark mode

The Material approach — pastel fills with dark text — hurts on a dark screen. Neba keeps fills mid-tone in dark mode and keeps the text white. The only thing that lightens is `accent`, the colour that has to read on a surface.

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

The four states have to say four different things.

| State | How it is expressed | Why |
| --- | --- | --- |
| `disabled` | Drops the colour family entirely for neutral grey | A faded colour still reads as "this is the primary action, only blurrier" |
| `loading` | Unchanged, with a spinner in the `startIcon` slot | It is in progress, not unavailable |
| `readOnly` | Keeps the colour, goes flat, `saturate(0.55)` | A label that happens to be button-shaped |
| default | — | — |

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
