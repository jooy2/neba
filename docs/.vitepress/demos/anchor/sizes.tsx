import { Anchor } from 'neba';

const ITEMS = [
  { href: '#size-a', label: 'Overview' },
  { href: '#size-b', label: 'Installation' },
  { href: '#size-c', label: 'Deployment' }
];

const sizes = ['xs', 'sm', 'md', 'lg'] as const;

export default function AnchorSizes() {
  return (
    <div className="flex items-start gap-8">
      {sizes.map((size) => (
        <Anchor key={size} size={size} items={ITEMS} activeHref="#size-b" label={size} />
      ))}
    </div>
  );
}
