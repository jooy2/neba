import { Slider } from 'neba';

const CHANNELS = [
  { label: 'Low', value: 70, color: 'primary' as const },
  { label: 'Mid', value: 45, color: 'info' as const },
  { label: 'High', value: 30, color: 'success' as const }
];

export default function SliderVertical() {
  return (
    <div className="flex items-end gap-8">
      {CHANNELS.map((channel) => (
        <div key={channel.label} className="flex flex-col items-center gap-2">
          <Slider
            orientation="vertical"
            color={channel.color}
            aria-label={channel.label}
            defaultValue={channel.value}
          />
          <span className="text-[0.75rem] text-[var(--neba-muted-fg)]">{channel.label}</span>
        </div>
      ))}
    </div>
  );
}
