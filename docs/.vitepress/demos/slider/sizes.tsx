import { Slider } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function SliderSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-6">
      {SIZES.map((size) => (
        <Slider key={size} size={size} label={size} defaultValue={50} />
      ))}
    </div>
  );
}
