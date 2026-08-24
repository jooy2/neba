import { Typography, WindowPane } from 'neba';
import type { NebaWindowOs } from 'neba';

const systems: { os: NebaWindowOs; title: string; note: string }[] = [
  { os: 'macos', title: 'Finder', note: 'Traffic lights, centred title, Mica-flat bar' },
  { os: 'macosx', title: 'Finder', note: 'Aqua: striped bar, glossy lights, square feet' },
  { os: 'windows11', title: 'Explorer', note: 'Rounded corners, one sheet, no rule' },
  { os: 'windows10', title: 'Explorer', note: 'Square corners, white bar, ruled off' },
  { os: 'windows8', title: 'Explorer', note: 'Flat, and a band of colour round the edge' },
  { os: 'windows7', title: 'Explorer', note: 'Aero glass, glowing title, wider close' },
  { os: 'windowsxp', title: 'Explorer', note: 'Luna blue, framed, coloured plates' },
  { os: 'linux', title: 'Files', note: 'A header bar, taller, with circles' }
];

export default function WindowPaneOs() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-2">
      {systems.map(({ os, title, note }) => (
        <WindowPane key={os} os={os} title={title} height={130} active={os === 'macos'}>
          <div className="flex h-full flex-col gap-1 p-3">
            <Typography level="caption">os=&quot;{os}&quot;</Typography>
            <Typography level="caption" color="secondary">
              {note}
            </Typography>
          </div>
        </WindowPane>
      ))}
    </div>
  );
}
