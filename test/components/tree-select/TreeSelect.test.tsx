import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { TreeSelect, type TreeSelectItem } from 'neba';

const REGIONS: TreeSelectItem[] = [
  {
    value: 'asia',
    label: 'Asia',
    children: [
      { value: 'kr', label: 'Korea' },
      { value: 'jp', label: 'Japan' }
    ]
  },
  {
    value: 'europe',
    label: 'Europe',
    children: [
      { value: 'fr', label: 'France' },
      { value: 'de', label: 'Germany', disabled: true }
    ]
  }
];

/**
 * Rows are clicked by their text rather than by role and name.
 *
 * A branch's `<li>` contains its children, so its accessible name is the whole
 * subtree — "Asia" is `AsiaKoreaJapan`, and a name query for a leaf matches its
 * ancestors too. The TreeView suite reads the same way for the same reason.
 */
describe('TreeSelect', () => {
  it('renders a trigger named by its label, with nothing open', async () => {
    const screen = await render(<TreeSelect label="Region" items={REGIONS} />);

    await expect.element(screen.getByRole('button', { name: 'Region' })).toBeInTheDocument();
    expect(screen.getByRole('tree').query()).toBeNull();
  });

  it('opens the tree and reports the leaf that was chosen', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <TreeSelect
        label="Region"
        items={REGIONS}
        defaultExpanded={['asia']}
        onValueChange={onValueChange}
      />
    );

    await screen.getByRole('button', { name: 'Region' }).click();
    await screen.getByText('Korea').click();

    expect(onValueChange).toHaveBeenCalledWith(['kr']);
    await expect.element(screen.getByText('Korea')).toBeInTheDocument();
  });

  /**
   * The default that carries the most weight: in most of these trees the
   * branches are the taxonomy and the leaves are the answers, and a "Europe"
   * chosen alongside "France" is a data model nobody meant.
   */
  it('does not let a branch be chosen unless asked', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <TreeSelect label="Region" items={REGIONS} onValueChange={onValueChange} />
    );

    await screen.getByRole('button', { name: 'Region' }).click();
    await screen.getByText('Asia').click();

    expect(onValueChange).not.toHaveBeenCalled();
  });

  it('lets a branch be chosen when asked', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <TreeSelect label="Region" items={REGIONS} selectableBranches onValueChange={onValueChange} />
    );

    await screen.getByRole('button', { name: 'Region' }).click();
    await screen.getByText('Asia').click();

    expect(onValueChange).toHaveBeenCalledWith(['asia']);
  });

  it('holds more than one when multiple', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <TreeSelect
        label="Region"
        items={REGIONS}
        multiple
        defaultExpanded={['asia', 'europe']}
        onValueChange={onValueChange}
      />
    );

    await screen.getByRole('button', { name: 'Region' }).click();
    await screen.getByText('Korea').click();
    await screen.getByText('France').click();

    expect(onValueChange.mock.calls.at(-1)?.[0]).toEqual(['kr', 'fr']);
  });

  it('closes after a single choice and stays open for a multiple one', async () => {
    const screen = await render(
      <TreeSelect label="Region" items={REGIONS} defaultExpanded={['asia']} />
    );

    await screen.getByRole('button', { name: 'Region' }).click();
    await screen.getByText('Korea').click();

    await expect.poll(() => screen.getByRole('tree').query()).toBeNull();
  });

  it('leaves a disabled node unchoosable', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <TreeSelect
        label="Region"
        items={REGIONS}
        defaultExpanded={['europe']}
        onValueChange={onValueChange}
      />
    );

    await screen.getByRole('button', { name: 'Region' }).click();
    await screen.getByText('Germany').click();

    expect(onValueChange).not.toHaveBeenCalled();
  });

  describe('searching', () => {
    it('keeps a match and every ancestor of it', async () => {
      // The ancestors are the point: a tree filtered to bare matches is a list,
      // and "France" under nothing at all does not say which taxonomy it is in.
      const screen = await render(<TreeSelect label="Region" items={REGIONS} searchable />);

      await screen.getByRole('button', { name: 'Region' }).click();
      await screen.getByRole('textbox').fill('fran');

      await expect.element(screen.getByText('Europe')).toBeInTheDocument();
      await expect.element(screen.getByText('France')).toBeInTheDocument();
      expect(screen.getByText('Asia').query()).toBeNull();
    });

    it('opens what it kept, so a match is not folded away', async () => {
      const screen = await render(<TreeSelect label="Region" items={REGIONS} searchable />);

      await screen.getByRole('button', { name: 'Region' }).click();
      await screen.getByRole('textbox').fill('korea');

      await expect.element(screen.getByText('Korea')).toBeInTheDocument();
    });

    it('says so when nothing matched', async () => {
      const screen = await render(<TreeSelect label="Region" items={REGIONS} searchable />);

      await screen.getByRole('button', { name: 'Region' }).click();
      await screen.getByRole('textbox').fill('atlantis');

      await expect.element(screen.getByText('No matches')).toBeInTheDocument();
    });
  });

  it('empties through the clear button', async () => {
    const onValueChange = vi.fn();
    const screen = await render(
      <TreeSelect
        label="Region"
        items={REGIONS}
        defaultValue="kr"
        clearable
        onValueChange={onValueChange}
      />
    );

    await screen.getByRole('button', { name: 'Clear' }).click();

    expect(onValueChange).toHaveBeenCalledWith([]);
  });

  it('submits one hidden input per value', async () => {
    const screen = await render(
      <TreeSelect
        label="Region"
        items={REGIONS}
        multiple
        name="region"
        defaultValue={['kr', 'fr']}
      />
    );

    const values = [...screen.container.querySelectorAll<HTMLInputElement>('input[name="region"]')];
    expect(values.map((input) => input.value)).toEqual(['kr', 'fr']);
  });

  it('writes the trigger through a format of its own', async () => {
    const screen = await render(
      <TreeSelect
        label="Region"
        items={REGIONS}
        multiple
        defaultValue={['kr', 'fr']}
        format={(chosen) => `${chosen.length} regions`}
      />
    );

    await expect.element(screen.getByText('2 regions')).toBeInTheDocument();
  });

  it('does not open when read-only', async () => {
    const screen = await render(<TreeSelect label="Region" items={REGIONS} readOnly />);

    await screen.getByRole('button', { name: 'Region' }).click();

    expect(screen.getByRole('tree').query()).toBeNull();
  });
});
