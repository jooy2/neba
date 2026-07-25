import { Accordion, AccordionItem } from 'neba';

export default function AccordionHero() {
  return (
    <Accordion defaultValue={['billing']} className="w-full max-w-lg">
      <AccordionItem value="billing" title="How does billing work?" subtitle="Plans and invoices">
        You are charged on the first of each month for the seats you had on the last day of the
        previous one. Adding a seat mid-month is prorated; removing one is credited.
      </AccordionItem>
      <AccordionItem value="regions" title="Where do builds run?" subtitle="Four regions">
        Builds run in the region closest to the repository's default branch, and can be pinned to a
        single region per project.
      </AccordionItem>
      <AccordionItem value="limits" title="What are the limits?" subtitle="Per plan">
        The free plan allows 400 build minutes a month. Paid plans are metered rather than capped.
      </AccordionItem>
    </Accordion>
  );
}
