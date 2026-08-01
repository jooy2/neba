import { TextLink } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function TextLinkColors() {
  return (
    <div className="flex flex-col gap-4">
      <p className="m-0 text-[0.8125rem]/[1.375rem]">
        With no <code>color</code> a link is{' '}
        <TextLink href="/components/">the colour of the sentence</TextLink> it sits in.
      </p>

      <div className="flex flex-wrap items-center gap-5">
        {COLORS.map((color) => (
          <TextLink key={color} href="/components/" color={color}>
            {color}
          </TextLink>
        ))}
      </div>
    </div>
  );
}
