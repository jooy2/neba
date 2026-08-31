import { useRef, useState } from 'react';
import { Button, Card, NebaProvider, Segment, SegmentedButton, useColorScheme } from 'neba';

function Switch() {
  const { colorScheme, resolvedColorScheme, setColorScheme } = useColorScheme();

  return (
    <Card size="sm" title="Appearance" subtitle={`Currently showing ${resolvedColorScheme}`}>
      <SegmentedButton
        size="sm"
        value={colorScheme}
        onValueChange={(next) => setColorScheme(next as 'light' | 'dark' | 'system')}
      >
        <Segment value="light">Light</Segment>
        <Segment value="dark">Dark</Segment>
        <Segment value="system">System</Segment>
      </SegmentedButton>
    </Card>
  );
}

export default function ProviderColorScheme() {
  const box = useRef<HTMLDivElement>(null);
  // Rendered once so the ref is filled before the provider's effect asks for it.
  const [, ready] = useState(0);

  return (
    <div ref={box} className="rounded-(--neba-radius-md) bg-(--neba-surface) p-4">
      {/* Pointed at this box rather than at `<html>`, so the switch repaints
          the preview and not the page around it. */}
      <NebaProvider colorSchemeElement={() => box.current} storageKey={false}>
        <div className="flex flex-col gap-3">
          <Switch />
          <Button variant="outline" onClick={() => ready(0)}>
            A control, for scale
          </Button>
        </div>
      </NebaProvider>
    </div>
  );
}
