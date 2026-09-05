---
title: IconButton
order: 14
---

# IconButton

<p class="neba-lede">A round button holding a single glyph. Use it where there is no room for a label: a toolbar, a list row.</p>

<Demo src="icon-button/hero" />

```tsx
import { IconButton } from 'neba';

<IconButton icon={<PlusIcon />} label="Add item" />;
```

## Props

<PropsTable name="IconButton" />

Every native `<button>` attribute passes through. It uses [Button](./button)'s axes unchanged, including `variant`, `elevation`, `loading` and `readOnly`.

For a square icon control, a [Button](./button) with no `children` already is one.

## Examples

### size

The same control heights [Button](./button) uses, so a disc drops into a row of buttons without the row losing its baseline.

<Demo src="icon-button/sizes">

<<< @/.vitepress/demos/icon-button/sizes.tsx

</Demo>

### loading · readOnly · disabled

They behave exactly as the same props do on [Button](./button). `loading` puts a spinner in place of the glyph.

<Demo src="icon-button/states">

<<< @/.vitepress/demos/icon-button/states.tsx

</Demo>

### label

`label` is a required prop. A button whose only content is a glyph has no other way to get an accessible name, so the type demands one.

```tsx
// Type error.
<IconButton icon={<TrashIcon />} />

// This.
<IconButton icon={<TrashIcon />} label="Delete file" />
```

`label` is not shown on screen. Wrap the button in a [Tooltip](../feedback/tooltip) to make the name visible too.

## Accessibility

- `label` is passed through as `aria-label`.
- The focus ring only appears on `:focus-visible`.
