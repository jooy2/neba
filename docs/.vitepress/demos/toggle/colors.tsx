import { Toggle } from 'neba';

const colors = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function ToggleColors() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {colors.map((color) => (
        <Toggle key={color} color={color} defaultPressed>
          {color}
        </Toggle>
      ))}
    </div>
  );
}
