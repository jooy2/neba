import { useState, type ReactNode } from 'react';
import { Button } from '@/dist';
import type { NebaColor, NebaElevation, NebaSize, NebaVariant } from '@/dist';

const VARIANTS: NebaVariant[] = ['solid', 'outline', 'text'];
const ELEVATIONS: NebaElevation[] = [0, 1, 2, 3];
const COLORS: NebaColor[] = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'];
const SIZES: NebaSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function ChevronIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="m6 4 4 4-4 4"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function Section({ title, note, children }: { title: string; note?: string; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-3">
      <div className="flex items-baseline gap-3">
        <h2 className="text-[0.8125rem] font-semibold tracking-wide uppercase">{title}</h2>
        {note ? <p className="text-[0.75rem] text-[var(--neba-muted-fg)]">{note}</p> : null}
      </div>
      <div className="flex flex-col gap-3">{children}</div>
    </section>
  );
}

function Row({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="w-20 shrink-0 text-[0.75rem] text-[var(--neba-muted-fg)]">{label}</span>
      {children}
    </div>
  );
}

export default function App() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [clicks, setClicks] = useState(0);

  const toggleTheme = () => {
    const next = theme === 'light' ? 'dark' : 'light';
    setTheme(next);
    document.documentElement.dataset.theme = next;
  };

  return (
    // Counted by delegation rather than an `onClick` on every button on the
    // page, which is also the honest way to see that disabled, loading and
    // read-only buttons stop the event before it gets here.
    <main
      className="mx-auto flex max-w-4xl flex-col gap-10 px-6 py-10"
      onClick={(event) => {
        if ((event.target as HTMLElement).closest('button')) {
          setClicks((n) => n + 1);
        }
      }}
    >
      <header className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-semibold">Neba — Button</h1>
          <p className="text-[0.8125rem] text-[var(--neba-muted-fg)]">
            Clicked {clicks} {clicks === 1 ? 'time' : 'times'}
          </p>
        </div>
        <Button variant="outline" color="secondary" size="sm" onClick={toggleTheme}>
          {theme === 'light' ? 'Dark' : 'Light'} mode
        </Button>
      </header>

      <Section title="Variants" note="solid / outline / text">
        {VARIANTS.map((variant) => (
          <Row key={variant} label={variant}>
            {COLORS.map((color) => (
              <Button key={color} variant={variant} color={color}>
                {color}
              </Button>
            ))}
          </Row>
        ))}
      </Section>

      <Section title="Sizes" note="xs 22px · sm 26px · md 32px · lg 40px · xl 48px">
        {VARIANTS.map((variant) => (
          <Row key={variant} label={variant}>
            {SIZES.map((size) => (
              <Button key={size} variant={variant} size={size}>
                Button {size}
              </Button>
            ))}
          </Row>
        ))}
      </Section>

      <Section title="Density" note="horizontal padding only — heights stay aligned">
        <Row label="default">
          {SIZES.map((size) => (
            <Button key={size} size={size} density="default" color="secondary" variant="outline">
              Save changes
            </Button>
          ))}
        </Row>
        <Row label="compact">
          {SIZES.map((size) => (
            <Button key={size} size={size} density="compact" color="secondary" variant="outline">
              Save changes
            </Button>
          ))}
        </Row>
      </Section>

      <Section title="Elevation" note="0 is the default — hover adds a level, press removes one">
        {VARIANTS.map((variant) => (
          <Row key={variant} label={variant}>
            {ELEVATIONS.map((elevation) => (
              <Button key={elevation} variant={variant} elevation={elevation} size="lg">
                elevation {elevation}
              </Button>
            ))}
          </Row>
        ))}
      </Section>

      <Section title="Icons">
        <Row label="start">
          {VARIANTS.map((variant) => (
            <Button key={variant} variant={variant} startIcon={<PlusIcon />}>
              New project
            </Button>
          ))}
        </Row>
        <Row label="end">
          {VARIANTS.map((variant) => (
            <Button key={variant} variant={variant} endIcon={<ChevronIcon />}>
              Continue
            </Button>
          ))}
        </Row>
        <Row label="icon only">
          {SIZES.map((size) => (
            <Button
              key={size}
              size={size}
              variant="outline"
              aria-label="Add"
              startIcon={<PlusIcon />}
            />
          ))}
        </Row>
      </Section>

      <Section title="States" note="normal / loading / disabled / read-only">
        {VARIANTS.map((variant) => (
          <Row key={variant} label={variant}>
            <Button variant={variant}>Normal</Button>
            <Button variant={variant} loading>
              Loading
            </Button>
            <Button variant={variant} disabled>
              Disabled
            </Button>
            <Button variant={variant} readOnly>
              Read-only
            </Button>
          </Row>
        ))}
      </Section>

      <Section title="Full width">
        <Button fullWidth size="lg" startIcon={<PlusIcon />}>
          Create workspace
        </Button>
      </Section>
    </main>
  );
}
