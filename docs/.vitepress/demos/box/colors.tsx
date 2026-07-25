import { Box } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function BoxColors() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-3 sm:grid-cols-3">
      {COLORS.map((color) => (
        <Box key={color} color={color} variant="outline">
          {color}
        </Box>
      ))}
    </div>
  );
}
