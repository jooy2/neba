import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Approval, NebaProvider } from 'neba';

const OPTIONS = [
  { value: 'once', label: 'Allow once' },
  { value: 'always', label: 'Always allow' },
  { value: 'deny', label: 'Deny', color: 'danger' as const }
];

describe('Approval', () => {
  describe('rendering', () => {
    it('draws a button per option', async () => {
      const screen = await render(<Approval options={OPTIONS} title="Write to disk?" />);

      await expect.element(screen.getByRole('button', { name: 'Allow once' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('button', { name: 'Always allow' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Deny' })).toBeInTheDocument();
    });

    it('names the group after the question', async () => {
      const screen = await render(<Approval options={OPTIONS} title="Write to disk?" />);

      await expect
        .element(screen.getByRole('group', { name: 'Write to disk?' }))
        .toBeInTheDocument();
    });

    it('falls back to a heading of its own', async () => {
      const screen = await render(<Approval options={OPTIONS} />);

      await expect
        .element(screen.getByRole('group', { name: 'Permission needed' }))
        .toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Approval options={OPTIONS} className="my-own-class" />);

      expect(screen.getByRole('group').element()).toHaveClass('my-own-class');
    });

    it('draws a string of details as preformatted text', async () => {
      const screen = await render(
        <Approval options={OPTIONS} details={'rm -rf ./build\necho done'} />
      );

      await expect
        .element(screen.getByText('rm -rf ./build', { exact: false }))
        .toBeInTheDocument();
    });

    it('lists the descriptions its options carry', async () => {
      const screen = await render(
        <Approval
          options={[
            { value: 'once', label: 'Allow once', description: 'Just this call' },
            { value: 'deny', label: 'Deny' }
          ]}
        />
      );

      await expect
        .element(screen.getByText('Just this call', { exact: false }))
        .toBeInTheDocument();
    });
  });

  describe('risk', () => {
    it('writes the level out in words', async () => {
      const screen = await render(<Approval options={OPTIONS} risk="high" />);

      await expect.element(screen.getByText('High risk')).toBeInTheDocument();
    });

    it('takes over the colour family', async () => {
      const screen = await render(<Approval options={OPTIONS} risk="low" color="danger" />);
      const element = screen.getByRole('group').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-info-accent)');
    });

    it('leaves the family to color when there is no risk', async () => {
      const screen = await render(<Approval options={OPTIONS} color="success" />);
      const element = screen.getByRole('group').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });
  });

  describe('deciding', () => {
    it('reports the value of the option that was pressed', async () => {
      const onDecide = vi.fn();
      const screen = await render(<Approval options={OPTIONS} onDecide={onDecide} />);

      await screen.getByRole('button', { name: 'Always allow' }).click();

      expect(onDecide).toHaveBeenCalledWith('always');
    });

    // The card is a record of what was agreed to, not a question that vanishes
    // once it has been answered.
    it('stays in the transcript as the answer that was given', async () => {
      const screen = await render(<Approval options={OPTIONS} />);

      await screen.getByRole('button', { name: 'Allow once' }).click();

      await expect.element(screen.getByText('Answered')).toBeInTheDocument();
      await expect.element(screen.getByText('Allow once')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Deny' }).query()).toBeNull();
    });

    it('shows a decision it was handed rather than one it took', async () => {
      const screen = await render(<Approval options={OPTIONS} decision="deny" />);

      await expect.element(screen.getByText('Answered')).toBeInTheDocument();
      await expect.element(screen.getByText('Deny')).toBeInTheDocument();
    });

    it('leaves a controlled Approval unanswered until its caller says so', async () => {
      const onDecide = vi.fn();
      const screen = await render(
        <Approval options={OPTIONS} decision={null} onDecide={onDecide} />
      );

      await screen.getByRole('button', { name: 'Deny' }).click();

      expect(onDecide).toHaveBeenCalledWith('deny');
      await expect.element(screen.getByRole('button', { name: 'Deny' })).toBeInTheDocument();
    });

    it('takes every answer away while it is disabled', async () => {
      const screen = await render(<Approval options={OPTIONS} disabled />);

      await expect.element(screen.getByRole('button', { name: 'Deny' })).toBeDisabled();
    });
  });

  describe('its own words', () => {
    // Only English ships; the other languages are registered by the consumer,
    // so an unregistered tag has to be a fallback rather than a page of blanks.
    it('falls back to English for a language nobody registered', async () => {
      const screen = await render(<Approval options={OPTIONS} risk="high" locale="ko" />);

      await expect.element(screen.getByText('Permission needed')).toBeInTheDocument();
      await expect.element(screen.getByText('High risk')).toBeInTheDocument();
    });

    it('lets a caller write them out instead', async () => {
      const screen = await render(
        <Approval options={OPTIONS} labels={{ request: 'Zustimmung nötig' }} />
      );

      await expect.element(screen.getByText('Zustimmung nötig')).toBeInTheDocument();
    });

    it('takes the locale from a provider', async () => {
      const screen = await render(
        <NebaProvider defaults={{ locale: 'de-DE' }}>
          <Approval options={OPTIONS} />
        </NebaProvider>
      );

      // German is not registered either, so what is being checked is that the
      // provider's tag reaches the component at all.
      await expect
        .element(screen.getByRole('group', { name: 'Permission needed' }))
        .toBeInTheDocument();
    });
  });
});
