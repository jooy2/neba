import { Button, ToastProvider, useToast } from 'neba';

function Raise() {
  const toast = useToast();

  const remove = () => {
    const id = toast.add({
      color: 'secondary',
      title: 'Deleted “Q3 forecast”',
      timeout: 0,
      actionLabel: 'Undo',
      onAction: () => toast.close(id)
    });
  };

  const upload = () =>
    toast.promise(
      new Promise<void>((resolve) => {
        setTimeout(resolve, 1600);
      }),
      {
        loading: { title: 'Uploading…', icon: false },
        success: { color: 'success', title: 'Uploaded' },
        error: { color: 'danger', title: 'Upload failed' }
      }
    );

  return (
    <div className="flex flex-wrap items-center gap-2">
      <Button size="sm" variant="outline" color="secondary" onClick={remove}>
        Delete something
      </Button>
      <Button size="sm" variant="outline" onClick={upload}>
        Upload a file
      </Button>
    </div>
  );
}

export default function ToastAction() {
  return (
    <ToastProvider position="bottom-center">
      <Raise />
    </ToastProvider>
  );
}
