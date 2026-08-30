import { Toggle } from 'neba';

const variants = ['solid', 'outline', 'text'] as const;

export default function ToggleVariants() {
  return (
    <div className="flex flex-col gap-4">
      {variants.map((variant) => (
        <div key={variant} className="flex items-center gap-3">
          <span className="w-16 text-[0.75rem] text-(--neba-muted-fg)">{variant}</span>
          <Toggle variant={variant}>Off</Toggle>
          <Toggle variant={variant} defaultPressed>
            On
          </Toggle>
          <Toggle variant={variant} disabled>
            Disabled
          </Toggle>
        </div>
      ))}
    </div>
  );
}
