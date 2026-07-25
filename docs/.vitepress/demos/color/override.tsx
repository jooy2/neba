import { useEffect, useState, type CSSProperties } from 'react';
import { Button, Card, TextField } from 'neba';

/**
 * A violet `primary`, scoped to one subtree instead of the whole app.
 *
 * Only the five hand-set tokens are given per theme. Everything else — the
 * translucent fill, the panel, the hairline, the focus ring — is `color-mix()`ed
 * off these in the derived block, so re-declaring the five re-skins the family.
 *
 * The wrapper carries `data-theme` for a reason that is easy to miss: the
 * derived block is declared on the theme roots, and a custom property resolves
 * its `var()`s on the element that declares it. On a plain `<div>` the five new
 * values would be inherited but `--neba-primary-fill` would still be the one
 * `:root` computed from the *old* `solid` — so the buttons would not change.
 * Marking the wrapper as a theme root is what makes the derived block recompute
 * here. An app-wide override on `:root` / `.dark` needs none of this.
 */
const violetLight = {
  '--neba-primary-solid': 'oklch(50% 0.24 300)',
  '--neba-primary-solid-hover': 'oklch(45.5% 0.232 300)',
  '--neba-primary-solid-active': 'oklch(38% 0.204 300)',
  '--neba-primary-on-solid': 'oklch(99% 0.004 300)',
  '--neba-primary-accent': 'oklch(54% 0.26 300)'
} as CSSProperties;

const violetDark = {
  '--neba-primary-solid': 'oklch(57% 0.253 300)',
  '--neba-primary-solid-hover': 'oklch(62% 0.22 300)',
  '--neba-primary-solid-active': 'oklch(48% 0.231 300)',
  '--neba-primary-on-solid': 'oklch(99% 0.004 300)',
  '--neba-primary-accent': 'oklch(78% 0.119 300)'
} as CSSProperties;

/** Follows the theme VitePress puts on `<html>`, so the subtree never fights it. */
function useIsDark() {
  const [dark, setDark] = useState(false);

  useEffect(() => {
    const read = () => setDark(document.documentElement.classList.contains('dark'));

    read();

    const observer = new MutationObserver(read);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });

    return () => observer.disconnect();
  }, []);

  return dark;
}

function Panel({ label }: { label: string }) {
  return (
    <Card title={label} subtitle="Same markup on both sides">
      <TextField label="Slug" defaultValue="release-notes" />
      <div className="mt-3 flex flex-wrap gap-2">
        <Button>Publish</Button>
        <Button variant="outline">Preview</Button>
        <Button variant="text">Cancel</Button>
      </div>
    </Card>
  );
}

export default function ColorOverride() {
  const dark = useIsDark();

  return (
    <div className="grid w-full max-w-3xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Panel label="Default" />
      <div data-theme={dark ? 'dark' : 'light'} style={dark ? violetDark : violetLight}>
        <Panel label="Violet" />
      </div>
    </div>
  );
}
