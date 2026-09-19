import { Sources } from 'neba';

const ITEMS = [
  {
    title: 'The design language',
    site: 'neba.cdget.com',
    href: 'https://neba.cdget.com/design/design-language'
  },
  {
    title: 'Breakpoints',
    site: 'neba.cdget.com',
    href: 'https://neba.cdget.com/design/breakpoints'
  }
];

export default function SourcesVariant() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['text', 'outline', 'solid'] as const).map((variant) => (
        <Sources key={variant} variant={variant} title={variant} items={ITEMS} defaultOpen />
      ))}
    </div>
  );
}
