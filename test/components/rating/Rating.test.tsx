import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { Rating } from 'neba';
import { ko, registerMessages } from 'neba/locales';

/* The library ships English; a `locale` prop answers for a language the
   project has registered. These assertions are about the prop, so the
   languages they name are registered here the way a consumer would. */
registerMessages('ko', ko);

describe('Rating', () => {
  describe('rendering', () => {
    it('renders a radio group with one radio per star', async () => {
      const screen = await render(<Rating />);

      await expect.element(screen.getByRole('radiogroup')).toBeInTheDocument();
      expect(screen.getByRole('radio').elements()).toHaveLength(5);
    });

    it('renders as many stars as it was asked for', async () => {
      const screen = await render(<Rating count={3} />);

      expect(screen.getByRole('radio').elements()).toHaveLength(3);
    });

    it('renders two radios per star at half precision', async () => {
      const screen = await render(<Rating count={3} precision={0.5} />);

      expect(screen.getByRole('radio').elements()).toHaveLength(6);
    });

    it('names the group, and every star in it', async () => {
      const screen = await render(<Rating count={5} />);

      await expect.element(screen.getByRole('radiogroup', { name: 'Rating' })).toBeInTheDocument();
      await expect.element(screen.getByRole('radio', { name: '3 out of 5' })).toBeInTheDocument();
    });

    it('takes its words from the locale', async () => {
      const screen = await render(<Rating locale="ko" />);

      await expect.element(screen.getByRole('radiogroup', { name: '별점' })).toBeInTheDocument();
      await expect
        .element(screen.getByRole('radio', { name: '5점 만점에 3점' }))
        .toBeInTheDocument();
    });

    it('lets the caller write the names itself', async () => {
      const screen = await render(
        <Rating label="How was it?" valueLabel={(value, count) => `${value}/${count} stars`} />
      );

      await expect
        .element(screen.getByRole('radiogroup', { name: 'How was it?' }))
        .toBeInTheDocument();
      await expect.element(screen.getByRole('radio', { name: '4/5 stars' })).toBeInTheDocument();
    });

    it('keeps caller-supplied class names alongside its own', async () => {
      const screen = await render(<Rating className="my-own-class" data-testid="rating" />);

      expect(screen.getByTestId('rating').element()).toHaveClass('my-own-class');
    });

    it('forwards unknown props to the root', async () => {
      const screen = await render(<Rating data-testid="rating" id="score" />);

      expect(screen.getByTestId('rating').element()).toHaveAttribute('id', 'score');
    });
  });

  describe('choosing', () => {
    it('checks the radio for the value it was given', async () => {
      const screen = await render(<Rating value={3} />);

      await expect.element(screen.getByRole('radio', { name: '3 out of 5' })).toBeChecked();
    });

    it('reports the score that was chosen', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Rating onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: '4 out of 5' }).click();

      expect(onValueChange).toHaveBeenCalledWith(4);
    });

    it('reports a half star at half precision', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Rating precision={0.5} onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: '2.5 out of 5' }).click();

      expect(onValueChange).toHaveBeenCalledWith(2.5);
    });

    it('keeps the score in an uncontrolled Rating', async () => {
      const screen = await render(<Rating defaultValue={1} />);

      await screen.getByRole('radio', { name: '4 out of 5' }).click();

      await expect.element(screen.getByRole('radio', { name: '4 out of 5' })).toBeChecked();
    });

    it('leaves a controlled Rating where it was put', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Rating value={2} onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: '4 out of 5' }).click();

      expect(onValueChange).toHaveBeenCalledWith(4);
      await expect.element(screen.getByRole('radio', { name: '2 out of 5' })).toBeChecked();
    });

    it('clears the score when the chosen star is chosen again', async () => {
      const onValueChange = vi.fn();
      const screen = await render(<Rating defaultValue={3} onValueChange={onValueChange} />);

      await screen.getByRole('radio', { name: '3 out of 5' }).click();

      expect(onValueChange).toHaveBeenCalledWith(0);
    });

    it('does not clear it when it was told not to', async () => {
      const onValueChange = vi.fn();
      const screen = await render(
        <Rating defaultValue={3} clearable={false} onValueChange={onValueChange} />
      );

      await screen.getByRole('radio', { name: '3 out of 5' }).click();

      expect(onValueChange).not.toHaveBeenCalled();
    });

    it('stops answering when it is disabled', async () => {
      const screen = await render(<Rating disabled />);

      await expect.element(screen.getByRole('radio', { name: '3 out of 5' })).toBeDisabled();
    });

    it('carries the name a form submits it under', async () => {
      const screen = await render(<Rating name="score" value={2} />);

      expect(screen.getByRole('radio', { name: '2 out of 5' }).element()).toHaveAttribute(
        'name',
        'score'
      );
    });
  });

  describe('read only', () => {
    it('becomes a picture with no radios in it', async () => {
      const screen = await render(<Rating value={4} readOnly />);

      expect(screen.getByRole('radio').elements()).toHaveLength(0);
      await expect.element(screen.getByRole('img', { name: '4 out of 5' })).toBeInTheDocument();
    });

    it('says so when nothing has been rated', async () => {
      const screen = await render(<Rating value={0} readOnly />);

      await expect.element(screen.getByRole('img', { name: 'No rating' })).toBeInTheDocument();
    });

    it('draws a fraction of a star for an average', async () => {
      const screen = await render(<Rating value={4.3} readOnly data-testid="rating" />);

      const fills = screen
        .getByTestId('rating')
        .element()
        .querySelectorAll<HTMLElement>('span[aria-hidden="true"]');

      // Four whole stars and the last one filled to a third of its width.
      expect(parseFloat(fills[3].style.width)).toBeCloseTo(100);
      expect(parseFloat(fills[4].style.width)).toBeCloseTo(30);
    });
  });

  describe('the fill', () => {
    /**
     * The one thing on the control that says how far the reader has got, and it
     * used to jump from one star to the next. It travels on `width` — the same
     * width on the same element — so no glyph is ever scaled to say it.
     */
    it('travels rather than jumping', async () => {
      const screen = await render(<Rating value={3} readOnly data-testid="rating" />);

      const fill = screen
        .getByTestId('rating')
        .element()
        .querySelector('span[aria-hidden="true"]') as HTMLElement;

      expect(fill.className).toContain('transition:width');
      expect(fill.className).not.toContain('scale');
    });
  });
});
