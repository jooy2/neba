import { useState } from 'react';
import { Chip, TreeItem, TreeView } from 'neba';

const LABELS: Record<string, string> = {
  overview: 'Overview',
  traffic: 'Traffic',
  errors: 'Errors',
  billing: 'Billing',
  members: 'Members'
};

export default function TreeViewSelection() {
  const [selected, setSelected] = useState<(string | number)[]>(['traffic']);

  return (
    <div className="flex flex-wrap items-start gap-4">
      <TreeView
        label="Reports"
        multiple
        selected={selected}
        onSelectedChange={setSelected}
        defaultExpanded={['analytics']}
        className="w-56"
      >
        <TreeItem value="overview" label="Overview" />
        <TreeItem value="analytics" label="Analytics">
          <TreeItem value="traffic" label="Traffic" />
          <TreeItem value="errors" label="Errors" />
        </TreeItem>
        <TreeItem value="account" label="Account">
          <TreeItem value="billing" label="Billing" />
          <TreeItem value="members" label="Members" />
        </TreeItem>
      </TreeView>

      <div className="flex flex-wrap gap-1.5">
        {selected.length === 0 ? (
          <Chip size="sm" variant="outline">
            Nothing chosen
          </Chip>
        ) : (
          selected.map((value) => (
            <Chip
              key={value}
              size="sm"
              onDelete={() => setSelected(selected.filter((entry) => entry !== value))}
            >
              {LABELS[String(value)] ?? value}
            </Chip>
          ))
        )}
      </div>
    </div>
  );
}
