---
title: Dialog
order: 2
---

# Dialog

<p class="neba-lede">A modal sheet that covers the page until it is answered. Use it to confirm an action or to take input that has to interrupt the flow.</p>

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

There is no `variant` and no `elevation` — a modal always carries a level-3 shadow.

## Examples

### size and width

`size` sets the type scale and the padding along with the sheet's maximum width. When you need to break that pairing — small type on a wide sheet for a table or a diff — set a length in `width`.

<Demo src="dialog/sizes">

<<< @/.vitepress/demos/dialog/sizes.tsx

</Demo>

### dividers

With a long body, only the body scrolls; the heading and the actions stay put. `dividers` rules those boundaries, which is what shows the header did not scroll away.

<Demo src="dialog/scrolling">

<<< @/.vitepress/demos/dialog/scrolling.tsx

</Demo>

### dismissible

`dismissible={false}` blocks both Escape and the click outside. Turn it off only when `actions` holds a button that answers the dialog — otherwise there is no way out.

<Demo src="dialog/controlled">

<<< @/.vitepress/demos/dialog/controlled.tsx

</Demo>

### DialogClose

Closes the dialog from a button without owning the `open` state yourself. Use `render` to put the control you want inside it.

```tsx
actions={
  <>
    <DialogClose render={<Button variant="text" color="secondary">Cancel</Button>} />
    <DialogClose render={<Button color="danger">Delete</Button>} />
  </>
}
```

## Accessibility

- `title` and `description` are wired into `aria-labelledby` and `aria-describedby`. The title renders as a real `<h2>`.
- The focus trap, the scroll lock, the inert page behind, and focus returning to the trigger on close are all handled.
- `showClose` is on by default. The way out of a modal should always be visible, and it is also what a touch screen reader uses to escape the popup.
- `locale` decides the ×'s accessible name; `closeLabel` writes it out instead.
