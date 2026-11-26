/**
 * The note a link that opens somewhere other than this tab ends with.
 *
 * Six components put it last inside their `<a>`, so its shape is asserted once
 * here. The part worth pinning is where the space before it lives: inside the
 * hidden span. As a text node of the link's own it is laid out at the end of
 * any link that is not a flex container, and the next word of the sentence
 * stands a space away from the link.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { ko, registerMessages } from 'neba/locales';
import { NewTabNote } from '../../src/internal/new-tab.js';

registerMessages('ko', ko);

describe('NewTabNote', () => {
  it('says nothing for a target that stays in the tab', async () => {
    const screen = await render(
      <>
        <a href="#">
          Docs
          <NewTabNote target={undefined} />
        </a>
        <a href="#">
          Guide
          <NewTabNote target="_self" />
        </a>
      </>
    );

    await expect.element(screen.getByRole('link', { name: 'Docs' })).toBeInTheDocument();
    await expect.element(screen.getByRole('link', { name: 'Guide' })).toBeInTheDocument();
  });

  it('leaves no space of its own in the link', async () => {
    const screen = await render(
      <a href="#" data-testid="link">
        Docs
        <NewTabNote target="_blank" />
      </a>
    );
    const loose = Array.from(screen.getByTestId('link').element().childNodes).filter(
      (node) => node.nodeType === Node.TEXT_NODE && node.textContent?.trim() === ''
    );

    expect(loose).toHaveLength(0);
  });

  it('keeps the label and the note two words apart', async () => {
    const screen = await render(
      <>
        <a href="#">
          Docs
          <NewTabNote target="_blank" />
        </a>
        <a href="#">
          문서
          <NewTabNote target="_blank" locale="ko" />
        </a>
      </>
    );

    await expect
      .element(screen.getByRole('link', { name: 'Docs (opens in a new tab)' }))
      .toBeInTheDocument();
    await expect
      .element(screen.getByRole('link', { name: '문서 (새 창에서 열림)' }))
      .toBeInTheDocument();
  });
});
