---
title: Colour
order: 2
---

# Colour

Neba does not accept arbitrary colour values. `color` is one of **six semantic families**, not `#4072cd`, and a family is a set of tokens defined in `styles.css`.

```tsx
<Button color="danger">Delete</Button>
```

Only **five** values per family are hand-picked; everything else is `color-mix()`ed off those five. Those five are also the only thing you have to touch to re-skin a family.

## The palette

The values below are read back from what the browser actually computed. Hit the theme toggle and the table switches to the dark values.

<Demo src="color/palette" plain />

## How a family is built

A family is a set of `--neba-{family}-{role}` tokens.

### The five that are hand-picked

```css
--neba-{color}-solid          /* the fill's base colour */
--neba-{color}-solid-hover    /* −4.5 lightness */
--neba-{color}-solid-active   /* −12 lightness */
--neba-{color}-on-solid       /* text on the fill */
--neba-{color}-accent         /* readable on a surface (for text/outline variants) */
```

`solid` and `accent` are not two shades of one idea. `solid` is **a background to put text on**; `accent` is **text to put on a background**. That is why `accent` is the lighter and more saturated of the two — it is the one that has to hold contrast against a white page.

### The rest, derived

```css
--neba-{color}-fill           /* solid at --neba-fill-alpha (88%) */
--neba-{color}-fill-hover
--neba-{color}-fill-active
--neba-{color}-panel          /* accent 8%  + --neba-glass-bg — an outline control's surface */
--neba-{color}-panel-hover    /* accent 16% */
--neba-{color}-panel-press    /* accent 24% */
--neba-{color}-soft           /* accent 10% — the text variant's hover wash */
--neba-{color}-soft-hover     /* accent 17% */
--neba-{color}-soft-press     /* accent 25% */
--neba-{color}-line           /* accent 22% — the hairline */
--neba-{color}-line-hover     /* accent 40% */
--neba-{color}-ring           /* accent 55% — the focus ring */
```

> **The derived block is repeated per theme root.** A custom property resolves its `var()`s on the element that declares it, so derived tokens declared only on `:root` would freeze to their light values inside a `.dark` subtree. [Design language](./design-language) has the full reasoning.

## Container surfaces are never dyed

Only **controls** let a family flood their surface. Box, Card and TextField read a neutral, undyed set of three steps rather than the family's own `--neba-{color}-panel`.

```css
--neba-panel        /* white 66% (dark 7%) */
--neba-panel-hover  /* white 82% (dark 10%) */
--neba-panel-press  /* white 92% (dark 13%) */
```

What a container holds is other people's content, and it arrives with its own colours: body text, links, buttons, fields. Tinting the sheet underneath puts every one of them on a background they were not chosen against. So **the family stops at the hairline, the focus ring and the caret, and the sheet stays white.** A Button is the opposite case — its surface _is_ the thing being coloured — so it keeps the family fill.

<Demo src="color/surfaces">

<<< @/.vitepress/demos/color/surfaces.tsx

</Demo>

It is also why the three steps rise in **opacity** rather than lightness: an engaged surface holds more light instead of turning grey.

> **One consequence.** On a `solid` Box or Card, which has no border, `color` has nothing left to reach and makes no visible difference. On a container, `color` is effectively the prop that picks the edge.

## Contrast

Every colour is defined in `oklch()`, because its lightness axis matches perception — which is what lets all six families be pinned to the same number.

- **Text on a fill holds 4.5:1.** All three steps — `solid`, `hover`, `active` — checked against the 88%-opaque fill over a white page.
- **`accent` clears 5:1 on white**, with the margin sized so it still clears 4.5:1 on the faintly tinted `panel`.
- **Chroma sits near 90% of the sRGB gamut ceiling.** Well under it and the colour reads grey at the very same brightness; over it and the browser clips.

Lightness is not as free as it looks. With a white `on-solid` and a fill at 88%, holding 4.5:1 pins the fill to the high 40s / low 50s. **A brighter fill means a darker ink**, and `warning` is the one family that does exactly that.

## Changing a colour

Re-declare the five and the whole family follows. To give the dark theme its own values, declare the same five on `.dark`.

```css
:root {
  --neba-primary-solid: oklch(50% 0.24 300);
  --neba-primary-solid-hover: oklch(45.5% 0.232 300);
  --neba-primary-solid-active: oklch(38% 0.204 300);
  --neba-primary-on-solid: oklch(99% 0.004 300);
  --neba-primary-accent: oklch(54% 0.26 300);
}
```

Neba's dark theme follows `prefers-color-scheme` and can be forced either way with `.dark` / `[data-theme='dark'|'light']`.

### To scope an override, make the element a theme root

For a different family colour in one part of the app rather than all of it, the wrapper has to **be a theme root** — it needs `.dark`, `.light` or `[data-theme='…']` on it.

```html
<!-- Does nothing: the buttons keep their old colour -->
<div style="--neba-primary-solid: oklch(50% 0.24 300)">…</div>

<!-- Works -->
<div data-theme="light" style="--neba-primary-solid: oklch(50% 0.24 300)">…</div>
```

The theme roots are where the derived block is declared, and a custom property resolves its `var()`s on the element that declares it. Put the five on a plain `<div>` and those five values are inherited, but `--neba-primary-fill` is still the one `:root` computed from the **old** `solid`. Making the element a theme root is what recomputes the derived block there.

The two panels below are exactly the same markup. Only the right one is wrapped that way.

<Demo src="color/override">

<<< @/.vitepress/demos/color/override.tsx

</Demo>

> **Do not override a derived token.** Overriding something like `--neba-primary-panel` directly changes that one token and leaves the other twelve on the original family colour. Always edit the five base values instead.

## Adding a family

Adding one to the library is two edits — the `NebaColor` union in [`src/types.ts`](https://github.com/jooy2/neba/blob/main/src/types.ts) and five lines in `styles.css` per theme. The derived block computes the rest.

From the consuming side, `NebaColor` is a closed union, so a new name cannot be passed in. If you need another family, please open an issue.

## The tokens that are not families

The neutral tokens live in the same file.

```css
--neba-surface        /* the page background */
--neba-fg             /* body text */
--neba-muted-fg       /* secondary text */
--neba-border         /* a neutral rule */
--neba-disabled-bg    /* inactive controls — the family is dropped, not faded */
--neba-disabled-fg
--neba-disabled-border
--neba-glass-bg       /* the undyed acrylic a family panel is mixed into */
```

Why a disabled control **drops** its family rather than fading it is in [Design language](./design-language): a faded accent still says "this is the primary action", only blurrier.
