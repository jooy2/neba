---
title: FilePicker
order: 10
---

# FilePicker

<p class="neba-lede">A dashed box you drop files on, or press to open the file dialog.</p>

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

### Variants

All three share the dashed edge. It is the one place in the library that draws a line which is not solid, and it is not decoration — a dashed rectangle is the established sign for "this area accepts a drop", and a dropzone that looks like a card is a card nobody tries to drop on.

<Demo src="file-picker/variants">

<<< @/.vitepress/demos/file-picker/variants.tsx

</Demo>

### What it turns away

<Demo src="file-picker/rejection">

<<< @/.vitepress/demos/file-picker/rejection.tsx

</Demo>

### States

<Demo src="file-picker/states">

<<< @/.vitepress/demos/file-picker/states.tsx

</Demo>

## The browser does not apply `accept` to a dropped file

The `accept` attribute governs the browser's **own file dialog** and nothing else. A file that arrived by drag has never been checked against that string. A dropzone that only sets the attribute accepts anything the moment a file comes in by drop.

This component runs the check itself, against the same string, in the three forms the attribute takes: `.ext`, `type/subtype`, and `type/*`.

## A drag state that does not flicker

`dragenter` and `dragleave` fire for every **child** of the zone the pointer crosses. A dropzone that toggles a boolean therefore flickers the entire time a file is being dragged over its own contents. Counting the events is the fix, and the only thing that survives a zone with content in it.

## `maxFiles` is not "you may drop this many"

It is "you may end up with this many". It is checked against what is already held, so dropping three files on a `maxFiles={3}` picker that holds two accepts exactly one of them.

## Why there is no Base UI primitive

A dropzone is a `<div>` listening for four drag events and an `<input type="file">` it clicks for you. There is no popup to position, no focus to trap and no roving anything. The fallback the [design language](../../guide/design-language) allows — plain React and DOM — is the right one here.

What is left is the part hand-rolled dropzones usually get wrong, which is the three sections above.

## Accessibility

The shell is a `<div>` and the pressable area inside it is a real `<button>`. The file list sits **outside** that button, because the remove buttons cannot be nested inside the browse button — the same shape [Chip](../display/chip) and [ListItem](../display/list) use.

The real `<input type="file">` is moved off-screen rather than hidden. `display: none` and `visibility: hidden` both make an input unfocusable in some browsers, and this one still has to be reachable to a form and to a `required` validation message.

Pass `onReject`. Without it a rejected file disappears without a word.
