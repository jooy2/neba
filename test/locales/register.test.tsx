/**
 * `neba/locales` — the languages, and the call that turns one on.
 *
 * The library ships English and nothing else, because eighteen languages behind
 * an `import { Chip }` is eighteen languages in the bundle of a product that
 * speaks one. What a `locale` prop does therefore depends on what the project
 * has registered, and that is a contract worth pinning: the fallback when a tag
 * is unknown, the tag matching when it is known by a broader name, and the fact
 * that registering after something has already read a string still takes.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { Chip, Empty, Rating, Spoiler } from 'neba';
import { ko, registerMessages } from 'neba/locales';

describe('neba/locales', () => {
  describe('before a language is registered', () => {
    it('answers an unknown tag in English', async () => {
      // `qps` is a reserved tag no locale module claims, so this stays true
      // however many languages the folder grows.
      const screen = await render(<Empty locale="qps" />);

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });

    /*
     * The tag reaches the message tables as a key, so a name off `Object`'s
     * prototype used to come back truthy and be spread over English as though it
     * were a table of messages. A caller can hand a `locale` straight out of a
     * URL, and the answer for a tag nobody registered is English either way.
     */
    it('answers a tag named after a prototype member in English', async () => {
      const screen = await render(<Empty locale="constructor" />);

      await expect.element(screen.getByText('Nothing here')).toBeInTheDocument();
    });
  });

  describe('once it is', () => {
    it('translates the strings the component invents', async () => {
      registerMessages('ko', ko);

      const screen = await render(<Empty locale="ko" />);

      await expect.element(screen.getByText('내용이 없습니다')).toBeInTheDocument();
    });

    it('answers a region under the language it was registered as', async () => {
      registerMessages('ko', ko);

      const screen = await render(<Empty locale="ko-KR" />);

      await expect.element(screen.getByText('내용이 없습니다')).toBeInTheDocument();
    });

    it('takes effect for a tag something has already resolved', async () => {
      // The resolution is cached per table per tag. A language registered after
      // a first render has to invalidate what that render cached, or the second
      // render answers from the stale copy.
      const before = await render(<Spoiler locale="qpsPloc">hidden</Spoiler>);

      await expect.element(before.getByText('This may contain spoilers')).toBeInTheDocument();

      registerMessages('qpsPloc', { spoiler: { notice: 'Ⓢⓟⓞⓘⓛⓔⓡⓢ' } });

      const after = await render(<Spoiler locale="qpsPloc">hidden</Spoiler>);

      await expect.element(after.getByText('Ⓢⓟⓞⓘⓛⓔⓡⓢ')).toBeInTheDocument();
    });

    it('falls back to English for a string the language does not carry', async () => {
      registerMessages('qpsLatn', { spoiler: { reveal: 'Ⓡⓔⓥⓔⓐⓛ' } });

      const screen = await render(<Spoiler locale="qpsLatn">hidden</Spoiler>);

      // The one string that was supplied…
      await expect.element(screen.getByText('Ⓡⓔⓥⓔⓐⓛ')).toBeInTheDocument();
      // …and one from the same namespace that was not.
      await expect.element(screen.getByText('This may contain spoilers')).toBeInTheDocument();
    });

    it('leaves the namespaces it was not given alone', async () => {
      registerMessages('qpsDeva', { spoiler: { reveal: 'x' } });

      const screen = await render(
        <Chip locale="qpsDeva" onDelete={() => {}}>
          Draft
        </Chip>
      );

      await expect.element(screen.getByRole('button', { name: 'Remove' })).toBeInTheDocument();
    });
  });

  describe('a placeholder', () => {
    /*
     * The names come out of the template, and a template is a *translation* —
     * so a name that happens to match a member of `Object`'s prototype must not
     * resolve to one. Left alone, `{constructor}` wrote
     * `function Object() { [native code] }` into the middle of the sentence.
     */
    it('is left as itself when the values do not carry it', async () => {
      registerMessages('qpsFill', { rating: { value: '{constructor} of {max}' } });

      const screen = await render(<Rating locale="qpsFill" value={3} readOnly />);

      await expect
        .element(screen.getByRole('img', { name: '{constructor} of 5' }))
        .toBeInTheDocument();
    });
  });

  describe('the folder', () => {
    it('exports one module per language, each its own entry point', async () => {
      // Reached through the barrel here; `neba/locales/ko` is the same module.
      const { ko: viaBarrel } = await import('neba/locales');

      expect(viaBarrel.action?.remove).toBe('삭제');
    });
  });
});
