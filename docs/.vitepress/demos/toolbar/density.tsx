import { Button, ButtonGroup, TextField, Toolbar, Typography } from 'neba';

const DENSITIES = ['default', 'compact'] as const;

/**
 * A Toolbar has no height of its own. It is as tall as the controls in it plus
 * its padding — and `density` is that padding, which is the only thing it is
 * ever allowed to change.
 */
export default function ToolbarDensity() {
  return (
    <div className="flex w-full flex-col gap-5">
      {DENSITIES.map((density) => (
        <div key={density} className="flex flex-col gap-2">
          <Typography level="caption">density=&quot;{density}&quot;</Typography>
          <Toolbar
            density={density}
            className="w-full"
            start={<Typography level="h6">Files</Typography>}
            end={
              <ButtonGroup variant="outline" size="sm" color="secondary">
                <Button>Rename</Button>
                <Button>Move</Button>
              </ButtonGroup>
            }
          >
            <TextField size="sm" placeholder="Filter…" fullWidth />
          </Toolbar>
        </div>
      ))}
    </div>
  );
}
