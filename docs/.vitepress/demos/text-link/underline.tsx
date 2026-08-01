import { TextLink } from 'neba';

export default function TextLinkUnderline() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <TextLink href="/components/">always</TextLink>
      <TextLink href="/components/" underline="hover">
        hover
      </TextLink>
      <TextLink href="/components/" underline="none" color="primary">
        none
      </TextLink>
    </div>
  );
}
