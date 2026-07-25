import { Button, ButtonGroup } from 'neba';

export default function ButtonGroupHero() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <ButtonGroup variant="outline" color="secondary">
        <Button>Day</Button>
        <Button>Week</Button>
        <Button>Month</Button>
      </ButtonGroup>

      <ButtonGroup>
        <Button>Deploy</Button>
        <Button aria-label="More options">▾</Button>
      </ButtonGroup>
    </div>
  );
}
