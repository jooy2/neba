import { Card, Tab, TabPanel, Tabs } from 'neba';

/**
 * A vertical bar is not just a rotated horizontal one: Base UI moves the arrow
 * keys onto the other axis with it, which is what makes it reachable at all.
 */
export default function TabsOrientation() {
  return (
    <div className="grid w-full grid-cols-1 gap-5 lg:grid-cols-2">
      <Tabs orientation="vertical" defaultValue="general" size="sm">
        <Tab value="general">General</Tab>
        <Tab value="members">Members</Tab>
        <Tab value="tokens">Tokens</Tab>
        <Tab value="webhooks">Webhooks</Tab>

        <TabPanel value="general">The project name, its slug and its default branch.</TabPanel>
        <TabPanel value="members">Nine people, three of them admins.</TabPanel>
        <TabPanel value="tokens">Two tokens, one expiring in eleven days.</TabPanel>
        <TabPanel value="webhooks">No webhooks yet.</TabPanel>
      </Tabs>

      <Card size="sm" title="Inside a card" subtitle="variant='text' and fullWidth">
        <Tabs variant="text" fullWidth defaultValue="a" size="sm">
          <Tab value="a">Daily</Tab>
          <Tab value="b">Weekly</Tab>
          <Tab value="c">Monthly</Tab>
          <TabPanel value="a">A card already has an edge, so the bar gives up its own.</TabPanel>
          <TabPanel value="b">The tabs share the width equally.</TabPanel>
          <TabPanel value="c">Nothing here draws a second rectangle.</TabPanel>
        </Tabs>
      </Card>
    </div>
  );
}
