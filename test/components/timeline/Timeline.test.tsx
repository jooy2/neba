import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Timeline, TimelineItem } from 'neba';

function Basic(props: React.ComponentProps<typeof Timeline>) {
  return (
    <Timeline {...props}>
      <TimelineItem title="Ordered">Payment taken.</TimelineItem>
      <TimelineItem title="Packed">Left the warehouse.</TimelineItem>
      <TimelineItem title="Delivered">Signed for.</TimelineItem>
    </Timeline>
  );
}

/** What each item's computed status is, in order. */
function statuses(root: Element): (string | null)[] {
  return Array.from(root.querySelectorAll('li')).map((item) => item.getAttribute('data-status'));
}

describe('Timeline', () => {
  describe('rendering', () => {
    // The order *is* the content, so it is an `<ol>`: a screen reader announcing
    // an unordered list would be describing something else.
    it('renders an ordered list of its items', async () => {
      const screen = await render(<Basic />);
      const list = screen.getByRole('list').element();

      expect(list.tagName).toBe('OL');
      expect(list.querySelectorAll('li')).toHaveLength(3);
    });

    it('renders the title, the meta and the body of an item', async () => {
      const screen = await render(
        <Timeline>
          <TimelineItem title="Packed" meta="2 days ago">
            Left the warehouse.
          </TimelineItem>
        </Timeline>
      );

      await expect.element(screen.getByText('Packed')).toBeInTheDocument();
      await expect.element(screen.getByText('2 days ago')).toBeInTheDocument();
      await expect.element(screen.getByText('Left the warehouse.')).toBeInTheDocument();
    });

    it('renders an item with only a body', async () => {
      const screen = await render(
        <Timeline>
          <TimelineItem>Just this.</TimelineItem>
        </Timeline>
      );

      await expect.element(screen.getByText('Just this.')).toBeInTheDocument();
    });

    it('draws what is passed as the bullet', async () => {
      const screen = await render(
        <Timeline>
          <TimelineItem bullet="1">Ordered</TimelineItem>
        </Timeline>
      );

      expect(screen.container.querySelector('li > span')?.textContent).toBe('1');
    });

    it('renders something else when told to', async () => {
      const screen = await render(<Basic render={<ul />} />);

      expect(screen.getByRole('list').element().tagName).toBe('UL');
    });

    it('reflects a changed title on re-render', async () => {
      const screen = await render(
        <Timeline>
          <TimelineItem title="Before">Body</TimelineItem>
        </Timeline>
      );

      await screen.rerender(
        <Timeline>
          <TimelineItem title="After">Body</TimelineItem>
        </Timeline>
      );

      await expect.element(screen.getByText('After')).toBeInTheDocument();
      expect(screen.getByText('Before').query()).toBeNull();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Basic className="my-own-class" />);

      expect(screen.getByRole('list').element()).toHaveClass('my-own-class');
    });
  });

  describe('progress', () => {
    it('leaves every item upcoming when active is not given', async () => {
      const screen = await render(<Basic />);

      expect(statuses(screen.container)).toEqual(['upcoming', 'upcoming', 'upcoming']);
    });

    it('splits the sequence around the active index', async () => {
      const screen = await render(<Basic active={1} />);

      expect(statuses(screen.container)).toEqual(['complete', 'current', 'upcoming']);
    });

    it('marks the whole sequence done when active is past the end', async () => {
      const screen = await render(<Basic active={3} />);

      expect(statuses(screen.container)).toEqual(['complete', 'complete', 'complete']);
    });

    it('moves the current step when active changes', async () => {
      const screen = await render(<Basic active={0} />);

      expect(statuses(screen.container)).toEqual(['current', 'upcoming', 'upcoming']);

      await screen.rerender(<Basic active={2} />);

      expect(statuses(screen.container)).toEqual(['complete', 'complete', 'current']);
    });

    // A step that failed and stopped the sequence is not something an index can
    // describe, which is what the per-item override is for.
    it('lets an item override what the index computed', async () => {
      const screen = await render(
        <Timeline active={2}>
          <TimelineItem title="Ordered">a</TimelineItem>
          <TimelineItem title="Packed" status="upcoming">
            b
          </TimelineItem>
          <TimelineItem title="Delivered">c</TimelineItem>
        </Timeline>
      );

      expect(statuses(screen.container)).toEqual(['complete', 'upcoming', 'current']);
    });

    it('counts only the items that are actually on the page', async () => {
      const screen = await render(
        <Timeline active={1}>
          <TimelineItem title="Ordered">a</TimelineItem>
          {false}
          <TimelineItem title="Packed">b</TimelineItem>
        </Timeline>
      );

      expect(statuses(screen.container)).toEqual(['complete', 'current']);
    });

    it('tells a screen reader which step is the current one', async () => {
      const screen = await render(<Basic active={1} />);
      const items = screen.container.querySelectorAll('li');

      expect(items[1]).toHaveAttribute('aria-current', 'step');
      expect(items[0]).not.toHaveAttribute('aria-current');
    });
  });

  describe('the connector', () => {
    it('draws a line after every item but the last', async () => {
      const screen = await render(<Basic />);
      const items = screen.container.querySelectorAll('li');

      expect(items[0].querySelector('[aria-hidden="true"].absolute')).not.toBeNull();
      expect(items[2].querySelector('[aria-hidden="true"].absolute')).toBeNull();
    });

    it('takes the line away for connector="none"', async () => {
      const screen = await render(
        <Timeline>
          <TimelineItem connector="none">a</TimelineItem>
          <TimelineItem>b</TimelineItem>
        </Timeline>
      );
      const items = screen.container.querySelectorAll('li');

      expect(items[0].querySelector('[aria-hidden="true"].absolute')).toBeNull();
    });

    it('draws it dashed or dotted when asked', async () => {
      const screen = await render(
        <Timeline>
          <TimelineItem connector="dashed">a</TimelineItem>
          <TimelineItem>b</TimelineItem>
        </Timeline>
      );

      expect(screen.container.querySelector('li [aria-hidden="true"].absolute')).toHaveClass(
        'border-dashed'
      );
    });

    // The line belongs to the step it leaves, so it is coloured by whether that
    // step has been reached rather than by where it arrives.
    it('takes its colour from the item it leaves', async () => {
      const screen = await render(<Basic active={1} />);
      const items = screen.container.querySelectorAll('li');

      expect(items[0].querySelector('[aria-hidden="true"].absolute')).toHaveClass(
        '[border-color:var(--n-line-hover)]'
      );
      expect(items[1].querySelector('[aria-hidden="true"].absolute')).toHaveClass(
        '[border-color:var(--neba-border)]'
      );
    });
  });

  describe('style props', () => {
    it('maps color onto the token slots the styles read from', async () => {
      const screen = await render(<Basic color="success" active={1} />);
      const item = screen.container.querySelector('li') as HTMLElement;

      expect(item.style.getPropertyValue('--n-fill')).toBe('var(--neba-success-fill)');
      expect(item.style.getPropertyValue('--n-accent')).toBe('var(--neba-success-accent)');
    });

    it('lets one item take a colour of its own', async () => {
      const screen = await render(
        <Timeline color="primary" active={1}>
          <TimelineItem title="Ordered">a</TimelineItem>
          <TimelineItem title="Failed" color="danger">
            b
          </TimelineItem>
        </Timeline>
      );
      const items = screen.container.querySelectorAll('li');

      expect((items[0] as HTMLElement).style.getPropertyValue('--n-fill')).toBe(
        'var(--neba-primary-fill)'
      );
      expect((items[1] as HTMLElement).style.getPropertyValue('--n-fill')).toBe(
        'var(--neba-danger-fill)'
      );
    });

    it('changes the bullet with size', async () => {
      const screen = await render(<Basic size="sm" />);
      const item = screen.container.querySelector('li') as HTMLElement;

      expect(item.style.getPropertyValue('--n-bullet')).toBe('1rem');

      await screen.rerender(<Basic size="xl" />);

      expect(
        (screen.container.querySelector('li') as HTMLElement).style.getPropertyValue('--n-bullet')
      ).toBe('1.875rem');
    });

    // Density is spacing and nothing else — the bullet and the type stay put.
    it('changes the space between items with density but not the bullet', async () => {
      const screen = await render(<Basic size="md" />);
      const item = screen.container.querySelector('li') as HTMLElement;

      expect(item).toHaveClass('pb-7');
      expect(item.style.getPropertyValue('--n-bullet')).toBe('1.25rem');

      await screen.rerender(<Basic size="md" density="compact" />);

      const compact = screen.container.querySelector('li') as HTMLElement;
      expect(compact).toHaveClass('pb-4');
      expect(compact.style.getPropertyValue('--n-bullet')).toBe('1.25rem');
    });

    it('lays the sequence out across when horizontal', async () => {
      const screen = await render(<Basic orientation="horizontal" />);

      expect(screen.getByRole('list').element()).toHaveClass('flex-row');
      expect(screen.container.querySelector('li')).toHaveClass('flex-col');
    });
  });
});
