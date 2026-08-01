import { TextLink } from 'neba';

export default function TextLinkHero() {
  return (
    <div className="flex max-w-lg flex-col gap-4 text-[0.8125rem]/[1.375rem]">
      <p className="m-0">
        Every component is documented on its own page, and the{' '}
        <TextLink href="/components/">component index</TextLink> lists them all with a live preview
        in each card. The design language behind them is written up{' '}
        <TextLink href="/design/design-language" color="primary">
          here
        </TextLink>
        .
      </p>

      <div className="flex flex-wrap items-center gap-5">
        <TextLink href="https://neba.cdget.com/components/" newTab>
          All components
        </TextLink>
        <TextLink href="/guide/getting-started" underline="hover" color="info">
          Getting started
        </TextLink>
        <TextLink href="/components/inputs/button" underline="none" icon color="secondary">
          Button
        </TextLink>
      </div>
    </div>
  );
}
