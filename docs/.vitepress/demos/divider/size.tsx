import { Divider, Typography } from 'neba';

/**
 * `length` is the long axis and `thickness` is the short one, whichever way the
 * rule runs. Both take a number of pixels or any CSS length.
 */
export default function DividerSize() {
  return (
    <div className="flex w-full max-w-96 flex-col gap-4">
      <Typography level="caption">Full width, 1px — the default</Typography>
      <Divider />

      <Typography level="caption">length=&quot;50%&quot;</Typography>
      <Divider length="50%" />

      <Typography level="caption">length=&#123;120&#125; thickness=&#123;2&#125;</Typography>
      <Divider length={120} thickness={2} color="success" />

      <Typography level="caption">thickness=&quot;0.25rem&quot;</Typography>
      <Divider thickness="0.25rem" color="danger" />

      <Typography level="caption">Vertical, length=&#123;48&#125;</Typography>
      <div className="flex items-center gap-4">
        <Typography level="caption">before</Typography>
        <Divider orientation="vertical" length={48} thickness={2} color="info" />
        <Typography level="caption">after</Typography>
      </div>
    </div>
  );
}
