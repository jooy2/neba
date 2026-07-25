import { Accordion, AccordionItem, Switch, Typography } from 'neba';

/**
 * `multiple` is the whole difference between an accordion and a stack of
 * collapsibles: closing the last section as you open the next is what keeps the
 * page from growing under the reader.
 *
 * `dividers` decides whether the sections are one ruled block or a stack of
 * tiles. A section cannot be both.
 */
export default function AccordionBehaviour() {
  return (
    <div className="grid w-full grid-cols-1 gap-5 lg:grid-cols-2">
      <div className="flex flex-col gap-2">
        <Typography level="caption">multiple</Typography>
        <Accordion multiple defaultValue={['a', 'b']} size="sm">
          <AccordionItem value="a" title="Both open at once">
            Nothing closed when this one opened.
          </AccordionItem>
          <AccordionItem value="b" title="And so is this">
            Reach for it when the sections are a checklist rather than a set of answers.
          </AccordionItem>
        </Accordion>
      </div>

      <div className="flex flex-col gap-2">
        <Typography level="caption">dividers={'{false}'} · action · disabled</Typography>
        <Accordion dividers={false} size="sm" defaultValue={['a']}>
          <AccordionItem
            value="a"
            title="Notifications"
            subtitle="Tiles rather than rules"
            action={<Switch size="sm" defaultChecked />}
          >
            The switch sits outside the folding button — a header that both folds and holds a
            control has two things to press, and one of them cannot be nested inside the other.
          </AccordionItem>
          <AccordionItem value="b" title="Archived" disabled>
            This one never opens.
          </AccordionItem>
        </Accordion>
      </div>
    </div>
  );
}
