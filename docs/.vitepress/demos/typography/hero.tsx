import { Typography } from 'neba';

export default function TypographyHero() {
  return (
    <div className="flex max-w-lg flex-col gap-2">
      <Typography level="overline">Changelog</Typography>
      <Typography level="h2">A sheet of cut acrylic</Typography>
      <Typography level="lead">
        Every surface in the library is the same material at a different opacity.
      </Typography>
      <Typography>
        The blur makes it a sheet of something; the noise makes that something acrylic rather than
        glass. Depth is not part of the surface — it is opt-in.
      </Typography>
      <Typography level="caption">Updated 2 minutes ago</Typography>
    </div>
  );
}
