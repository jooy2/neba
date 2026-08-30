import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Tour } from 'neba';

const STEPS = [
  { target: '#tour-save', title: 'Save', content: 'This writes the change.' },
  { target: '#tour-deploy', title: 'Deploy', content: 'And this ships it.' },
  { title: 'That is all', content: 'Nothing else to point at.' }
];

function Page(props: React.ComponentProps<typeof Tour>) {
  return (
    <div>
      <button id="tour-save" type="button">
        Save
      </button>
      <button id="tour-deploy" type="button">
        Deploy
      </button>
      <Tour {...props} />
    </div>
  );
}

describe('Tour', () => {
  describe('rendering', () => {
    it('draws nothing until it is running', async () => {
      const screen = await render(<Page steps={STEPS} />);

      expect(screen.getByText('This writes the change.').query()).toBeNull();
    });

    it('draws the first step when it is', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen />);

      await expect.element(screen.getByText('Save').last()).toBeInTheDocument();
      await expect.element(screen.getByText('This writes the change.')).toBeInTheDocument();
    });

    it('counts the steps', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen />);

      await expect.element(screen.getByText('1 of 3')).toBeInTheDocument();
    });

    it('renders nothing at all with no steps', async () => {
      const screen = await render(<Page steps={[]} defaultOpen />);

      expect(screen.getByRole('dialog').query()).toBeNull();
    });
  });

  describe('walking through', () => {
    it('goes forward and back', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen />);

      await screen.getByRole('button', { name: 'Next' }).click();
      await expect.element(screen.getByText('And this ships it.')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Previous' }).click();
      await expect.element(screen.getByText('This writes the change.')).toBeInTheDocument();
    });

    it('offers no Previous on the first step', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen />);

      expect(screen.getByRole('button', { name: 'Previous' }).query()).toBeNull();
    });

    it('turns Next into Done on the last one', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen defaultStep={2} />);

      await expect.element(screen.getByRole('button', { name: 'Done' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Next' }).query()).toBeNull();
    });

    it('reports the step it moved to', async () => {
      const onStepChange = vi.fn();
      const screen = await render(<Page steps={STEPS} defaultOpen onStepChange={onStepChange} />);

      await screen.getByRole('button', { name: 'Next' }).click();

      expect(onStepChange).toHaveBeenCalledWith(1);
    });

    it('stays where a controlled step puts it', async () => {
      const screen = await render(
        <Page steps={STEPS} defaultOpen step={0} onStepChange={() => {}} />
      );

      await screen.getByRole('button', { name: 'Next' }).click();

      await expect.element(screen.getByText('This writes the change.')).toBeInTheDocument();
    });
  });

  describe('ending', () => {
    it('finishes on the last step and closes', async () => {
      const onFinish = vi.fn();
      const onOpenChange = vi.fn();
      const screen = await render(
        <Page
          steps={STEPS}
          defaultOpen
          defaultStep={2}
          onFinish={onFinish}
          onOpenChange={onOpenChange}
        />
      );

      await screen.getByRole('button', { name: 'Done' }).click();

      expect(onFinish).toHaveBeenCalledTimes(1);
      expect(onOpenChange).toHaveBeenCalledWith(false);
    });

    it('skips out of the middle', async () => {
      const onOpenChange = vi.fn();
      const screen = await render(<Page steps={STEPS} defaultOpen onOpenChange={onOpenChange} />);

      await screen.getByRole('button', { name: 'Skip' }).click();

      expect(onOpenChange).toHaveBeenCalledWith(false);
    });

    it('offers no Skip on the last step', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen defaultStep={2} />);

      expect(screen.getByRole('button', { name: 'Skip' }).query()).toBeNull();
    });

    it('drops the Skip button when it is turned off', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen skippable={false} />);

      expect(screen.getByRole('button', { name: 'Skip' }).query()).toBeNull();
    });
  });

  describe('the mask', () => {
    it('never takes the pointer, so the page stays usable', async () => {
      const screen = await render(<Page steps={STEPS} defaultOpen />);

      await screen.getByRole('button', { name: 'Deploy' }).click();

      await expect.element(screen.getByText('This writes the change.')).toBeInTheDocument();
    });
  });
  describe('slots', () => {
    it('puts a class name on the card and on every part it was given one for', async () => {
      const screen = await render(
        <Page
          steps={STEPS}
          defaultOpen
          className="card-class"
          classNames={{
            mask: 'slot-mask',
            title: 'slot-title',
            description: 'slot-description',
            close: 'slot-close',
            footer: 'slot-footer'
          }}
        />
      );

      const title = screen.getByRole('heading', { name: 'Save' });

      await expect.element(title).toHaveClass('slot-title');
      expect(screen.getByText('This writes the change.').element()).toHaveClass('slot-description');

      const card = title.element().closest('.card-class');

      expect(card).not.toBeNull();
      expect(card?.querySelector('.slot-close')).not.toBeNull();
      expect(card?.querySelector('.slot-footer')).not.toBeNull();
    });

    /** The mask is a sibling of the card, so nothing written against it reaches. */
    it('reaches the mask, which sits outside the card', async () => {
      const screen = await render(
        <Page steps={STEPS} defaultOpen classNames={{ mask: 'slot-mask' }} />
      );

      await expect.element(screen.getByRole('heading', { name: 'Save' })).toBeInTheDocument();
      expect(document.querySelector('.slot-mask')).not.toBeNull();
    });

    it('draws no mask class when the mask is off', async () => {
      const screen = await render(
        <Page steps={STEPS} defaultOpen mask={false} classNames={{ mask: 'slot-mask' }} />
      );

      await expect.element(screen.getByRole('heading', { name: 'Save' })).toBeInTheDocument();
      expect(document.querySelector('.slot-mask')).toBeNull();
    });
  });
});
