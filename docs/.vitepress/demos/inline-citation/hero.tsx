import { InlineCitation, Sources } from 'neba';

const ITEMS = [
  {
    title: 'The design language',
    site: 'neba.cdget.com',
    href: 'https://neba.cdget.com/design/design-language',
    description: 'A Neba surface is a sheet of cut acrylic, not a moulded plastic key.'
  },
  {
    title: 'Breakpoints',
    site: 'neba.cdget.com',
    href: 'https://neba.cdget.com/design/breakpoints',
    description: 'Every entry in a per-breakpoint map is a floor, not a range.'
  }
];

export default function InlineCitationHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <p className="m-0 text-[0.9375rem]/[1.6]">
        A control never moves under the pointer, because scaling it would resample its label
        <InlineCitation
          index={1}
          title={ITEMS[0].title}
          site={ITEMS[0].site}
          href={ITEMS[0].href}
          description={ITEMS[0].description}
        />{' '}
        — and a value that changes at a breakpoint applies from that width up rather than only at it
        <InlineCitation
          index={2}
          title={ITEMS[1].title}
          site={ITEMS[1].site}
          href={ITEMS[1].href}
          description={ITEMS[1].description}
        />
        .
      </p>
      <Sources items={ITEMS} />
    </div>
  );
}
