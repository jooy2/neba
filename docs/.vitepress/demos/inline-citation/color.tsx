import { InlineCitation, type NebaColor } from 'neba';

const COLORS: NebaColor[] = ['primary', 'secondary', 'success', 'info'];

export default function InlineCitationColor() {
  return (
    <p className="m-0 w-full max-w-lg text-[0.9375rem]/[1.6]">
      The mark is sized in <code>em</code>, so it tracks whatever sentence it interrupts
      {COLORS.map((color, at) => (
        <InlineCitation key={color} index={at + 1} color={color} title={color} />
      ))}
      .
    </p>
  );
}
