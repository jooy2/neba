import { Blockquote } from 'neba';

export default function BlockquoteVariants() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-5">
      <Blockquote variant="text">
        The rule in the margin and nothing else, which is what a quote in running prose should be.
      </Blockquote>

      <Blockquote variant="outline">
        A hairline sheet under the words, for a quote that has to be found on a busy page.
      </Blockquote>

      <Blockquote variant="solid">
        The frosted sheet, for a pull quote that is the point of the section rather than an aside
        inside it.
      </Blockquote>
    </div>
  );
}
