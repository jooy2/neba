import { Footer, Typography } from 'neba';

export default function FooterVariant() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <Footer key={variant} variant={variant} className="rounded-(--neba-radius-md)">
          <Typography level="caption" color="secondary">
            variant=&quot;{variant}&quot;
          </Typography>
        </Footer>
      ))}
    </div>
  );
}
