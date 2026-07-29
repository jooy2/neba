import { Blockquote } from 'neba';

const families = ['primary', 'success', 'warning', 'danger'] as const;

export default function BlockquoteColors() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {families.map((color) => (
        <Blockquote key={color} color={color} variant="outline" size="sm" icon={false}>
          The sheet stays undyed whatever the family is — the colour is in the rule and the mark.
        </Blockquote>
      ))}
    </div>
  );
}
