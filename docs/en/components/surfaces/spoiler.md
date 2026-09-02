---
title: Spoiler
order: 9
---

# Spoiler

<p class="neba-lede">Content that stays covered until somebody asks for it. The cover is a blur rather than a hidden box, so a reader can see that there is something there and how much of it, without reading it by accident.</p>

<Demo src="spoiler/hero" />

```tsx
import { Spoiler } from 'neba';

<Spoiler locale="ko">
  <p>로즈버드는 썰매의 이름이었습니다.</p>
</Spoiler>;
```

## Props

<PropsTable name="Spoiler" />

Every other `<div>` attribute passes through to the root, except `onChange` — the change worth listening for is `onRevealedChange`.

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### maxHeight

Left out, the box is exactly as tall as what it holds — right for a paragraph or a picture. `maxHeight` clamps the covered box instead, and revealing lets go of the clamp so the content takes whatever height it needs. It takes a CSS length or a number in pixels.

`reversible` puts the cover back on afterwards, with a hide button under the content. Its row is held open while the content is still covered, so the box is the same height either way and nothing on the page moves when it is pressed.

<Demo src="spoiler/clamped">

<<< @/.vitepress/demos/spoiler/clamped.tsx

</Demo>

### locale

The button and the line above it are the only words the component invents, and `locale` is which language they are in: a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Tags with no translation fall back to English, and a regional tag resolves to its language — `ko-KR` is `ko`, `zh-TW` is Traditional.

<Demo src="spoiler/locale">

<<< @/.vitepress/demos/spoiler/locale.tsx

</Demo>

### label, description and action

`label` changes the button's words and `description` changes the line above it; `description={false}` leaves the cover with nothing written on it. `blur` decides how hard the content is blurred, in pixels.

`action` replaces the button entirely — and that replacement is yours to wire up, through `revealed` and `onRevealedChange`.

<Demo src="spoiler/words">

<<< @/.vitepress/demos/spoiler/words.tsx

</Demo>

### padded

The box pads its content on Box's own scale. Turn it off for something that should reach the edges: the corners then crop the picture the way they do on any other sheet.

<Demo src="spoiler/media">

<<< @/.vitepress/demos/spoiler/media.tsx

</Demo>

### variant

`text` draws no box at all, which is what a spoiler in the middle of running prose usually wants. `solid` is the filled sheet, for one that is meant to stop the reader.

<Demo src="spoiler/inline">

<<< @/.vitepress/demos/spoiler/inline.tsx

</Demo>

### Controlled

Pass `revealed` and the Spoiler stops keeping state of its own. Use it to reveal several at once, to remember what a reader has already uncovered, or to put the control somewhere else on the page.

```tsx
const [revealed, setRevealed] = useState(false);

<Spoiler revealed={revealed} onRevealedChange={setRevealed}>
  <p>The butler did it.</p>
</Spoiler>;
```

## Accessibility

- While it is covered the content is `inert`: out of the tab order, off the accessibility tree, and out of a select-all. A spoiler that could be defeated by a select-all is not a spoiler.
- The reveal button carries `aria-expanded` and `aria-controls`, pointing at the content it uncovers.
- Set `locale` so the button and the notice are read out in the page's own language, or write them out in `label` and `description`.
