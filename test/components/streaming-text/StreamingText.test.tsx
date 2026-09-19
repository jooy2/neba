import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { StreamingText } from 'neba';

describe('StreamingText', () => {
  describe('rendering', () => {
    it('draws the text it has so far', async () => {
      const screen = await render(<StreamingText>A sheet of cut acrylic.</StreamingText>);

      await expect
        .element(screen.getByText('A sheet of cut acrylic.', { exact: false }))
        .toBeInTheDocument();
    });

    it('keeps the whole string, whitespace and all', async () => {
      const screen = await render(<StreamingText>{'One\ntwo  three'}</StreamingText>);

      expect(screen.getByText('One', { exact: false }).first().element().textContent).toBeTruthy();
      expect(document.body.textContent).toContain('One\ntwo  three');
    });

    it('renders something that is not a string untouched', async () => {
      const screen = await render(
        <StreamingText>
          <em>Already an element</em>
        </StreamingText>
      );

      await expect.element(screen.getByText('Already an element')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      await render(<StreamingText className="my-own-class">Hello</StreamingText>);

      expect(document.querySelector('.my-own-class')).not.toBeNull();
    });

    it('renders something other than a div when it is asked to', async () => {
      await render(<StreamingText render={<p />}>Hello</StreamingText>);

      expect(document.querySelector('p')).not.toBeNull();
    });
  });

  describe('the words', () => {
    it('gives every word an element of its own to arrive in', async () => {
      await render(<StreamingText>A sheet of cut acrylic</StreamingText>);

      expect(document.querySelectorAll('.neba-stream-word')).toHaveLength(5);
    });

    // Words are keyed by position, so one already on screen keeps its element
    // as the text grows and never fades a second time.
    it('keeps the element a word already had when the text grows', async () => {
      const screen = await render(<StreamingText>A sheet</StreamingText>);
      const first = document.querySelector('.neba-stream-word');

      await screen.rerender(<StreamingText>A sheet of cut acrylic</StreamingText>);

      expect(document.querySelector('.neba-stream-word')).toBe(first);
      expect(document.querySelectorAll('.neba-stream-word')).toHaveLength(5);
    });

    it('leaves the text in one piece when the fade is off', async () => {
      await render(<StreamingText fade={false}>A sheet of cut acrylic</StreamingText>);

      expect(document.querySelectorAll('.neba-stream-word')).toHaveLength(0);
      expect(document.body.textContent).toContain('A sheet of cut acrylic');
    });
  });

  describe('the caret', () => {
    it('draws one while the stream runs', async () => {
      await render(<StreamingText streaming>A sheet</StreamingText>);

      expect(document.querySelector('.neba-stream-caret')).not.toBeNull();
    });

    it('takes it away when the stream stops', async () => {
      const screen = await render(<StreamingText streaming>A sheet</StreamingText>);

      await screen.rerender(<StreamingText>A sheet</StreamingText>);

      expect(document.querySelector('.neba-stream-caret')).toBeNull();
    });

    it('draws a caret of its own when it is handed one', async () => {
      const screen = await render(
        <StreamingText streaming cursor={<span>typing…</span>}>
          A sheet
        </StreamingText>
      );

      await expect.element(screen.getByText('typing…')).toBeInTheDocument();
      expect(document.querySelector('.neba-stream-caret')).toBeNull();
    });

    it('draws none at all when it is turned off', async () => {
      await render(
        <StreamingText streaming cursor={false}>
          A sheet
        </StreamingText>
      );

      expect(document.querySelector('.neba-stream-caret')).toBeNull();
    });

    it('marks itself busy while the stream runs', async () => {
      await render(<StreamingText streaming>A sheet</StreamingText>);

      expect(document.querySelector('[data-streaming][aria-busy="true"]')).not.toBeNull();
    });
  });

  describe('reserving the height', () => {
    it('holds one line before anything has arrived', async () => {
      await render(<StreamingText streaming />);
      const element = document.querySelector('[data-streaming]') as HTMLElement;

      expect(element.style.getPropertyValue('--n-reserve')).toBe('calc(1 * 1lh)');
    });

    it('holds as many as it was asked for', async () => {
      await render(<StreamingText lines={3} />);
      const element = document.querySelector('.min-h-\\(--n-reserve\\)') as HTMLElement;

      expect(element.style.getPropertyValue('--n-reserve')).toBe('calc(3 * 1lh)');
    });
  });
});
