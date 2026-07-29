import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Divider } from 'neba';

describe('Divider', () => {
  describe('rendering', () => {
    it('renders a separator', async () => {
      const screen = await render(<Divider />);

      await expect.element(screen.getByRole('separator')).toBeInTheDocument();
    });

    it('is horizontal by default', async () => {
      const screen = await render(<Divider />);
      const element = screen.getByRole('separator').element();

      expect(element).toHaveClass('border-t');
      expect(element).not.toHaveClass('border-l');
    });

    it('turns the line on its side when vertical', async () => {
      const screen = await render(<Divider orientation="vertical" />);
      const element = screen.getByRole('separator').element();

      expect(element).toHaveClass('border-l');
      expect(element).toHaveAttribute('aria-orientation', 'vertical');
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Divider className="my-own-class" />);

      expect(screen.getByRole('separator').element()).toHaveClass('my-own-class');
    });

    it('maps color onto the hairline slot', async () => {
      const screen = await render(<Divider color="danger" />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-danger-line)');
    });

    it('defaults to the primary color', async () => {
      const screen = await render(<Divider />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-line')).toBe('var(--neba-primary-line)');
    });
  });

  describe('length and thickness', () => {
    it('stretches to its flex parent when no length is given', async () => {
      const screen = await render(<Divider orientation="vertical" />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element).toHaveClass('self-stretch');
      expect(element.style.height).toBe('');
    });

    it('takes a number of pixels as its length', async () => {
      const screen = await render(<Divider length={120} />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.width).toBe('120px');
    });

    it('takes any CSS length as its length', async () => {
      const screen = await render(<Divider length="50%" />);

      expect((screen.getByRole('separator').element() as HTMLElement).style.width).toBe('50%');
    });

    it('sets the height rather than the width when vertical, and stops stretching', async () => {
      const screen = await render(<Divider orientation="vertical" length={48} />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.height).toBe('48px');
      expect(element.style.width).toBe('');
      expect(element).not.toHaveClass('self-stretch');
    });

    it('is a 1px rule by default', async () => {
      const screen = await render(<Divider />);

      expect(
        (screen.getByRole('separator').element() as HTMLElement).style.getPropertyValue('--n-rule')
      ).toBe('1px');
    });

    it('maps thickness onto the rule slot, in both spellings', async () => {
      const screen = await render(<Divider thickness={4} />);
      const element = screen.getByRole('separator').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-rule')).toBe('4px');

      await screen.rerender(<Divider thickness="0.25rem" />);

      expect(element.style.getPropertyValue('--n-rule')).toBe('0.25rem');
    });

    it('gives the label variant the same rule on both stubs', async () => {
      const screen = await render(
        <Divider thickness={3} data-testid="divider">
          OR
        </Divider>
      );
      const element = screen.getByTestId('divider').element() as HTMLElement;
      const children = [...element.children];

      expect(element.style.getPropertyValue('--n-rule')).toBe('3px');
      expect(children[0]).toHaveClass('[border-top-width:var(--n-rule)]');
      expect(children[2]).toHaveClass('[border-top-width:var(--n-rule)]');
    });

    it('sizes the label variant too', async () => {
      const screen = await render(<Divider length={200}>OR</Divider>);

      expect((screen.getByRole('separator').element() as HTMLElement).style.width).toBe('200px');
    });
  });

  describe('with a label', () => {
    it('renders the label and names the separator with it', async () => {
      const screen = await render(<Divider>OR</Divider>);

      await expect.element(screen.getByRole('separator', { name: 'OR' })).toBeInTheDocument();
    });

    it('breaks the line into two halves around the label', async () => {
      const screen = await render(<Divider data-testid="divider">OR</Divider>);
      const children = [...screen.getByTestId('divider').element().children];

      expect(children).toHaveLength(3);
      expect(children[0]).toHaveClass('border-t');
      expect(children[1].textContent).toBe('OR');
      expect(children[2]).toHaveClass('border-t');
    });

    it('leaves a short stub on the near side when the label is not centred', async () => {
      const screen = await render(
        <Divider textAlign="start" data-testid="divider">
          OR
        </Divider>
      );
      const children = [...screen.getByTestId('divider').element().children];

      expect(children[0]).toHaveClass('w-4');
      expect(children[2]).toHaveClass('flex-1');
    });

    it('centres the label by default', async () => {
      const screen = await render(<Divider data-testid="divider">OR</Divider>);
      const children = [...screen.getByTestId('divider').element().children];

      expect(children[0]).toHaveClass('flex-1');
      expect(children[2]).toHaveClass('flex-1');
    });

    it('reflects a changed label on re-render', async () => {
      const screen = await render(<Divider>Before</Divider>);

      await screen.rerender(<Divider>After</Divider>);

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('turns the label with the line when vertical', async () => {
      const screen = await render(
        <Divider orientation="vertical" data-testid="divider">
          OR
        </Divider>
      );
      const children = [...screen.getByTestId('divider').element().children];

      expect(children[0]).toHaveClass('border-l');
      expect(children[1]).toHaveClass('[writing-mode:vertical-rl]');
    });

    it('treats an empty string as no label at all', async () => {
      const screen = await render(<Divider data-testid="divider">{''}</Divider>);
      const element = screen.getByTestId('divider').element();

      expect(element.children).toHaveLength(0);
      expect(element).toHaveClass('border-t');
    });
  });
});
