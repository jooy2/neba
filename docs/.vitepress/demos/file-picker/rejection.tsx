import { useState } from 'react';
import { Alert, FilePicker, type FileRejection } from 'neba';

const WHY: Record<FileRejection['reason'], string> = {
  type: 'is not an image',
  size: 'is over 100 kB',
  count: 'would be the third file'
};

/**
 * A rejected file that vanishes without a word is the worst thing a dropzone
 * does, which is why `onReject` exists at all: the component turns files away,
 * and only the application knows how to say so.
 */
export default function FilePickerRejection() {
  const [files, setFiles] = useState<File[]>([]);
  const [rejected, setRejected] = useState<FileRejection[]>([]);

  return (
    <div className="flex w-full flex-col gap-3">
      <FilePicker
        multiple
        accept="image/*"
        maxSize={100_000}
        maxFiles={2}
        title="Images only, under 100 kB, two at a time"
        hint="Try dropping something else"
        value={files}
        onFilesChange={(next) => {
          setFiles(next);
          setRejected([]);
        }}
        onReject={setRejected}
      />

      {rejected.length > 0 ? (
        <Alert color="warning" title="Some files were turned away" onClose={() => setRejected([])}>
          {rejected.map(({ file, reason }) => `${file.name} ${WHY[reason]}`).join(' · ')}
        </Alert>
      ) : null}
    </div>
  );
}
