import { Divider } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function DividerColors() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      {COLORS.map((color) => (
        <Divider key={color} color={color}>
          {color}
        </Divider>
      ))}
    </div>
  );
}
