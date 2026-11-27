---
title: FilePicker
order: 10
flutter: true
---

# FilePicker

<p class="neba-lede">A dropzone you drag files onto, or press to open the file dialog. It checks size, type and count, and reports back what it turned away.</p>

<Demo src="file-picker/hero" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaFilePicker(
  multiple: true,
  label: const Text('Attachments'),
  accept: 'image/*,.pdf',
  maxSize: 5000000,
  maxFiles: 4,
  onPick: pickWithTheAppsDialog,
  onFilesChange: (List<NebaFile> files) => setState(() => this.files = files),
  onReject: (List<NebaFileRejection> rejected) => setState(() => this.rejected = rejected),
);
```

:::

## Props

<PropsTable name="FilePicker" />

::: fw react

Native `<div>` attributes pass through to the root. `color`, `defaultValue` and `title` are excluded, since the table above spells them differently, and so is `children`, since the picker draws its own. `id` goes to the zone button rather than the root.

:::

::: fw flutter

The widgets layer has no file dialog and no drop target for files from outside the app, and the package takes no plugin, so the files reach the picker from the app, in any of three ways:

- **A press.** A press on the box, Enter or Space call `onPick`, which opens whatever dialog the app uses and hands back what was chosen. Without `onPick` the box takes only dropped files and is not in the focus order.
- **A drag inside the app.** The box is a `DragTarget`, so a `Draggable` whose `data` is a `NebaFile` or a `List<NebaFile>` is taken when it is dropped on it.
- **A drop from outside.** A drop target of the app's own, which a plugin provides, hands what lands on it to `drop()` on the picker's `NebaFilePickerState`, reached through a `GlobalKey`, and sets its `dragging` while a drag is over it, which lights the edge.

A file is a `NebaFile`: its `name`, its `size` in bytes, its media `type`, and `data`, the app's own handle on it, which the picker never reads. `icon` is a widget, and `showIcon: false` is React's `icon={null}`. There is no `name`, `required` or `id`, since there is no `<input type="file">` to submit or point a label at: a picker in a [Form](./form) takes part through a `NebaFormField`, whose `validator` says whether a file is required. `nebaFormatFileSize` writes a size as the list does, `formatFileSize`'s counterpart.

<PropsTable name="NebaFile" />

:::

## Examples

### variant

All three weights share the dashed edge.

<Demo src="file-picker/variants">

::: fw react

<<< @/.vitepress/demos/file-picker/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/variants.dart

:::

</Demo>

### accept · maxSize · maxFiles

::: fw react

The browser's `accept` attribute only governs its own file dialog and never a file that arrived by drag, so this component runs the same string itself. All three forms are supported: `.ext`, `type/subtype` and `type/*`.

:::

::: fw flutter

Every file is checked against `accept`, whichever way it arrived; hand the same string to the dialog `onPick` opens, so it offers only those. All three forms are supported: `.ext`, `type/subtype` and `type/*`.

:::

`maxFiles` is not how many may be dropped at once but **how many may be held in total**. Dropping three files on a <Fw react="`maxFiles={3}`" flutter="`maxFiles: 3`" /> picker that already holds two accepts exactly one.

### onReject

Reports the files that were turned away and why. Without this handler a rejected file disappears with no feedback, so always pass it.

<Demo src="file-picker/rejection">

::: fw react

<<< @/.vitepress/demos/file-picker/rejection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/rejection.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="file-picker/states">

::: fw react

<<< @/.vitepress/demos/file-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/states.dart

:::

</Demo>

### title · hint · icon · showList

`title` and `hint` are the copy inside the dropzone and `icon` the glyph above it. `showList` renders the chosen files under the zone, and `removeLabel` names each remove button.

## Accessibility

::: fw react

- The shell is a `<div>` and the pressable area inside it is a real `<button>`. The file list sits outside that button, so the remove buttons are never nested inside the browse button.
- The button is named by `label` followed by what the box says, so two pickers on one form are told apart by what each is for.
- The `<input type="file">` still takes part in `required` validation, and it holds exactly the files in the list, so a form submits a dropped file and not a removed one. A `readOnly` picker still submits what it holds; only `disabled` takes it out of the form.

:::

::: fw flutter

- The box is a button while it has an `onPick`, and the file list sits outside it, so each remove button is a button of its own.
- The box is named by a `Text` label followed by what the box says, so two pickers on one form are told apart by what each is for, and a `Text` description or error is read after it.
- Removing a file from the keyboard leaves the focus on the remove button now in its place, the one before it when the last went, and the box once nothing is left.

:::
