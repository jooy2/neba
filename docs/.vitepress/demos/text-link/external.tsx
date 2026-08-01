import { TextLink } from 'neba';

function DownloadIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none">
      <path
        d="M8 2.75v7m0 0L5.25 7M8 9.75 10.75 7M3 12.5h10"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export default function TextLinkExternal() {
  return (
    <div className="flex flex-wrap items-center gap-6">
      <TextLink href="https://neba.cdget.com/components/" newTab>
        New tab
      </TextLink>
      <TextLink href="https://neba.cdget.com/components/" newTab icon={false}>
        No mark
      </TextLink>
      <TextLink href="/components/" icon>
        Same tab, marked
      </TextLink>
      <TextLink href="/neba.zip" icon={<DownloadIcon />} color="secondary">
        A glyph of its own
      </TextLink>
    </div>
  );
}
