import { Sources } from 'neba';

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
    description: 'Every entry in a per-breakpoint map is a floor.'
  },
  {
    title: 'Prop conventions',
    site: 'neba.cdget.com',
    href: 'https://neba.cdget.com/design/prop-conventions'
  }
];

export default function SourcesHero() {
  return (
    <div className="w-full max-w-lg">
      <Sources items={ITEMS} defaultOpen />
    </div>
  );
}
