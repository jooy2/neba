import { Button, ToastProvider, useToast } from 'neba';

function Raise() {
  const toast = useToast();

  return (
    <div className="flex flex-wrap items-center gap-2">
      <Button
        size="sm"
        onClick={() =>
          toast.add({ color: 'success', title: 'Deployed', description: 'production · 4m 02s' })
        }
      >
        Deploy
      </Button>
      <Button
        size="sm"
        variant="outline"
        color="danger"
        onClick={() =>
          toast.add({
            color: 'danger',
            title: 'Deploy failed',
            description: 'The build exited with code 1.',
            timeout: 0,
            actionLabel: 'Retry'
          })
        }
      >
        Fail a deploy
      </Button>
    </div>
  );
}

export default function ToastHero() {
  return (
    <ToastProvider>
      <Raise />
    </ToastProvider>
  );
}
