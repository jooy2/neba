import { Reasoning } from 'neba';

export default function ReasoningVariant() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['text', 'outline', 'solid'] as const).map((variant) => (
        <Reasoning key={variant} variant={variant} duration={2400} defaultOpen>
          Drawn as {variant}. The rule down the inside edge is the panel, whichever weight the
          header is on.
        </Reasoning>
      ))}
    </div>
  );
}
