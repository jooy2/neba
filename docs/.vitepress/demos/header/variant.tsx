import { AppLogo, Header } from 'neba';

export default function HeaderVariant() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <Header
          key={variant}
          variant={variant}
          position="static"
          brand={<AppLogo name="Neba" src="/128x128.png" showName size="sm" />}
          actions={<span className="text-(--neba-muted-fg) text-xs">{variant}</span>}
          className="rounded-(--neba-radius-md)"
        />
      ))}
    </div>
  );
}
