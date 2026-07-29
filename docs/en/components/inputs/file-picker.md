---
title: FilePicker
order: 10
---

# FilePicker

<p class="neba-lede">A dropzone you drag files onto, or press to open the file dialog. It checks size, type and count, and reports back what it turned away.</p>

<Demo src="file-picker/hero" />

```tsx
import { FilePicker } from 'neba';

<FilePicker
  multiple
  label="Attachments"
  accept="image/*,.pdf"
  maxSize={5_000_000}
  maxFiles={4}
  onFilesChange={setFiles}
  onReject={setRejected}
/>;
```

## Props

<PropsTable name="FilePicker" />

## Examples

### variant

All three weights share the dashed edge, which is the established sign that an area accepts a drop.

<Demo src="file-picker/variants">

<<< @/.vitepress/demos/file-picker/variants.tsx

</Demo>

### accept · maxSize · maxFiles

The browser's `accept` attribute only governs its own file dialog and never a file that arrived by drag, so this component runs the same string itself. All three forms are supported: `.ext`, `type/subtype` and `type/*`.

`maxFiles` is not how many may be dropped at once but **how many may be held in total**. Dropping three files on a `maxFiles={3}` picker that already holds two accepts exactly one.

### onReject

Reports the files that were turned away and why. Without this handler a rejected file disappears with no feedback, so always pass it.

<Demo src="file-picker/rejection">

<<< @/.vitepress/demos/file-picker/rejection.tsx

</Demo>

### disabled · readOnly · error

<Demo src="file-picker/states">

<<< @/.vitepress/demos/file-picker/states.tsx

</Demo>

### title · hint · icon · showList

`title` and `hint` are the copy inside the dropzone and `icon` the glyph above it. `showList` renders the chosen files under the zone, and `removeLabel` names each remove button.

## Accessibility

- The shell is a `<div>` and the pressable area inside it is a real `<button>`. The file list sits outside that button, so the remove buttons are never nested inside the browse button.
- The `<input type="file">` is moved off-screen rather than set to `display: none`, which makes an input unfocusable in some browsers and would block `required` validation messages.
- The drag state is tracked by counting events, so it does not flicker as the pointer crosses children of the dropzone.
