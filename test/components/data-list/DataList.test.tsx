import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Chip, DataList, DataListItem } from 'neba';

function Details(props: React.ComponentProps<typeof DataList>) {
  return (
    <DataList data-testid="details" {...props}>
      <DataListItem label="Status">
        <Chip size="xs">Live</Chip>
      </DataListItem>
      <DataListItem label="Region">Frankfurt</DataListItem>
      <DataListItem label="Commit">8f2c1a</DataListItem>
    </DataList>
  );
}

describe('DataList', () => {
  describe('rendering', () => {
    it('renders a description list of real pairs', async () => {
      const screen = await render(<Details />);
      const list = screen.getByTestId('details').element();

      expect(list.tagName).toBe('DL');
      expect(list.querySelectorAll('dt')).toHaveLength(3);
      expect(list.querySelectorAll('dd')).toHaveLength(3);
    });

    it('puts the label in the dt and the value in the dd', async () => {
      const screen = await render(<Details />);
      const list = screen.getByTestId('details').element();

      expect(list.querySelectorAll('dt')[1]).toHaveTextContent('Region');
      expect(list.querySelectorAll('dd')[1]).toHaveTextContent('Frankfurt');
    });

    it('takes a node as the value', async () => {
      const screen = await render(<Details />);

      await expect.element(screen.getByText('Live')).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Details className="my-own-class" />);

      expect(screen.getByTestId('details').element()).toHaveClass('my-own-class');
    });

    it('reflects a changed value on re-render', async () => {
      const screen = await render(
        <DataList>
          <DataListItem label="Region">Frankfurt</DataListItem>
        </DataList>
      );

      await screen.rerender(
        <DataList>
          <DataListItem label="Region">Seoul</DataListItem>
        </DataList>
      );

      await expect.element(screen.getByText('Seoul')).toBeInTheDocument();
    });
  });

  describe('orientation', () => {
    it('lays the labels beside the values by default', async () => {
      const screen = await render(<Details />);

      expect(screen.getByTestId('details').element()).toHaveClass('grid');
    });

    it('stacks them when vertical', async () => {
      const screen = await render(<Details orientation="vertical" />);
      const list = screen.getByTestId('details').element();

      expect(list).toHaveClass('flex-col');
      expect(list).not.toHaveClass('grid');
    });
  });

  describe('appearance', () => {
    it('sizes the label column to the widest label', async () => {
      const screen = await render(<Details />);
      const element = screen.getByTestId('details').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-label')).toBe('max-content');
    });

    it('takes a label width of its own', async () => {
      const screen = await render(<Details labelWidth={140} />);
      const element = screen.getByTestId('details').element() as HTMLElement;

      expect(element.style.getPropertyValue('--n-label')).toBe('140px');
    });

    it('draws no hairlines unless asked', async () => {
      const screen = await render(<Details />);

      expect(screen.getByTestId('details').element().className).not.toContain('border-t');
    });

    it('draws them when it is', async () => {
      const screen = await render(<Details dividers />);

      expect(screen.getByTestId('details').element().className).toContain('border-t');
    });
  });
});
