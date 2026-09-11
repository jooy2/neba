import { Slider } from 'neba';

const SIZES = [
  { value: 1, label: '1' },
  { value: 100, label: '100' },
  { value: 250, label: '250' },
  { value: 500, label: '500' }
];

const STYLES = [
  { value: 0, label: 'Realistic' },
  { value: 100, label: 'Abstract' }
];

export default function SliderMarks() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-8">
      <Slider label="Batch size" min={1} max={500} defaultValue={100} marks={SIZES} showValue />

      <Slider label="Style" defaultValue={50} marks={STYLES} />

      {/* `marks` on its own is a tick at every step, which is worth pairing
          with a step you chose. */}
      <Slider label="Strength" step={20} defaultValue={40} marks showValue />
    </div>
  );
}
