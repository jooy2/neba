import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { HowToSteps } from 'neba';
import { ko, registerMessages } from 'neba/locales';
import type { HowToStep } from 'neba';

/* The library ships English; a `locale` prop answers for a language the project
   has registered. The one assertion about that prop registers Korean the way a
   consumer would. */
registerMessages('ko', ko);

const STEPS: HowToStep[] = [
  { title: 'Install', content: 'One package.' },
  { title: 'Configure', content: 'One stylesheet import.' },
  { title: 'Use it', content: 'Render the component.' }
];

/** The rows of the list, in order. */
const rows = (root: Element) => [...root.querySelectorAll('ol > li')];

describe('HowToSteps', () => {
  describe('rendering', () => {
    it('lists every step', async () => {
      const screen = await render(<HowToSteps steps={STEPS} data-testid="guide" />);

      expect(rows(screen.getByTestId('guide').element())).toHaveLength(3);
    });

    it('draws the guide its own heading', async () => {
      const screen = await render(<HowToSteps steps={STEPS} title="Getting started" />);

      await expect
        .element(screen.getByRole('heading', { name: 'Getting started' }))
        .toBeInTheDocument();
    });

    // A guide whose data has not arrived is nothing, not an empty bordered box
    // with two dead buttons in it.
    it('draws nothing at all with no steps', async () => {
      const screen = await render(
        <div data-testid="host">
          <HowToSteps steps={[]} />
        </div>
      );

      expect(screen.getByTestId('host').element().children).toHaveLength(0);
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(
        <HowToSteps steps={STEPS} className="my-own-class" data-testid="guide" />
      );

      expect(screen.getByTestId('guide').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(<HowToSteps steps={STEPS} data-testid="guide" id="setup" />);

      expect(screen.getByTestId('guide').element()).toHaveAttribute('id', 'setup');
    });

    it('draws a step image with the title as its fallback text', async () => {
      const screen = await render(
        <HowToSteps steps={[{ title: 'Open the panel', image: '/panel.png' }]} />
      );

      await expect.element(screen.getByRole('img', { name: 'Open the panel' })).toBeInTheDocument();
    });
  });

  describe('moving between steps', () => {
    it('starts on the first step', async () => {
      const screen = await render(<HowToSteps steps={STEPS} />);

      await expect.element(screen.getByText('1 of 3')).toBeInTheDocument();
    });

    it('starts wherever it was told to', async () => {
      const screen = await render(<HowToSteps steps={STEPS} defaultStep={1} />);

      await expect.element(screen.getByText('2 of 3')).toBeInTheDocument();
    });

    it('moves forward and back', async () => {
      const screen = await render(<HowToSteps steps={STEPS} />);

      await screen.getByRole('button', { name: 'Next' }).click();
      await expect.element(screen.getByText('2 of 3')).toBeInTheDocument();

      await screen.getByRole('button', { name: 'Previous' }).click();
      await expect.element(screen.getByText('1 of 3')).toBeInTheDocument();
    });

    it('jumps to a step pressed in the list', async () => {
      const screen = await render(<HowToSteps steps={STEPS} />);

      await screen.getByRole('button', { name: 'Step 3: Use it' }).click();

      await expect.element(screen.getByText('3 of 3')).toBeInTheDocument();
    });

    it('reports every change', async () => {
      const onStepChange = vi.fn();
      const screen = await render(<HowToSteps steps={STEPS} onStepChange={onStepChange} />);

      await screen.getByRole('button', { name: 'Next' }).click();

      expect(onStepChange).toHaveBeenCalledWith(1);
    });

    it('has nowhere to go back to on the first step', async () => {
      const screen = await render(<HowToSteps steps={STEPS} />);

      await expect.element(screen.getByRole('button', { name: 'Previous' })).toBeDisabled();
    });

    it('takes the step it is given and changes nothing on its own', async () => {
      const onStepChange = vi.fn();
      const screen = await render(
        <HowToSteps steps={STEPS} step={1} onStepChange={onStepChange} />
      );

      await screen.getByRole('button', { name: 'Next' }).click();

      expect(onStepChange).toHaveBeenCalledWith(2);
      await expect.element(screen.getByText('2 of 3')).toBeInTheDocument();
    });

    // `steps` can shrink under a controlled index, and a guide pointing past the
    // end of its own list would draw an empty panel with no way back.
    it('clamps a step index past the end of the list', async () => {
      const screen = await render(<HowToSteps steps={STEPS} step={9} />);

      await expect.element(screen.getByText('3 of 3')).toBeInTheDocument();
    });
  });

  describe('finishing', () => {
    it('offers Done in place of Next on the last step', async () => {
      const screen = await render(<HowToSteps steps={STEPS} defaultStep={2} />);

      expect(screen.getByRole('button', { name: 'Next' }).query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Done' })).toBeInTheDocument();
    });

    it('says so, and offers to start again', async () => {
      const screen = await render(<HowToSteps steps={STEPS} defaultStep={2} />);

      await screen.getByRole('button', { name: 'Done' }).click();

      await expect.element(screen.getByText('All steps complete')).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Start over' })).toBeInTheDocument();
    });

    it('goes back to the first step when it is started again', async () => {
      const screen = await render(<HowToSteps steps={STEPS} defaultStep={2} />);

      await screen.getByRole('button', { name: 'Done' }).click();
      await screen.getByRole('button', { name: 'Start over' }).click();

      await expect.element(screen.getByText('1 of 3')).toBeInTheDocument();
    });

    it('reports finishing and starting again', async () => {
      const onCompletedChange = vi.fn();
      const screen = await render(
        <HowToSteps steps={STEPS} defaultStep={2} onCompletedChange={onCompletedChange} />
      );

      await screen.getByRole('button', { name: 'Done' }).click();
      expect(onCompletedChange).toHaveBeenLastCalledWith(true);

      await screen.getByRole('button', { name: 'Start over' }).click();
      expect(onCompletedChange).toHaveBeenLastCalledWith(false);
    });

    it('takes a completed state it is given', async () => {
      const screen = await render(<HowToSteps steps={STEPS} completed />);

      await expect.element(screen.getByText('All steps complete')).toBeInTheDocument();
    });

    it('says what it was told to say instead', async () => {
      const screen = await render(
        <HowToSteps steps={STEPS} completed completedContent="Your cron job is live." />
      );

      await expect.element(screen.getByText('Your cron job is live.')).toBeInTheDocument();
    });

    // With no finished state the last step is simply the last step: the button
    // stays "Next" and there is nothing left to press.
    it('has no finished state when completion is off', async () => {
      const screen = await render(<HowToSteps steps={STEPS} defaultStep={2} completion={false} />);

      expect(screen.getByRole('button', { name: 'Done' }).query()).toBeNull();
      await expect.element(screen.getByRole('button', { name: 'Next' })).toBeDisabled();
    });
  });

  describe('the panel', () => {
    /*
      Every step is in the same grid cell so the panel keeps the height of the
      tallest one and does not resize the card while the reader moves through
      it. The ones not showing are therefore still in the document — which is
      only safe because they are `inert`: out of the tab order, off the
      accessibility tree, and out of a find-in-page.
    */
    it('keeps every step in the document', async () => {
      const screen = await render(<HowToSteps steps={STEPS} data-testid="guide" />);
      const panels = screen.getByTestId('guide').element().querySelectorAll('[inert]');

      // Two steps that are not showing, plus the finished panel.
      expect(panels).toHaveLength(3);
    });

    it('makes the steps that are not showing inert', async () => {
      const screen = await render(<HowToSteps steps={STEPS} data-testid="guide" />);

      await expect.element(screen.getByText('One package.')).toBeVisible();
      expect(
        screen.getByText('One stylesheet import.').element().closest('[inert]')
      ).not.toBeNull();
    });

    it('un-inerts the step it moves to', async () => {
      const screen = await render(<HowToSteps steps={STEPS} />);

      await screen.getByRole('button', { name: 'Next' }).click();

      await expect
        .poll(() => screen.getByText('One stylesheet import.').element().closest('[inert]'))
        .toBeNull();
    });
  });

  describe('appearance', () => {
    it('bounds its height when it is told to', async () => {
      const screen = await render(<HowToSteps steps={STEPS} maxHeight={280} data-testid="guide" />);

      expect((screen.getByTestId('guide').element() as HTMLElement).style.maxHeight).toBe('280px');
    });

    it('takes the rail width it was given', async () => {
      const screen = await render(<HowToSteps steps={STEPS} railWidth={220} data-testid="guide" />);

      expect(
        (screen.getByTestId('guide').element() as HTMLElement).style.getPropertyValue(
          '--n-step-rail'
        )
      ).toBe('220px');
    });

    it('drops the button row when navigation is off', async () => {
      const screen = await render(<HowToSteps steps={STEPS} navigation={false} />);

      expect(screen.getByRole('button', { name: 'Next' }).query()).toBeNull();
      expect(screen.getByRole('button', { name: 'Previous' }).query()).toBeNull();
    });

    // The list is still the way forward with no buttons under the panel.
    it('still moves from the list with no buttons', async () => {
      const screen = await render(<HowToSteps steps={STEPS} navigation={false} />);

      await screen.getByRole('button', { name: 'Step 2: Configure' }).click();

      await expect.element(screen.getByText('2 of 3')).toBeInTheDocument();
    });
  });

  describe('accessibility', () => {
    // A stepper looks like tabs and is not one: the panels are ordered and the
    // reader is expected to arrive at them in that order.
    it('marks the current row as the current step', async () => {
      const screen = await render(<HowToSteps steps={STEPS} data-testid="guide" />);
      const current = rows(screen.getByTestId('guide').element())[0].querySelector('button');

      expect(current).toHaveAttribute('aria-current', 'step');
    });

    it('moves that mark with the step', async () => {
      const screen = await render(<HowToSteps steps={STEPS} data-testid="guide" />);

      await screen.getByRole('button', { name: 'Next' }).click();

      await expect
        .poll(() =>
          rows(screen.getByTestId('guide').element())[1]
            .querySelector('button')
            ?.getAttribute('aria-current')
        )
        .toBe('step');
    });

    it('names the list', async () => {
      const screen = await render(<HowToSteps steps={STEPS} />);

      await expect.element(screen.getByRole('list', { name: 'Steps' })).toBeInTheDocument();
    });

    it('says its own words in the locale it was given', async () => {
      const screen = await render(<HowToSteps steps={STEPS} locale="ko" />);

      await expect.element(screen.getByRole('button', { name: '다음' })).toBeInTheDocument();
    });

    it('takes labels written out over the locale', async () => {
      const screen = await render(
        <HowToSteps steps={STEPS} nextLabel="Onward" previousLabel="Back" />
      );

      await expect.element(screen.getByRole('button', { name: 'Onward' })).toBeInTheDocument();
      await expect.element(screen.getByRole('button', { name: 'Back' })).toBeInTheDocument();
    });
  });
});
