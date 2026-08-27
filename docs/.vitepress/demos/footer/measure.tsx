import { Footer, Typography } from 'neba';

export default function FooterMeasure() {
  return (
    <Footer maxWidth="sm" className="rounded-(--neba-radius-md)">
      <Typography level="caption" color="secondary">
        The sheet spans the window; the content is held to 40rem and centred.
      </Typography>
    </Footer>
  );
}
