import { Button, Popover, PopoverClose, Switch, TextField } from 'neba';

export default function PopoverHero() {
  return (
    <Popover
      trigger={<Button variant="outline">Share</Button>}
      title="Share this page"
      description="Anyone with the link can read it."
      showClose
    >
      <div className="flex flex-col gap-3">
        <TextField size="sm" label="Link" defaultValue="https://neba.cdget.com/p/8f2c1a" readOnly />
        <Switch size="sm" label="Allow comments" defaultChecked />
        <PopoverClose render={<Button size="sm">Copy link</Button>} />
      </div>
    </Popover>
  );
}
