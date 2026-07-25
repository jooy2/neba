import { useState } from 'react';
import { FilePicker } from 'neba';

export default function FilePickerHero() {
  const [files, setFiles] = useState<File[]>([]);

  return (
    <FilePicker
      multiple
      label="Attachments"
      accept="image/*,.pdf"
      maxSize={5_000_000}
      maxFiles={4}
      hint="PNG, JPG or PDF · up to 5 MB each · 4 files"
      description="Dropped files are checked against accept too, which the browser does not do."
      value={files}
      onFilesChange={setFiles}
    />
  );
}
