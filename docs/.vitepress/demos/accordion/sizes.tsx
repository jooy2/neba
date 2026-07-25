import { Accordion, AccordionItem } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function AccordionSizes() {
  return (
    <div className="flex w-full flex-col gap-4">
      {SIZES.map((size) => (
        <Accordion key={size} size={size} defaultValue={['a']}>
          <AccordionItem value="a" title={size} subtitle="Radius and padding, never the ladder">
            A section's size is the sheet's size — its radius and its padding — exactly as on Box.
          </AccordionItem>
        </Accordion>
      ))}
    </div>
  );
}
