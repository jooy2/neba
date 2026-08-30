import { Toggle } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function ToggleSizes() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {sizes.map((size) => (
        <Toggle key={size} size={size} defaultPressed>
          {size}
        </Toggle>
      ))}
    </div>
  );
}
