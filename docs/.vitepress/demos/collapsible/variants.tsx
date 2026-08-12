import { Collapsible, Typography } from 'neba';

export default function CollapsibleVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <Collapsible variant="solid" title="solid" defaultOpen>
        <Typography>A filled sheet, for the fold a screen is about.</Typography>
      </Collapsible>

      <Collapsible variant="outline" title="outline">
        <Typography>A hairline around frosted acrylic. The default.</Typography>
      </Collapsible>

      <Collapsible variant="text" title="text">
        <Typography>No sheet at all, for a fold inside running prose or a Card.</Typography>
      </Collapsible>
    </div>
  );
}
