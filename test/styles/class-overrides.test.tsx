/**
 * A caller's utility against a component's own default, measured with the
 * stylesheet on.
 *
 * Typography and TextLink write their defaults at two-class strength so that a
 * host's `.prose h2` or `.vp-doc a` cannot reach them. A caller's utility is one
 * class, so for a property the caller sets, the component states its default at
 * zero specificity instead. A heading handed to a sheet as its `title` is the
 * same trade drawn per element: guarded with no class, the caller's with one.
 * The classes that decide it are tested with each component; whether they
 * decide it the right way is only visible here.
 *
 * The host rules below stand in for VitePress's: unlayered, one class plus one
 * tag, and setting everything the scale sets.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import { Card, TextLink, Typography } from 'neba';
import overridesCss from './class-overrides.css?inline';

const HOST = `
  .prose h1, .prose h2, .prose p {
    margin: 3rem 0;
    font-size: 3rem;
    line-height: 1;
    letter-spacing: 0.2em;
    font-weight: 800;
  }
  .prose a {
    color: rgb(0, 0, 255);
    font-weight: 700;
    text-decoration-line: none;
    text-decoration-thickness: 4px;
    text-decoration-color: rgb(0, 0, 255);
    text-underline-offset: 8px;
  }
`;

const sheets: HTMLStyleElement[] = [];
let viewport: [number, number];

beforeAll(() => {
  viewport = [window.innerWidth, window.innerHeight];

  for (const text of [overridesCss, HOST]) {
    const sheet = document.createElement('style');

    sheet.textContent = text;
    document.head.append(sheet);
    sheets.push(sheet);
  }
});

afterAll(async () => {
  for (const sheet of sheets) {
    sheet.remove();
  }

  await page.viewport(...viewport);
});

/** The computed style of the first element that has `text`. */
async function styleOf(screen: Awaited<ReturnType<typeof render>>, text: string) {
  const locator = screen.getByText(text);

  await expect.element(locator).toBeInTheDocument();

  return getComputedStyle(locator.element());
}

describe('Typography', () => {
  it('keeps its own scale and no margins inside an article that styles its tags', async () => {
    const screen = await render(
      <div className="prose">
        <Typography level="h2">Heading</Typography>
        <Typography>Body</Typography>
      </div>
    );
    const heading = await styleOf(screen, 'Heading');
    const body = await styleOf(screen, 'Body');

    expect(heading.fontSize).toBe('24px');
    expect(heading.lineHeight).toBe('30px');
    expect(heading.letterSpacing).toBe('-0.36px');
    expect(heading.fontWeight).toBe('600');
    expect(heading.marginTop).toBe('0px');
    expect(heading.marginBottom).toBe('0px');
    expect(body.fontSize).toBe('13px');
    expect(body.marginBottom).toBe('0px');
  });

  it('takes a margin from className', async () => {
    const screen = await render(<Typography className="mb-8">Body</Typography>);
    const body = await styleOf(screen, 'Body');

    expect(body.marginBottom).toBe('32px');
    expect(body.marginTop).toBe('0px');
  });

  it('takes a size, a leading, a weight and a tracking from className', async () => {
    const screen = await render(
      <Typography level="h2" className="text-[2.5rem] leading-none font-black tracking-tight">
        42
      </Typography>
    );
    const figure = await styleOf(screen, '42');

    expect(figure.fontSize).toBe('40px');
    expect(figure.lineHeight).toBe('40px');
    expect(figure.fontWeight).toBe('900');
    expect(figure.letterSpacing).toBe('-1px');
  });

  // The leading is a ratio, so a size on its own keeps a line box in
  // proportion to it rather than the one drawn for the level's own size.
  it('keeps the level ratio under a size that sets no leading', async () => {
    const screen = await render(
      <Typography level="h2" className="text-[2.5rem]">
        42
      </Typography>
    );

    expect((await styleOf(screen, '42')).lineHeight).toBe('50px');
  });

  it('takes a colour over the muted ink and over a colour role', async () => {
    const screen = await render(
      <>
        <span className="text-red-600">Reference</span>
        <Typography level="caption" className="text-red-600">
          Caption
        </Typography>
        <Typography color="primary" className="text-red-600">
          Accent
        </Typography>
      </>
    );
    const red = (await styleOf(screen, 'Reference')).color;

    expect((await styleOf(screen, 'Caption')).color).toBe(red);
    expect((await styleOf(screen, 'Accent')).color).toBe(red);
  });

  it('gives an important class the result it always had', async () => {
    const screen = await render(<Typography className="mb-8!">Body</Typography>);

    expect((await styleOf(screen, 'Body')).marginBottom).toBe('32px');
  });

  it('keeps the level size below the breakpoint of a class behind one', async () => {
    const screen = await render(
      <Typography level="h1" className="md:text-5xl">
        Title
      </Typography>
    );

    await page.viewport(400, 800);
    expect((await styleOf(screen, 'Title')).fontSize).toBe('30px');

    await page.viewport(1024, 800);
    expect((await styleOf(screen, 'Title')).fontSize).toBe('48px');
  });

  // Only the property the caller set leaves the guard.
  it('keeps the guard on everything a class does not set', async () => {
    const screen = await render(
      <div className="prose">
        <Typography level="h2" className="mb-8">
          Heading
        </Typography>
      </div>
    );
    const heading = await styleOf(screen, 'Heading');

    expect(heading.fontSize).toBe('24px');
    expect(heading.fontWeight).toBe('600');
    expect(heading.marginTop).toBe('0px');
  });
});

