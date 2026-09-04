import { AppLogo, Footer, TextLink, Typography } from 'neba';

export default function FooterHero() {
  return (
    <Footer className="rounded-(--neba-radius-md)">
      <div className="flex flex-wrap items-start justify-between gap-8">
        <div className="flex flex-col gap-2">
          <AppLogo name="Neba" src="/128x128.png" showName size="sm" />
          <Typography level="caption" color="secondary">
            © 2026 Neba. All rights reserved.
          </Typography>
        </div>

        <nav className="flex gap-10">
          <div className="flex flex-col gap-1.5">
            <Typography level="overline">Product</Typography>
            <TextLink href="#">Components</TextLink>
            <TextLink href="#">Changelog</TextLink>
          </div>
          <div className="flex flex-col gap-1.5">
            <Typography level="overline">Company</Typography>
            <TextLink href="#">About</TextLink>
            <TextLink href="#">Privacy</TextLink>
          </div>
        </nav>
      </div>
    </Footer>
  );
}
