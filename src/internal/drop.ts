/**
 * Whether what was dropped is a file at all.
 *
 * A folder dragged onto a page arrives in `dataTransfer.files` as a `File` with
 * no type and a size of zero, and there is no flag on it that says so. The only
 * thing that does is `webkitGetAsEntry`, which is on the *item* rather than on
 * the file — so the two lists are walked in step, and a browser too old to have
 * it is left trusting what it was given.
 *
 * Silently accepting a folder is worse than refusing it: it goes into the list
 * looking like a file, and the upload that follows sends nothing.
 *
 * It is here rather than in whichever component needed it first because two
 * take files now — a [FilePicker](../components/inputs/file-picker), and a
 * [PromptInput](../components/agent/prompt-input) whose shell is a drop target.
 * A second copy would eventually disagree about folders, which is the one case
 * neither of them is checked against by hand.
 */
export function droppedFiles(transfer: DataTransfer): File[] {
  const items = [...transfer.items];
  const files = [...transfer.files];

  // The two out of step means the browser has told us nothing we can line up,
  // so the files are returned as they are rather than filtered by the wrong
  // index.
  if (items.length !== files.length) {
    return files;
  }

  return files.filter((_, index) => {
    const entry = items[index]?.webkitGetAsEntry?.();

    return entry ? entry.isFile : true;
  });
}