describe('TextLink', () => {
  it('keeps its line and its inherited colour inside an article that restyles links', async () => {
    const screen = await render(
      <div className="prose" style={{ color: 'rgb(10, 20, 30)' }}>
        <TextLink href="/docs">Docs</TextLink>
      </div>
    );
    const link = await styleOf(screen, 'Docs');

    expect(link.textDecorationLine).toBe('underline');
    expect(link.color).toBe('rgb(10, 20, 30)');
  });

  it('keeps its weight and the shape of its line inside that article', async () => {
    const screen = await render(
      <div className="prose" style={{ fontSize: '20px', fontWeight: 400 }}>
        <TextLink href="/docs">Docs</TextLink>
      </div>
    );
    const link = await styleOf(screen, 'Docs');

    expect(link.fontWeight).toBe('400');
    expect(link.textUnderlineOffset).toBe('4px');
    expect(link.textDecorationThickness).toBe('1.1px');
    expect(link.textDecorationColor).not.toBe('rgb(0, 0, 255)');
  });

  it('takes a weight and the shape of its line from className', async () => {
    const screen = await render(
      <>
        <span className="decoration-red-600">Reference</span>
        <TextLink
          href="/docs"
          className="font-semibold decoration-2 underline-offset-4 decoration-red-600"
        >
          Docs
        </TextLink>
      </>
    );
    const link = await styleOf(screen, 'Docs');

    expect(link.fontWeight).toBe('600');
    expect(link.textDecorationThickness).toBe('2px');
    expect(link.textUnderlineOffset).toBe('4px');
    expect(link.textDecorationColor).toBe((await styleOf(screen, 'Reference')).textDecorationColor);
  });

  it('takes a colour and a line from className', async () => {
    const screen = await render(
      <>
        <span className="text-red-600">Reference</span>
        <TextLink href="/docs" className="text-red-600 no-underline">
          Docs
        </TextLink>
      </>
    );
    const link = await styleOf(screen, 'Docs');

    expect(link.textDecorationLine).toBe('none');
    expect(link.color).toBe((await styleOf(screen, 'Reference')).color);
  });
});

describe('a heading passed as a sheet title', () => {
  it('takes the sheet scale inside an article that styles its tag', async () => {
    const screen = await render(
      <div className="prose">
        <Card title={<h2>Invoice</h2>} />
      </div>
    );
    const heading = await styleOf(screen, 'Invoice');

    expect(heading.fontSize).toBe('15px');
    expect(heading.fontWeight).toBe('600');
    expect(heading.marginTop).toBe('0px');
    expect(heading.marginBottom).toBe('0px');
  });

  it('takes its own classes over the sheet scale', async () => {
    const screen = await render(<Card title={<h2 className="mb-2 text-xl">Invoice</h2>} />);
    const heading = await styleOf(screen, 'Invoice');

    expect(heading.fontSize).toBe('20px');
    expect(heading.marginBottom).toBe('8px');
    // What the classes do not say is still the sheet's.
    expect(heading.fontWeight).toBe('600');
  });
});
