import { Button, Toolbar, Typography } from 'neba';

/**
 * `position="sticky"` is what an application header usually wants: it takes up
 * its own space, so nothing underneath has to be padded around it. `divider`
 * gives it the rule that says there is content beneath.
 *
 * The box below scrolls; the bar does not.
 */
export default function ToolbarSticky() {
  return (
    <div className="h-64 w-full overflow-y-auto rounded-(--neba-radius-md) [border:1px_solid_var(--neba-border)]">
      <Toolbar
        position="sticky"
        divider
        variant="solid"
        density="compact"
        start={<Typography level="h6">Changelog</Typography>}
        end={
          <Button size="sm" variant="text">
            Subscribe
          </Button>
        }
      />

      <div className="flex flex-col gap-3 p-4">
        {Array.from({ length: 12 }, (_, index) => (
          <Typography key={index} level="body">
            {`1.0.${12 - index} — a release note long enough to make the page scroll under the bar.`}
          </Typography>
        ))}
      </div>
    </div>
  );
}
