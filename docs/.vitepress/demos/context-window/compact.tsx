import { ContextWindow, Toolbar } from 'neba';

export default function ContextWindowCompact() {
  return (
    <div className="w-full max-w-sm">
      <Toolbar
        density="compact"
        start={
          <ContextWindow size="xs" max={200_000} used={124_000} breakdown={false} cost={0.42} />
        }
      />
    </div>
  );
}
