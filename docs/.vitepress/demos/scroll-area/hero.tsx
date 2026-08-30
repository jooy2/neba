import { Box, ScrollArea, Typography } from 'neba';

const CHANGES = [
  ['1.8.1', 'Every component marked with a client directive.'],
  ['1.8.0', 'Package dependencies upgraded.'],
  ['1.7.0', 'Every component got its own entry point.'],
  ['1.6.2', 'The pure annotations terser was throwing away.'],
  ['1.6.1', 'A header holds its three slots apart.'],
  ['1.6.0', 'PageLayout, Header, Footer and Sidebar.'],
  ['1.5.0', 'CodeBlock and HowToSteps.'],
  ['1.4.1', 'A floating bottom navigation stops moving on press.'],
  ['1.4.0', 'The eleven Animate wrappers.'],
  ['1.3.0', 'Mockup, Empty and DataTable.']
];

export default function ScrollAreaHero() {
  return (
    <Box variant="outline" className="w-full max-w-sm">
      <ScrollArea height={200} fade>
        <div className="flex flex-col gap-3 pe-3">
          {CHANGES.map(([version, note]) => (
            <div key={version} className="flex flex-col gap-0.5">
              <Typography level="caption" className="tabular-nums">
                {version}
              </Typography>
              <Typography level="body">{note}</Typography>
            </div>
          ))}
        </div>
      </ScrollArea>
    </Box>
  );
}
