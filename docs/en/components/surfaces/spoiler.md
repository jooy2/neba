---
title: Spoiler
order: 9
flutter: true
---

# Spoiler

<p class="neba-lede">Content that stays covered until somebody asks for it. The cover is a blur rather than a hidden box, so a reader can see that there is something there and how much of it, without reading it by accident.</p>

<Demo src="spoiler/hero" />

::: fw react

```tsx
import { Spoiler } from 'neba';

<Spoiler locale="ko">
  <p>로즈버드는 썰매의 이름이었습니다.</p>
</Spoiler>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaSpoiler(
  locale: Locale('ko'),
  child: Text('로즈버드는 썰매의 이름이었습니다.'),
);
```

:::

## Props

<PropsTable name="Spoiler" />

::: fw react

Every other `<div>` attribute passes through to the root, except `onChange`: the change worth listening for is `onRevealedChange`.

:::

::: fw flutter

The covered content is `child`, and the words on the cover are widgets. A Spoiler takes the width it is given.

:::

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### maxHeight and reversible

Without `maxHeight` the box is exactly as tall as what it holds. The cover keeps its place once the content is out, so the box does not shrink on the press and nothing on the page below moves.

`maxHeight` clamps the covered box to <Fw react="a CSS length or a number in pixels" flutter="a height in logical pixels" />. Revealing releases the clamp, and the content takes whatever height it needs.

`reversible` puts a hide button under the content so the cover can go back on. Its row is held open while the content is still covered, so covering it again does not change the box's height either.

<Demo src="spoiler/clamped">

::: fw react

<<< @/.vitepress/demos/spoiler/clamped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/clamped.dart

:::

</Demo>

### locale

::: fw react

The button and the line above it are the only words the component invents, and `locale` is which language they are in: a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Tags with no translation fall back to English, and a regional tag resolves to its language: `ko-KR` is `ko`, `zh-TW` is Traditional.

:::

::: fw flutter

The button and the line above it are the only words the component invents, and `locale` is which language they are in, then `NebaProvider`'s, then the app's. A language is there once the app registers it from `package:neba/locales.dart` with `registerNebaMessages`; one with no translation falls back to English, and a regional locale resolves to its language: `ko-KR` is `ko`, `zh-TW` is Traditional.

:::

<Demo src="spoiler/locale">

::: fw react

<<< @/.vitepress/demos/spoiler/locale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/locale.dart

:::

</Demo>

### label, description, action and blur

`label` changes the button's words and `description` changes the line above it; <Fw react="`description={false}`" flutter="`showDescription: false`" /> leaves the cover with nothing written on it. `blur` decides how hard the content is blurred, in pixels.

`action` replaces the button entirely, and that replacement is yours to wire up, through `revealed` and `onRevealedChange`.

<Demo src="spoiler/words">

::: fw react

<<< @/.vitepress/demos/spoiler/words.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/words.dart

:::

</Demo>

### padded

The box pads its content on Box's own scale. Turn it off for something that should reach the edges: the corners then crop the picture the way they do on any other sheet.

<Demo src="spoiler/media">

::: fw react

<<< @/.vitepress/demos/spoiler/media.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/media.dart

:::

</Demo>

### variant

`text` draws no box at all, which is what a spoiler in the middle of running prose usually wants. `solid` is the filled sheet, for one that is meant to stop the reader.

<Demo src="spoiler/inline">

::: fw react

<<< @/.vitepress/demos/spoiler/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/inline.dart

:::

</Demo>

### Controlled

Pass `revealed` and the Spoiler stops keeping state of its own. Use it to reveal several at once, to remember what a reader has already uncovered, or to put the control somewhere else on the page.

::: fw react

```tsx
const [revealed, setRevealed] = useState(false);

<Spoiler revealed={revealed} onRevealedChange={setRevealed}>
  <p>The butler did it.</p>
</Spoiler>;
```

:::

::: fw flutter

```dart
NebaSpoiler(
  revealed: revealed,
  onRevealedChange: (bool next) => setState(() => revealed = next),
  child: const Text('The butler did it.'),
);
```

:::

## Accessibility

::: fw react

- While it is covered the content is `inert`: out of the tab order, off the accessibility tree, and out of a select-all.
- The reveal button carries `aria-expanded` and `aria-controls`, pointing at the content it uncovers.
- Set `locale` so the button and the notice are read out in the page's own language, or write them out in `label` and `description`.

:::

::: fw flutter

- While it is covered the content is out of the focus order, the semantics tree, the pointer's reach and any selection a `SelectionArea` around it makes.
- The reveal button is heard as collapsed and the hide button as expanded. When one of them had the focus, the focus moves to the content that was revealed, or back to the cover's button.
- Set `locale` so the button and the notice are read out in the page's own language, or write them out in `label` and `description`.

:::
