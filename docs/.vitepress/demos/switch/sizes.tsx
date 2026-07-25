import { Switch } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function SwitchSizes() {
  return (
    <div className="flex flex-col gap-3">
      {SIZES.map((size) => (
        <Switch key={size} size={size} label={size} defaultChecked />
      ))}
    </div>
  );
}
