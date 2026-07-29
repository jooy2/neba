import { Highlight } from 'neba';

const sentence = 'A sheet of cut acrylic, not a moulded plastic key.';

export default function HighlightVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3 text-[0.8125rem]/[1.6]">
      <Highlight query="acrylic">{sentence}</Highlight>
      <Highlight query="acrylic" variant="outline" color="primary">
        {sentence}
      </Highlight>
      <Highlight query="acrylic" variant="text" color="danger">
        {sentence}
      </Highlight>
      <Highlight query="acrylic" variant="text" color="primary" underline>
        {sentence}
      </Highlight>
      <Highlight query="acrylic" variant="text" color="success" weight="bold">
        {sentence}
      </Highlight>
    </div>
  );
}
