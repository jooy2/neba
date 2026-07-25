import { Box, Button, TextField } from 'neba';

/**
 * The same `color` on a control and on a container.
 *
 * The Button's surface is the thing being coloured, so it takes the family's
 * tinted fill. The Box and the TextField hold content of their own, so their
 * sheet stays white and the family reaches only the edge, the ring and the
 * caret.
 */
export default function ColorSurfaces() {
  return (
    <div className="flex w-full max-w-2xl flex-col gap-4">
      {(['primary', 'success', 'danger'] as const).map((color) => (
        <div key={color} className="flex flex-wrap items-center gap-3">
          <Button color={color}>{color}</Button>
          <Button color={color} variant="outline">
            {color}
          </Button>
          <TextField color={color} placeholder={color} />
          <Box color={color} className="text-[0.8125rem]">
            {color}
          </Box>
        </div>
      ))}
    </div>
  );
}
