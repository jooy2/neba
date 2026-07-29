import { Blockquote } from 'neba';

export default function BlockquoteAttribution() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-6">
      {/* Nothing at all: a plain `<blockquote>`. */}
      <Blockquote variant="outline">Make it work, make it right, make it fast.</Blockquote>

      {/* A person. */}
      <Blockquote variant="outline" author="Kent Beck">
        Make it work, make it right, make it fast.
      </Blockquote>

      {/* A person and the work it came from, with a machine-readable URL. */}
      <Blockquote
        variant="outline"
        author="Kent Beck"
        source="Extreme Programming Explained"
        cite="https://example.com/xp"
      >
        Make it work, make it right, make it fast.
      </Blockquote>
    </div>
  );
}
