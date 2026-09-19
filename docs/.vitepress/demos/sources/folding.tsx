import { Sources } from 'neba';

const ITEMS = [
  { title: 'The design language', href: 'https://neba.cdget.com/design/design-language' },
  { title: 'Breakpoints', href: 'https://neba.cdget.com/design/breakpoints' },
  { title: 'Prop conventions', href: 'https://neba.cdget.com/design/prop-conventions' },
  { title: 'Browser support', href: 'https://neba.cdget.com/browser-support' }
];

export default function SourcesFolding() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Sources items={ITEMS} />
      <Sources items={ITEMS} collapsible={false} title="Always open" variant="outline" />
    </div>
  );
}
