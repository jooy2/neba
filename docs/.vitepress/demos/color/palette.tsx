import { useEffect, useRef, useState } from 'react';
import { DEFAULT_LOCALE, type Locale } from '../../data/i18n';

/**
 * Every token of every colour family, with the value the browser actually
 * resolved it to.
 *
 * Unlike the other demos this one is documentation rather than a code sample,
 * so it takes the locale `Demo.vue` passes in and localises its own copy.
 *
 * The values are read back from the DOM rather than duplicated here. Half the
 * tokens are `color-mix()` expressions, so the declared value says nothing
 * useful — and a hardcoded table is a table that goes stale the first time
 * `styles.css` is touched. Reading the computed value means this page cannot
 * disagree with the stylesheet.
 */

const FAMILIES = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

interface TokenRow {
  /** Suffix after `--neba-{family}-`. */
  key: string;
  /** Hand-picked in `styles.css`, rather than derived with `color-mix()`. */
  hand?: boolean;
  note: Record<Locale, string>;
}

const TOKENS: TokenRow[] = [
  {
    key: 'solid',
    hand: true,
    note: { ko: '채움 기준색', en: "The fill's base colour" }
  },
  {
    key: 'solid-hover',
    hand: true,
    note: { ko: '−4.5 명도', en: '−4.5 lightness' }
  },
  {
    key: 'solid-active',
    hand: true,
    note: { ko: '−12 명도', en: '−12 lightness' }
  },
  {
    key: 'on-solid',
    hand: true,
    note: { ko: '채움 위 글자색', en: 'Text on the fill' }
  },
  {
    key: 'accent',
    hand: true,
    note: { ko: '표면 위에서 읽히는 색', en: 'Readable on a surface' }
  },
  {
    key: 'fill',
    note: { ko: 'solid을 88% 불투명하게', en: 'solid at 88% opacity' }
  },
  {
    key: 'panel',
    note: { ko: 'outline 컨트롤의 표면', en: "An outline control's surface" }
  },
  {
    key: 'soft',
    note: { ko: 'text 변형의 hover 워시', en: "The text variant's hover wash" }
  },
  {
    key: 'line',
    note: { ko: '하이라인', en: 'The hairline' }
  },
  {
    key: 'ring',
    note: { ko: '포커스 링', en: 'The focus ring' }
  }
];

const COPY = {
  hand: { ko: '직접 지정', en: 'hand-set' },
  derived: { ko: '파생', en: 'derived' }
} satisfies Record<string, Record<Locale, string>>;

/**
 * The resolved value as a hex string.
 *
 * A computed custom property comes back in whatever syntax the browser settled
 * on — `oklch(…)` for an opaque family colour, `color(srgb … / …)` for a
 * `color-mix()`. Painting one pixel with it and reading the pixel back is the
 * one conversion that works for all of them without a colour library, and it is
 * the browser's own answer rather than a reimplementation of it.
 */
function toHex(value: string, canvas: HTMLCanvasElement | null): string {
  if (!canvas) {
    return value;
  }

  const context = canvas.getContext('2d', { willReadFrequently: true });

  if (!context) {
    return value;
  }

  context.clearRect(0, 0, 1, 1);
  context.fillStyle = '#000';
  context.fillStyle = value;

  // An unparseable value leaves `fillStyle` at the black we just set, which
  // would render as a plausible-looking lie. Bail out to the raw string.
  if (context.fillStyle === '#000000' && !/^#0{3,8}$/i.test(value.trim())) {
    return value;
  }

  context.fillRect(0, 0, 1, 1);

  const [r, g, b, a] = context.getImageData(0, 0, 1, 1).data;
  const pair = (n: number) => n.toString(16).padStart(2, '0');
  const rgb = `#${pair(r)}${pair(g)}${pair(b)}`;

  return a === 255 ? rgb : `${rgb}${pair(a)}`;
}

/** One swatch, plus the value it resolved to. */
function Swatch({ token, value }: { token: string; value: string }) {
  return (
    <div
      className="size-7 shrink-0 rounded-md border border-[var(--vp-c-divider)]"
      style={{ background: `var(--neba-${token})` }}
      title={value}
    />
  );
}

export default function ColorPalette({ locale = DEFAULT_LOCALE }: { locale?: Locale }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const rootRef = useRef<HTMLDivElement>(null);
  const [values, setValues] = useState<Record<string, string>>({});

  useEffect(() => {
    const read = () => {
      const root = rootRef.current;

      if (!root) {
        return;
      }

      const style = getComputedStyle(root);
      const next: Record<string, string> = {};

      for (const family of FAMILIES) {
        for (const { key } of TOKENS) {
          const token = `${family}-${key}`;
          // The declared value of a derived token is the `color-mix()` itself,
          // so it has to be resolved on a real element before it means anything.
          const declared = style.getPropertyValue(`--neba-${token}`).trim();
          next[token] = toHex(declared, canvasRef.current);
        }
      }

      setValues(next);
    };

    read();

    // VitePress toggles `.dark` on `<html>`, and every one of these tokens
    // answers to it. Without this the table would keep the light values after
    // the reader flips the theme.
    const observer = new MutationObserver(read);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });

    return () => observer.disconnect();
  }, []);

  return (
    <div ref={rootRef} className="flex w-full flex-col gap-4">
      <canvas ref={canvasRef} width={1} height={1} className="hidden" />

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {FAMILIES.map((family) => (
          <section
            key={family}
            className="overflow-hidden rounded-xl border border-[var(--vp-c-divider)]"
          >
            <header
              className="flex items-baseline justify-between px-4 py-3"
              style={{
                background: `var(--neba-${family}-solid)`,
                color: `var(--neba-${family}-on-solid)`
              }}
            >
              <span className="text-[0.875rem] font-semibold">{family}</span>
              <span className="font-mono text-[0.6875rem] opacity-80">
                {values[`${family}-solid`]}
              </span>
            </header>

            <div className="flex flex-col divide-y divide-[var(--vp-c-divider)]">
              {TOKENS.map(({ key, hand, note }) => (
                <div key={key} className="flex items-center gap-3 px-3 py-2">
                  <Swatch token={`${family}-${key}`} value={values[`${family}-${key}`] ?? ''} />

                  <div className="flex min-w-0 flex-1 flex-col">
                    <code className="truncate font-mono text-[0.6875rem] text-[var(--vp-c-text-1)]">
                      --neba-{family}-{key}
                    </code>
                    <span className="truncate text-[0.6875rem] text-[var(--vp-c-text-3)]">
                      {note[locale]}
                    </span>
                  </div>

                  <div className="flex shrink-0 flex-col items-end gap-0.5">
                    <span className="font-mono text-[0.6875rem] text-[var(--vp-c-text-2)]">
                      {values[`${family}-${key}`]}
                    </span>
                    <span className="text-[0.625rem] text-[var(--vp-c-text-3)]">
                      {hand ? COPY.hand[locale] : COPY.derived[locale]}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}
