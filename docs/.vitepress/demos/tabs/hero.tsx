import { Tab, TabPanel, Tabs } from 'neba';

export default function TabsHero() {
  return (
    <Tabs defaultValue="overview" className="w-full max-w-xl">
      <Tab value="overview">Overview</Tab>
      <Tab value="usage">Usage</Tab>
      <Tab value="billing">Billing</Tab>
      <Tab value="archived" disabled>
        Archived
      </Tab>

      <TabPanel value="overview">
        Three deploys today, all green. The last one finished four minutes ago.
      </TabPanel>
      <TabPanel value="usage">1,284 build minutes of the 4,000 on this plan.</TabPanel>
      <TabPanel value="billing">Next invoice on the first, for $84.</TabPanel>
    </Tabs>
  );
}
