import { Badge, Tab, TabPanel, Tabs } from 'neba';

function InboxIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M2 9.5h3l1 2h4l1-2h3M2.5 9.5 4 3.5h8l1.5 6v2a1.5 1.5 0 0 1-1.5 1.5h-8A1.5 1.5 0 0 1 2.5 11.5v-2Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function StarIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m8 2.5 1.7 3.5 3.8.5-2.8 2.7.7 3.8L8 11.2 4.6 13l.7-3.8L2.5 6.5l3.8-.5L8 2.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function TabsIcons() {
  return (
    <Tabs variant="solid" defaultValue="inbox" className="w-full max-w-lg">
      <Tab value="inbox" startIcon={<InboxIcon />} endIcon={<Badge content={12} size="xs" />}>
        Inbox
      </Tab>
      <Tab value="starred" startIcon={<StarIcon />}>
        Starred
      </Tab>
      <Tab value="sent">Sent</Tab>

      <TabPanel value="inbox">Twelve unread, four of them from this morning.</TabPanel>
      <TabPanel value="starred">Nothing starred yet.</TabPanel>
      <TabPanel value="sent">Eight sent this week.</TabPanel>
    </Tabs>
  );
}
