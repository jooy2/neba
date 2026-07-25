import { useState } from 'react';
import { Button, ButtonGroup, ToastProvider, useToast, type ToastPosition } from 'neba';

const POSITIONS: ToastPosition[] = [
  'top-start',
  'top-center',
  'top-end',
  'bottom-start',
  'bottom-center',
  'bottom-end'
];

function Raise({ position }: { position: ToastPosition }) {
  const toast = useToast();

  return (
    <Button size="sm" onClick={() => toast.add({ title: position, timeout: 2500 })}>
      Raise one here
    </Button>
  );
}

export default function ToastPositions() {
  const [position, setPosition] = useState<ToastPosition>('bottom-end');

  return (
    <div className="flex flex-col items-start gap-3">
      <ButtonGroup size="xs" variant="outline" color="secondary">
        {POSITIONS.map((option) => (
          <Button
            key={option}
            variant={option === position ? 'solid' : 'outline'}
            onClick={() => setPosition(option)}
          >
            {option}
          </Button>
        ))}
      </ButtonGroup>

      {/* The provider is keyed by the position so the whole stack moves at once
          rather than leaving the toasts already on screen behind. */}
      <ToastProvider key={position} position={position} width={300}>
        <Raise position={position} />
      </ToastProvider>
    </div>
  );
}
