import { Accordion, AccordionItem } from 'neba';

export default function AccordionVariants() {
  return (
    <div className="grid w-full grid-cols-1 gap-4 lg:grid-cols-3">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <Accordion key={variant} variant={variant} size="sm" defaultValue={['a']}>
          <AccordionItem value="a" title={variant}>
            The sheet is never dyed — a container holds other people's content, and that content
            arrives with its own colours.
          </AccordionItem>
          <AccordionItem value="b" title="Second">
            Only one section is open at a time unless `multiple` says otherwise.
          </AccordionItem>
        </Accordion>
      ))}
    </div>
  );
}
