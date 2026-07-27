import { Pill, Typography } from 'neba';

function DotIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <circle cx="8" cy="8" r="4" fill="currentColor" />
    </svg>
  );
}

const VARIANTS = ['solid', 'outline', 'text'] as const;
const SIZES = ['sm', 'md', 'lg'] as const;

/**
 * A Pill is a *control* as far as colour goes, not a container: its surface is
 * the thing being coloured, exactly as on a Button or a Chip.
 */
export default function PillVariants() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center gap-3">
        {VARIANTS.map((variant) => (
          <Pill key={variant} variant={variant} color="primary" startIcon={<DotIcon />}>
            {variant}
          </Pill>
        ))}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        {SIZES.map((size) => (
          <Pill key={size} size={size} color="success" startIcon={<DotIcon />}>
            size {size}
          </Pill>
        ))}
      </div>

      <div className="flex flex-wrap items-center gap-3">
        <Pill density="compact" color="secondary" startIcon={<DotIcon />}>
          compact
        </Pill>
        <Pill elevation={0} color="secondary" startIcon={<DotIcon />}>
          elevation 0
        </Pill>
        <Typography level="caption">Density is padding; elevation is how far it floats.</Typography>
      </div>
    </div>
  );
}
