import { Box } from 'neba';

export default function BoxVariants() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      <Box variant="solid">solid</Box>
      <Box variant="outline">outline</Box>
      <Box variant="text">text</Box>
    </div>
  );
}
