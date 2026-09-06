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
  'API keys',
  'Domains'
];

function Bar(props: { wheel?: boolean }) {
  return (
    <Tabs defaultValue="Overview" {...props}>
      {SECTIONS.map((section) => (
        <Tab key={section} value={section}>
          {section}
        </Tab>
      ))}
      <TabPanel value="Overview">Ten sections in a box too narrow for them.</TabPanel>
    </Tabs>
  );
}

export default function TabsWheel() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <div>
        <Typography level="caption" color="secondary">
          Roll over the bar; the page waits until the pointer leaves
        </Typography>
        <Bar />
      </div>

      <div>
        <Typography level="caption" color="secondary">
          wheel={'{false}'} — the wheel is the page&apos;s
        </Typography>
        <Bar wheel={false} />
      </div>
    </div>
  );
}
