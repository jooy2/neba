import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Select } from 'neba';

const PLANS = [
  { value: 'starter', label: 'Starter' },
  { value: 'team', label: 'Team' },
  { value: 'enterprise', label: 'Enterprise', disabled: true }
];

describe('Select', () => {
  describe('rendering', () => {
    it('renders a combobox named by its label', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" />);

      await expect.element(screen.getByRole('combobox', { name: 'Plan' })).toBeInTheDocument();
    });

    it('shows the placeholder while nothing is chosen', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" placeholder="Pick one" />);

      await expect.element(screen.getByText('Pick one')).toBeInTheDocument();
    });

    it("shows the chosen option's label rather than its value", async () => {
      const screen = await render(<Select items={PLANS} label="Plan" defaultValue="team" />);

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Team');
      expect(screen.getByRole('combobox').element().textContent).not.toContain('team');
    });

    it('falls back to the value when an option has no label', async () => {
      const screen = await render(
        <Select items={[{ value: 'kr' }]} label="Country" defaultValue="kr" />
      );

      await expect.element(screen.getByText('kr')).toBeInTheDocument();
    });

    it('renders the description', async () => {
      const screen = await render(
        <Select items={PLANS} label="Plan" description="Change it any time." />
      );

      await expect.element(screen.getByText('Change it any time.')).toBeInTheDocument();
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Select items={PLANS} label="Before" />);

      await screen.rerender(<Select items={PLANS} label="After" />);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names on the field wrapper', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" className="my-own-class" />);

      expect(screen.getByText('Plan').element().closest('.my-own-class')).not.toBeNull();
    });
  });

  describe('behaviour', () => {
    it('opens the list and chooses an option', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Select items={PLANS} label="Plan" placeholder="Pick one" onValueChange={onValueChange} />
      );

      await screen.getByRole('combobox').click();

      await expect.element(screen.getByRole('option', { name: 'Team' })).toBeInTheDocument();

      await screen.getByRole('option', { name: 'Team' }).click();

      expect(onValueChange).toHaveBeenCalledWith('team');
      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Team');
    });

    it('marks a disabled option as unavailable', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" />);

      await screen.getByRole('combobox').click();

      await expect
        .element(screen.getByRole('option', { name: 'Enterprise' }))
        .toHaveAttribute('aria-disabled', 'true');
    });

    it('honours a controlled value', async () => {
      const screen = await render(
        <Select items={PLANS} label="Plan" value="team" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Team');

      await screen.rerender(
        <Select items={PLANS} label="Plan" value="starter" onValueChange={() => {}} />
      );

      await expect.element(screen.getByRole('combobox')).toHaveTextContent('Starter');
    });

    it('does not open when disabled', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" disabled />);

      await expect.element(screen.getByRole('combobox')).toBeDisabled();
      expect(screen.getByRole('option', { name: 'Team' }).query()).toBeNull();
    });
  });

  describe('validation', () => {
    it('renders the error message', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" error="Choose a plan." />);

      await expect.element(screen.getByText('Choose a plan.')).toBeInTheDocument();
    });

    it('re-points the colour family at danger when invalid', async () => {
      const screen = await render(
        <Select items={PLANS} label="Plan" color="success" error="Choose a plan." />
      );
      const root = screen
        .getByText('Plan', { exact: true })
        .element()
        .closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-ring')).toBe('var(--neba-danger-ring)');
    });
  });

  describe('style props', () => {
    it('is drawn on the same shell as a TextField', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" />);
      const trigger = screen.getByRole('combobox').element();

      expect(trigger).toHaveClass('h-8');
      expect(trigger).toHaveClass('px-4');
      expect(trigger).toHaveClass('border');
    });

    it('changes height with size but not with density', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" size="lg" />);

      expect(screen.getByRole('combobox').element()).toHaveClass('h-10');

      await screen.rerender(<Select items={PLANS} label="Plan" size="lg" density="compact" />);
      const trigger = screen.getByRole('combobox').element();

      expect(trigger).toHaveClass('h-10');
      expect(trigger).toHaveClass('px-3');
    });

    /**
     * The popup is portalled to the end of `<body>`, so nothing declared on the
     * Field reaches it. Without its own slots every `var(--n-*)` in the popup
     * resolved to nothing: the border fell back to `currentColor` — a black
     * hairline — and the highlight on a hovered row did not light at all.
     */
    it('carries its own colour slots, because it renders outside the field', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" color="info" />);

      await screen.getByRole('combobox').click();
      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();

      const popup = screen.getByRole('listbox').element() as HTMLElement;

      expect(popup.closest('[class*="neba-scope"]')).toBeNull();
      expect(popup.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
      expect(popup.style.getPropertyValue('--n-soft-hover')).toBe('var(--neba-info-soft-hover)');
      expect(popup.style.getPropertyValue('--n-accent')).toBe('var(--neba-info-accent)');
      expect(popup.style.getPropertyValue('--n-panel-press')).toBe('var(--neba-panel-press)');
    });

    it('follows the danger family into the popup when invalid', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" error="Pick one" />);

      await screen.getByRole('combobox').click();
      await expect.element(screen.getByRole('listbox')).toBeInTheDocument();

      expect(
        (screen.getByRole('listbox').element() as HTMLElement).style.getPropertyValue('--n-line')
      ).toBe('var(--neba-danger-line)');
    });

    it('keeps the sheet undyed while colouring the edge', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" color="info" />);
      const root = screen.getByText('Plan').element().closest('[style]') as HTMLElement;

      expect(root.style.getPropertyValue('--n-panel')).toBe('var(--neba-panel)');
      expect(root.style.getPropertyValue('--n-line')).toBe('var(--neba-info-line)');
    });

    it('stretches to the container when full width', async () => {
      const screen = await render(<Select items={PLANS} label="Plan" fullWidth />);
      const root = screen.getByText('Plan').element().closest('[style]') as HTMLElement;

      expect(root).toHaveClass('w-full');
      expect(root).not.toHaveClass('inline-flex');
    });
  });

  /**
   * A select that is not `fullWidth` is sized by its content, so the trigger
   * would grow and shrink every time a shorter option was chosen — and the
   * option being reached for would move mid-click. The trigger therefore carries
   * a hidden stack of every label it could ever show, which pins its width to
   * the widest of them.
   *
   * Nothing here measures a width: no stylesheet is loaded in this run, so the
   * assertions are about the markup that does the reserving.
   */
  describe('width', () => {
    const CITIES = [
      { value: 'kr', label: 'Seoul' },
      { value: 'us', label: 'Washington DC' },
      { value: 'de' }
    ];

    const sizerOf = (root: HTMLElement) =>
      root.querySelector('[aria-hidden="true"].invisible') as HTMLElement;

    const samplesOf = (root: HTMLElement) =>
      [...sizerOf(root).children].map((child) => child.getAttribute('data-sample'));

    it('reserves room for every label, chosen or not', async () => {
      const screen = await render(<Select items={CITIES} label="Region" defaultValue="kr" />);

      expect(samplesOf(screen.getByRole('combobox').element() as HTMLElement)).toEqual([
        'Seoul',
        'Washington DC',
        'de'
      ]);
    });

    it('reserves room for the placeholder too', async () => {
      const screen = await render(
        <Select items={CITIES} label="Region" placeholder="Choose a region" />
      );

      expect(samplesOf(screen.getByRole('combobox').element() as HTMLElement)).toContain(
        'Choose a region'
      );
    });

    it('follows a changed item list', async () => {
      const screen = await render(<Select items={CITIES} label="Region" />);

      await screen.rerender(<Select items={[{ value: 'jp', label: 'Tokyo' }]} label="Region" />);

      expect(samplesOf(screen.getByRole('combobox').element() as HTMLElement)).toEqual(['Tokyo']);
    });

    /**
     * Drawn as generated content off a data attribute rather than as text
     * nodes. It lays out identically, so it reserves the same width — and it
     * leaves nothing for a `getByText` or a find-in-page to trip over, which is
     * what would otherwise make every query for a chosen option ambiguous.
     */
    it('reserves the width without putting the words in the document', async () => {
      const screen = await render(<Select items={CITIES} label="Region" defaultValue="kr" />);
      const trigger = screen.getByRole('combobox').element() as HTMLElement;

      expect(trigger.textContent).toBe('Seoul');
      expect(screen.getByText('Washington DC').query()).toBeNull();
      expect([...sizerOf(trigger).children].every((child) => child.textContent === '')).toBe(true);
    });

    it('keeps the sizer out of sight and out of the accessibility tree', async () => {
      const screen = await render(<Select items={CITIES} label="Region" defaultValue="kr" />);
      const sizer = sizerOf(screen.getByRole('combobox').element() as HTMLElement);

      expect(sizer).toHaveAttribute('aria-hidden', 'true');
      // Not `hidden` and not `display:none`, either of which would stop it
      // being laid out and so stop it reserving anything. Clipped to no height
      // instead, so it costs width and nothing else.
      expect(sizer).toHaveClass('invisible');
      expect(sizer).toHaveClass('h-0');
      expect(sizer).toHaveClass('overflow-hidden');
    });

    it('renders a node label for real, since there is nothing to measure in an attribute', async () => {
      const screen = await render(
        <Select items={[{ value: 'kr', label: <em>Seoul</em> }]} label="Region" />
      );
      const sizer = sizerOf(screen.getByRole('combobox').element() as HTMLElement);

      expect(sizer.textContent).toBe('Seoul');
    });

    it('leaves the column shrinkable, so a narrow container still wins', async () => {
      const screen = await render(<Select items={CITIES} label="Region" fullWidth />);
      const column = sizerOf(screen.getByRole('combobox').element() as HTMLElement)
        .parentElement as HTMLElement;

      expect(column).toHaveClass('min-w-0');
      expect(column).toHaveClass('flex-1');
    });
  });
});
