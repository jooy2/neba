import { useRef } from 'react';
import { Anchor, Box, Typography } from 'neba';

const SECTIONS = [
  { id: 'install', label: 'Install', depth: 0 },
  { id: 'setup', label: 'Setup', depth: 0 },
  { id: 'tailwind', label: 'With Tailwind', depth: 1 },
  { id: 'standalone', label: 'Standalone', depth: 1 },
  { id: 'first-component', label: 'First component', depth: 0 },
  { id: 'dark-mode', label: 'Dark mode', depth: 0 }
];

export default function AnchorHero() {
  const scroller = useRef<HTMLDivElement>(null);

  return (
    <div className="grid w-full max-w-2xl grid-cols-[1fr_auto] gap-6">
      <Box variant="outline" className="min-w-0">
        <div ref={scroller} className="h-64 overflow-y-auto pe-3">
          <div className="flex flex-col gap-6">
            {SECTIONS.map((section) => (
              <section key={section.id} id={section.id}>
                <Typography level="h6">{section.label}</Typography>
                <Typography level="body" color="secondary">
                  Two or three sentences of whatever this section is about, so there is something to
                  scroll past on the way to the next heading.
                </Typography>
              </section>
            ))}
          </div>
        </div>
      </Box>

      <Anchor
        size="sm"
        container={scroller}
        items={SECTIONS.map((section) => ({
          href: `#${section.id}`,
          label: section.label,
          depth: section.depth
        }))}
      />
    </div>
  );
}
