import { Tab, TabPanel, Tabs, Typography } from 'neba';

const SECTIONS = [
  'Overview',
  'Activity',
  'Members',
  'Settings',
  'Billing',
  'Integrations',
  'Audit log',
  'Webhooks',
  'API keys'
];

function Bar(props: { overflow?: 'scroll' | 'wrap'; lines?: number }) {
  return (
    <Tabs defaultValue="Overview" {...props}>
      {SECTIONS.map((section) => (
        <Tab key={section} value={section}>
          {section}
        </Tab>
      ))}
      <TabPanel value="Overview">Nine sections in a box too narrow for them.</TabPanel>
    </Tabs>
  );
}

export default function TabsOverflow() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          overflow=&quot;scroll&quot; — the default
        </Typography>
        <Bar />
      </div>

      <div>
        <Typography level="caption" color="secondary">
          overflow=&quot;wrap&quot;
        </Typography>
        <Bar overflow="wrap" />
      </div>

      <div>
        <Typography level="caption" color="secondary">
          overflow=&quot;wrap&quot; · lines=2
        </Typography>
        <Bar overflow="wrap" lines={2} />
      </div>
    </div>
  );
}
