import { Typography } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function TypographyColors() {
  return (
    <div className="flex flex-col gap-1.5">
      <Typography>No colour asked for — inherits the page.</Typography>
      {COLORS.map((color) => (
        <Typography key={color} color={color}>
          {color}
        </Typography>
      ))}
    </div>
  );
}
