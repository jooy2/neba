import { TextLink } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function TextLinkSizes() {
  return (
    <div className="flex flex-wrap items-baseline gap-5">
      {SIZES.map((size) => (
        <TextLink key={size} href="/components/" size={size} color="primary">
          {size}
        </TextLink>
      ))}
    </div>
  );
}
