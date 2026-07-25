---
title: Dialog
order: 2
---

# Dialog

<p class="neba-lede">A sheet that takes the page away until it is answered.</p>

<Demo src="dialog/hero" align="center" />

```tsx
import { Button, Dialog, DialogClose } from 'neba';

<Dialog
  trigger={<Button color="danger">Delete workspace</Button>}
  title="Delete this workspace?"
  description="Every project, deploy and log inside it goes with it."
  actions={<DialogClose render={<Button color="danger">Delete</Button>} />}
>
  This cannot be undone.
</Dialog>;
```

## Props

<PropsTable name="Dialog" />

## Examples

### Size is the width

<Demo src="dialog/sizes">

<<< @/.vitepress/demos/dialog/sizes.tsx

</Demo>

### A body that scrolls

Only the body scrolls; the heading and the actions stay put. That is what `dividers` is really for here — the hairlines are what say the header did not move.

<Demo src="dialog/scrolling">

<<< @/.vitepress/demos/dialog/scrolling.tsx

</Demo>

### A dialog that has to be answered

`dismissible={false}` turns off both Escape and the click outside. Turn it off only when the dialog has actions that answer it, because there will be no other way out.

<Demo src="dialog/controlled">

<<< @/.vitepress/demos/dialog/controlled.tsx

</Demo>

## Closing without owning state

An uncontrolled dialog has no `setOpen` for its Cancel button to call, and making every dialog controlled is a piece of state per dialog that exists only to answer a button. `DialogClose` is the way out: it is Base UI's own close part, so `render` puts a real Neba button inside it.

```tsx
actions={
  <>
    <DialogClose render={<Button variant="text" color="secondary">Cancel</Button>} />
    <DialogClose render={<Button color="danger">Delete</Button>} />
  </>
}
```

## One size axis, not two

MUI splits this into `size` and `maxWidth`. Here they are one: `size` sets the type scale, the padding **and** how wide the sheet may get. A second five-value scale would be a second spelling of an idea the library already has a word for — see [prop conventions](../../guide/prop-conventions).

The case the split exists for is real, though: small type on a wide sheet, for a table or a diff. That is what `width` is, and it is a hard number rather than a scale, so it never has to agree with anything.

## What it does not have

No `variant`: the three weights answer "how much does this surface assert itself against the page around it", and a modal has already taken the page.

No `elevation`: the popup is one of the two surfaces in the library that is _supposed_ to float, so it carries a level-3 shadow always. A dialog that could be told to sit flat would be a dialog that could be told to stop being a dialog.

## Accessibility

Base UI owns everything hard here — the focus trap, the scroll lock, the inert page behind, restoring focus to the trigger on close, and wiring `title` and `description` into `aria-labelledby` and `aria-describedby`. The title is a real `<h2>`, so a dialog appears in the document outline where it should.

`showClose` is on by default, unlike most booleans in this library. A modal takes the page away until it is answered, and the visible way out should not have to be remembered. It is also what a touch screen reader escapes the popup with.
