import { Tab, TabPanel, Tabs } from 'neba';

/**
 * `variant` here is the weight of the *bar*, not of the panels under it:
 * `solid` is a segmented control with a tile that slides between the tabs,
 * `outline` is the classic rule with the indicator riding on it, and `text` is
 * the same bar with the rule taken away — for tabs inside a Card that already
 * has an edge of its own.
 */
export default function TabsVariants() {
  return (
    <div className="flex w-full flex-col gap-6">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <Tabs key={variant} variant={variant} defaultValue="a" size="sm">
          <Tab value="a">Overview</Tab>
          <Tab value="b">Usage</Tab>
          <Tab value="c">Billing</Tab>
          <TabPanel value="a">variant="{variant}"</TabPanel>
          <TabPanel value="b">
            The indicator moves by animating its box, never by transforming it.
          </TabPanel>
          <TabPanel value="c">Nothing with text in it moves.</TabPanel>
        </Tabs>
      ))}
    </div>
  );
}
