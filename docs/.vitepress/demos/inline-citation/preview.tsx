import { InlineCitation } from 'neba';

export default function InlineCitationPreview() {
  return (
    <p className="m-0 w-full max-w-lg text-[0.9375rem]/[1.6]">
      With a preview
      <InlineCitation
        index={1}
        title="The design language"
        site="neba.cdget.com"
        href="https://neba.cdget.com/design/design-language"
        description="Rest the pointer here and the source comes up."
      />
      , without one
      <InlineCitation index={2} href="https://neba.cdget.com/design/breakpoints" preview={false} />
      , and with nothing to point at at all
      <InlineCitation index={3} />.
    </p>
  );
}
