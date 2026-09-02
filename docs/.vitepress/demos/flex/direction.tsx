import { Button, Flex, TextField } from 'neba';

export default function FlexDirection() {
  return (
    // The commonest responsive form there is: a field and its action side by
    // side once there is room, and stacked before there is.
    <Flex direction={{ xs: 'vertical', sm: 'horizontal' }} spacing={2} className="w-full max-w-lg">
      <TextField label="Work email" placeholder="you@company.com" className="flex-1" fullWidth />
      <Button color="primary" className="sm:self-end">
        Request access
      </Button>
    </Flex>
  );
}
