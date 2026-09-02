import { Avatar, Button, Flex, Typography } from 'neba';

export default function FlexAlignment() {
  return (
    <Flex justifyContent="space-between" alignItems="center" spacing={3} className="w-full">
      <Flex alignItems="center" spacing={2}>
        <Avatar name="Kim Minji" size="sm" />
        <div>
          <Typography level="body">Kim Minji</Typography>
          <Typography level="caption" color="secondary">
            Owner
          </Typography>
        </div>
      </Flex>
      <Button size="sm" variant="outline">
        Manage
      </Button>
    </Flex>
  );
}
