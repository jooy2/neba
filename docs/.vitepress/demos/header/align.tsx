import { useState } from 'react';
import { AppLogo, Button, Header, SegmentedButton, Segment, TextLink } from 'neba';
import type { NebaAlign } from 'neba';

export default function HeaderAlign() {
  const [align, setAlign] = useState<NebaAlign>('center');

  return (
    <div className="flex w-full flex-col gap-4">
      <SegmentedButton
        size="sm"
        value={align}
        onValueChange={(next) => setAlign(next as NebaAlign)}
      >
        <Segment value="start">start</Segment>
        <Segment value="center">center</Segment>
        <Segment value="end">end</Segment>
      </SegmentedButton>

      <Header
        align={align}
        position="static"
        brand={<AppLogo name="Neba" showName shape="app" size="sm" />}
        actions={
          <Button size="sm" variant="outline">
            Sign in
          </Button>
        }
        className="rounded-(--neba-radius-md)"
      >
        <nav className="flex items-center gap-4">
          <TextLink href="#" underline="hover">
            Docs
          </TextLink>
          <TextLink href="#" underline="hover">
            Pricing
          </TextLink>
        </nav>
      </Header>
    </div>
  );
}
