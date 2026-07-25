import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Accordion, AccordionItem, Button } from 'neba';

describe('Accordion', () => {
  describe('rendering', () => {
    it('renders a button per section', async () => {
      const screen = await render(
        <Accordion>
          <AccordionItem title="Billing">How we charge.</AccordionItem>
          <AccordionItem title="Regions">Where we run.</AccordionItem>
        </Accordion>
      );

      expect(screen.getByRole('button').elements()).toHaveLength(2);
      await expect.element(screen.getByRole('button', { name: 'Billing' })).toBeInTheDocument();
    });

    it('renders a subtitle under the title', async () => {
      const screen = await render(
        <Accordion>
          <AccordionItem title="Billing" subtitle="Invoices and cards" />
        </Accordion>
      );

      await expect.element(screen.getByText('Invoices and cards')).toBeInTheDocument();
    });

    it('shows the section that starts open', async () => {
      const screen = await render(
        <Accordion defaultValue={['billing']}>
          <AccordionItem value="billing" title="Billing">
            How we charge.
          </AccordionItem>
          <AccordionItem value="regions" title="Regions">
            Where we run.
          </AccordionItem>
        </Accordion>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'true');
      await expect.element(screen.getByText('How we charge.')).toBeInTheDocument();
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(
        <Accordion>
          <AccordionItem title="Before" />
        </Accordion>
      );

      await screen.rerender(
        <Accordion>
          <AccordionItem title="After" />
        </Accordion>
      );

      await expect.element(screen.getByRole('button', { name: 'After' })).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <Accordion className="my-own-class">
          <AccordionItem title="Billing" className="my-section-class" />
        </Accordion>
      );

      expect(screen.container.querySelector('.my-own-class')).not.toBeNull();
      expect(screen.container.querySelector('.my-section-class')).not.toBeNull();
    });
  });

  describe('folding', () => {
    it('opens a section when its header is pressed', async () => {
      const screen = await render(
        <Accordion>
          <AccordionItem value="billing" title="Billing">
            How we charge.
          </AccordionItem>
        </Accordion>
      );

      const header = screen.getByRole('button', { name: 'Billing' });
      await expect.element(header).toHaveAttribute('aria-expanded', 'false');

      await header.click();

      await expect.element(header).toHaveAttribute('aria-expanded', 'true');
    });

    it('reports which sections are open', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Accordion onValueChange={onValueChange}>
          <AccordionItem value="billing" title="Billing" />
        </Accordion>
      );

      await screen.getByRole('button', { name: 'Billing' }).click();

      expect(onValueChange).toHaveBeenCalledWith(['billing']);
    });

    // Closing the last one as you open the next is the whole reason an accordion
    // is not just a stack of collapsibles.
    it('closes the open section when another is opened', async () => {
      const screen = await render(
        <Accordion defaultValue={['billing']}>
          <AccordionItem value="billing" title="Billing" />
          <AccordionItem value="regions" title="Regions" />
        </Accordion>
      );

      await screen.getByRole('button', { name: 'Regions' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'false');
      await expect
        .element(screen.getByRole('button', { name: 'Regions' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('keeps both open when multiple is set', async () => {
      const screen = await render(
        <Accordion multiple defaultValue={['billing']}>
          <AccordionItem value="billing" title="Billing" />
          <AccordionItem value="regions" title="Regions" />
        </Accordion>
      );

      await screen.getByRole('button', { name: 'Regions' }).click();

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'true');
      await expect
        .element(screen.getByRole('button', { name: 'Regions' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('follows a controlled value', async () => {
      const screen = await render(
        <Accordion value={[]}>
          <AccordionItem value="billing" title="Billing" />
        </Accordion>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'false');

      await screen.rerender(
        <Accordion value={['billing']}>
          <AccordionItem value="billing" title="Billing" />
        </Accordion>
      );

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'true');
    });

    it('does not fold a disabled section', async () => {
      const screen = await render(
        <Accordion>
          <AccordionItem value="billing" title="Billing" disabled />
        </Accordion>
      );

      const header = screen.getByRole('button', { name: 'Billing' });
      await header.click({ force: true });

      await expect.element(header).toHaveAttribute('aria-expanded', 'false');
    });

    it('does not fold anything when the whole accordion is disabled', async () => {
      const screen = await render(
        <Accordion disabled>
          <AccordionItem value="billing" title="Billing" />
        </Accordion>
      );

      await screen.getByRole('button', { name: 'Billing' }).click({ force: true });

      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'false');
    });
  });

  describe('the action beside the header', () => {
    // A header that both folds and holds a button has two things to press, and
    // one of them cannot be nested inside the other.
    it('keeps the action out of the folding area', async () => {
      const onAction = vi.fn();
      const screen = await render(
        <Accordion>
          <AccordionItem
            value="billing"
            title="Billing"
            action={<Button onClick={onAction}>Manage</Button>}
          />
        </Accordion>
      );

      await screen.getByRole('button', { name: 'Manage' }).click();

      expect(onAction).toHaveBeenCalledTimes(1);
      await expect
        .element(screen.getByRole('button', { name: 'Billing' }))
        .toHaveAttribute('aria-expanded', 'false');
    });
  });

  describe('what the section inherits', () => {
    it('takes its size from the accordion rather than from itself', async () => {
      const screen = await render(
        <Accordion size="xl">
          <AccordionItem title="Billing" />
        </Accordion>
      );

      expect(screen.getByRole('button', { name: 'Billing' }).element()).toHaveClass('px-6');
    });

    it('takes its density from the accordion', async () => {
      const screen = await render(
        <Accordion density="compact">
          <AccordionItem title="Billing" />
        </Accordion>
      );

      expect(screen.getByRole('button', { name: 'Billing' }).element()).toHaveClass('px-2.5');
    });

    // A section cannot be a floating tile and a ruled line at the same time.
    it('squares the sections off when the accordion is ruled', async () => {
      const screen = await render(
        <Accordion dividers={false}>
          <AccordionItem title="Billing" />
        </Accordion>
      );

      expect(screen.getByRole('button', { name: 'Billing' }).element().className).toContain(
        'rounded'
      );

      await screen.rerender(
        <Accordion dividers>
          <AccordionItem title="Billing" />
        </Accordion>
      );

      expect(screen.getByRole('button', { name: 'Billing' }).element().className).not.toContain(
        'rounded'
      );
    });
  });

  describe('style props', () => {
    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(
        <Accordion color="success" className="probe">
          <AccordionItem title="Billing" />
        </Accordion>
      );
      const element = screen.container.querySelector('.probe') as HTMLElement;

      expect(element.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-success-line)');
    });

    it('maps elevation onto the token slots', async () => {
      const screen = await render(
        <Accordion elevation={3} className="probe">
          <AccordionItem title="Billing" />
        </Accordion>
      );
      const element = screen.container.querySelector('.probe') as HTMLElement;

      expect(element.style.getPropertyValue('--n-elev')).toBe('var(--neba-shadow-3)');
    });

    it('is an outline accordion by default', async () => {
      const screen = await render(
        <Accordion className="probe">
          <AccordionItem title="Billing" />
        </Accordion>
      );

      expect(screen.container.querySelector('.probe')).toHaveClass('border');
    });

    // The panel animates its height, which moves no text relative to the box it
    // is in. Nothing here is ever transformed.
    it('never applies a transform', async () => {
      const screen = await render(
        <Accordion defaultValue={['billing']}>
          <AccordionItem value="billing" title="Billing" subtitle="Invoices">
            How we charge.
          </AccordionItem>
        </Accordion>
      );

      expect(screen.container.innerHTML).not.toContain('translate');
    });
  });
});
