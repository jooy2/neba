import { Card, Tab, TabPanel, Tabs } from 'neba';

export default function TabsAlign() {
  return (
    <div className="grid w-full grid-cols-1 gap-5 lg:grid-cols-2">
      <Card size="sm" title="A column of settings" subtitle="align='start'">
        <Tabs orientation="vertical" align="start" defaultValue="general" size="sm">
          <Tab value="general">General</Tab>
          <Tab value="members">Members and roles</Tab>
          <Tab value="tokens">Tokens</Tab>
          <Tab value="webhooks">Webhooks</Tab>

          <TabPanel value="general">Every label starts on the same edge.</TabPanel>
          <TabPanel value="members">The tabs are still as wide as the longest one.</TabPanel>
          <TabPanel value="tokens">Only the label moved.</TabPanel>
          <TabPanel value="webhooks">The indicator is where it always was.</TabPanel>
        </Tabs>
      </Card>

      <Card size="sm" title="A bar of equal shares" subtitle="fullWidth with align='start'">
        <Tabs variant="text" fullWidth align="start" defaultValue="a" size="sm">
          <Tab value="a">Daily</Tab>
          <Tab value="b">Weekly</Tab>
          <Tab value="c">Monthly</Tab>
          <TabPanel value="a">Each tab takes an equal share of the bar.</TabPanel>
          <TabPanel value="b">The labels sit at the start of their own share.</TabPanel>
          <TabPanel value="c">Without fullWidth there would be nothing to align.</TabPanel>
        </Tabs>
      </Card>
    </div>
  );
}
