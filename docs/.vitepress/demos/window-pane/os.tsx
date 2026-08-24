import { Typography, WindowPane } from 'neba';
import type { NebaWindowOs } from 'neba';

const systems: { os: NebaWindowOs; title: string }[] = [
  { os: 'macos', title: 'Finder' },
  { os: 'windows11', title: 'Explorer' },
  { os: 'windows10', title: 'Explorer' },
  { os: 'linux', title: 'Files' }
];

export default function WindowPaneOs() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-2">
      {systems.map(({ os, title }) => (
        <WindowPane key={os} os={os} title={title} height={140}>
          <div className="p-3">
            <Typography level="caption" color="secondary">
              os=&quot;{os}&quot;
            </Typography>
          </div>
        </WindowPane>
      ))}
    </div>
  );
}
