import { Box, Button, ButtonGroup, Show } from 'neba';

export default function ShowPair() {
  return (
    <Box className="w-full max-w-2xl">
      <Show below="sm">
        <Button fullWidth>Actions</Button>
      </Show>
      <Show above="sm">
        <ButtonGroup>
          <Button>Duplicate</Button>
          <Button>Archive</Button>
          <Button>Export</Button>
        </ButtonGroup>
      </Show>
    </Box>
  );
}
