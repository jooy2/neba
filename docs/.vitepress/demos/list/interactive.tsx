import { useState } from 'react';
import { List, ListItem, Switch } from 'neba';

const CHANNELS = [
  { id: 'deploys', name: 'Deploys', detail: 'Every push to a tracked branch' },
  { id: 'failures', name: 'Failures', detail: 'Builds and health checks' },
  { id: 'digest', name: 'Weekly digest', detail: 'Sent on Monday morning' }
];

/**
 * A row that both navigates and holds a control has two things to press, which
 * is why `action` sits outside the pressable area rather than inside it.
 */
export default function ListInteractive() {
  const [on, setOn] = useState<string[]>(['deploys', 'failures']);
  const [open, setOpen] = useState('deploys');

  const toggle = (id: string) =>
    setOn((current) =>
      current.includes(id) ? current.filter((item) => item !== id) : [...current, id]
    );

  return (
    <div className="w-full max-w-96">
      <List dividers>
        {CHANNELS.map((channel) => (
          <ListItem
            key={channel.id}
            description={channel.detail}
            selected={open === channel.id}
            onClick={() => setOpen(channel.id)}
            action={
              <Switch
                size="sm"
                aria-label={`Turn ${channel.name} on`}
                checked={on.includes(channel.id)}
                onCheckedChange={() => toggle(channel.id)}
              />
            }
          >
            {channel.name}
          </ListItem>
        ))}
      </List>
    </div>
  );
}
