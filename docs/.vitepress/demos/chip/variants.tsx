import { Chip } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function ChipVariants() {
  return (
    <div className="flex flex-col gap-3">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <div key={variant} className="flex flex-wrap items-center gap-2">
          {COLORS.map((color) => (
            <Chip key={color} variant={variant} color={color}>
              {color}
            </Chip>
          ))}
        </div>
      ))}
    </div>
  );
}
