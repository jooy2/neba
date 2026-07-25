import { Card, List, ListItem } from 'neba';

export default function ListVariants() {
  return (
    <div className="w-full max-w-96">
      {/* `text` is the one to reach for inside a Card: the card is already a
          sheet, and a second bordered rectangle inside it is a rectangle too
          many. */}
      <Card title="Notifications" subtitle="Where the alerts go">
        <List variant="text" density="compact">
          <ListItem href="#email" description="jane@example.com">
            Email
          </ListItem>
          <ListItem href="#slack" description="#deploys">
            Slack
          </ListItem>
          <ListItem href="#webhook" description="Not configured">
            Webhook
          </ListItem>
        </List>
      </Card>
    </div>
  );
}
