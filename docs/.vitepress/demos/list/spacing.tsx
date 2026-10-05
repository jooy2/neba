import { useState } from 'react';
import { List, ListItem } from 'neba';

const PROJECTS = [
  { id: 'web', name: 'web', detail: 'Deployed 4 minutes ago' },
  { id: 'api', name: 'api', detail: 'Deployed 2 hours ago' },
  { id: 'docs', name: 'docs', detail: 'Deployed yesterday' }
];

export default function ListSpacing() {
  const [open, setOpen] = useState('web');

  return (
    <div className="w-full max-w-80">
      <List spacing={1}>
        {PROJECTS.map((project) => (
          <ListItem
            key={project.id}
            description={project.detail}
            selected={open === project.id}
            onClick={() => setOpen(project.id)}
          >
            {project.name}
          </ListItem>
        ))}
      </List>
    </div>
  );
}
