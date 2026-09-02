import { Box, Flex } from 'neba';

export default function FlexHero() {
  return (
    <Flex direction={{ xs: 'vertical', md: 'horizontal' }} spacing={3} className="w-full">
      <Box variant="solid" className="flex-1">
        A column on a phone
      </Box>
      <Box variant="solid" className="flex-1">
        A row from md
      </Box>
      <Box variant="solid" className="flex-1">
        Resize the window
      </Box>
    </Flex>
  );
}
