import { Anchor } from 'neba';

const ITEMS = [
  { href: '#anchor-a', label: 'Overview' },
  { href: '#anchor-b', label: 'Installation' },
  { href: '#anchor-c', label: 'Configuration', depth: 1 },
  { href: '#anchor-d', label: 'Deployment' }
];

export default function AnchorRail() {
  return (
    <div className="flex items-start gap-10">
      <Anchor size="sm" items={ITEMS} activeHref="#anchor-b" label="With rail" />
      <Anchor size="sm" rail={false} items={ITEMS} activeHref="#anchor-b" label="Without rail" />
    </div>
  );
}
