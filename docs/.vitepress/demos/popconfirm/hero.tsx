import { useState } from 'react';
import { Button, IconButton, List, ListItem, Popconfirm, Typography } from 'neba';

const TrashIcon = () => (
  <svg viewBox="0 0 16 16" width="16" height="16" fill="none" stroke="currentColor">
    <path d="M3 4.5h10M6.5 4.5V3h3v1.5M4.5 4.5l.5 8h6l.5-8" strokeWidth="1.4" />
  </svg>
);

export default function PopconfirmHero() {
  const [rows, setRows] = useState(['staging.neba.dev', 'preview.neba.dev', 'docs.neba.dev']);

  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      <List variant="outline">
        {rows.map((row) => (
          <ListItem
            key={row}
            action={
              <Popconfirm
                title={`Remove ${row}?`}
                description="The domain stops resolving immediately."
                confirmLabel="Remove"
                onConfirm={() => setRows((all) => all.filter((entry) => entry !== row))}
                trigger={
                  <IconButton size="sm" variant="text" label="Remove" icon={<TrashIcon />} />
                }
              />
            }
          >
            {row}
          </ListItem>
        ))}
      </List>

      {rows.length === 0 ? (
        <Button variant="outline" onClick={() => setRows(['staging.neba.dev'])}>
          Put one back
        </Button>
      ) : (
        <Typography level="caption" className="text-(--neba-muted-fg)">
          The question stays beside the row it is about.
        </Typography>
      )}
    </div>
  );
}
