import { useState, type ReactNode } from 'react';
import { Box, Button, Card, TextField } from 'neba';

/**
 * One sample screen rather than a grid of specimens: every component in the
 * library appears once, doing the job it exists for, on a page that could
 * plausibly ship. The acrylic only means anything over real content, so the
 * parts are arranged as a product screen would arrange them.
 *
 * The copy stays in English in both locales — it is a sample application, and
 * the prose explaining it lives in the Markdown around the preview.
 */

function PlusIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
    </svg>
  );
}

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <circle cx="7" cy="7" r="4.25" stroke="currentColor" strokeWidth="1.5" />
      <path d="m10.5 10.5 3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

const STATS = [
  { label: 'Deploys', value: '128', color: 'primary' as const },
  { label: 'Review apps', value: '9', color: 'info' as const },
  { label: 'Failing', value: '2', color: 'danger' as const }
];

function Caption({ children }: { children: ReactNode }) {
  return (
    <div className="text-[0.6875rem] tracking-wide text-[var(--neba-muted-fg)] uppercase">
      {children}
    </div>
  );
}

export default function Showcase() {
  const [name, setName] = useState('Jane Doe');
  const [email, setEmail] = useState('jane@example.com');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const emailValid = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);

  const save = () => {
    if (!emailValid) {
      return;
    }
    setSaving(true);
    setSaved(false);
    setTimeout(() => {
      setSaving(false);
      setSaved(true);
    }, 900);
  };

  return (
    <div className="flex flex-col gap-8">
      {/* Toolbar — Button in every weight it comes in. */}
      <section className="flex flex-col gap-3">
        <Caption>Button · TextField</Caption>
        <div className="flex flex-wrap items-center gap-2">
          <TextField size="sm" startIcon={<SearchIcon />} placeholder="Search projects" />
          <Button size="sm" variant="text" color="secondary">
            Filter
          </Button>
          <div className="grow" />
          <Button size="sm" variant="outline" color="secondary">
            Import
          </Button>
          <Button size="sm" startIcon={<PlusIcon />}>
            New project
          </Button>
        </div>
      </section>

      {/* Boxes as the plainest surface there is: they group, and nothing else. */}
      <section className="flex flex-col gap-3">
        <Caption>Box</Caption>
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
          {STATS.map((stat) => (
            <Box key={stat.label} variant="solid" color={stat.color}>
              <div className="text-[1.5rem] leading-none font-semibold">{stat.value}</div>
              <div className="mt-1 text-[0.75rem] text-[var(--neba-muted-fg)]">{stat.label}</div>
            </Box>
          ))}
        </div>
      </section>

      {/* A card holding controls — the composition the library is actually for. */}
      <section className="flex flex-col gap-3">
        <Caption>Card · TextField · Button</Caption>
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-[1.4fr_1fr]">
          <Card
            dividers
            title={<h3>Profile</h3>}
            subtitle="Shown on your public profile."
            footer={
              <>
                <Button variant="text" color="secondary">
                  Revert
                </Button>
                <Button className="ml-auto" loading={saving} onClick={save}>
                  {saved ? 'Saved' : 'Save changes'}
                </Button>
              </>
            }
          >
            <div className="flex flex-col gap-3">
              <TextField
                label="Name"
                value={name}
                onChange={(event) => setName(event.target.value)}
                fullWidth
              />
              <TextField
                label="Email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                error={emailValid ? undefined : 'Enter a valid address.'}
                fullWidth
              />
              <TextField
                multiline
                rows={3}
                label="About"
                placeholder="A sentence or two."
                description="Markdown is not supported."
                fullWidth
              />
            </div>
          </Card>

          <div className="flex flex-col gap-4">
            <Card
              variant="solid"
              color="secondary"
              title="Team"
              subtitle="Up to twelve seats"
              headerAction={
                <Button size="xs" variant="outline" color="secondary">
                  Current plan
                </Button>
              }
              footer={
                <Button size="sm" fullWidth variant="outline" color="secondary">
                  Change plan
                </Button>
              }
            >
              Shared environments, review apps and a seat for everyone.
            </Card>

            <Card
              color="danger"
              size="sm"
              title="Danger zone"
              footer={
                <Button size="sm" color="danger" variant="outline">
                  Delete workspace
                </Button>
              }
            >
              This cannot be undone.
            </Card>
          </div>
        </div>
      </section>

      {/* A box grouping cards: the box groups, the cards structure. */}
      <section className="flex flex-col gap-3">
        <Caption>Box + Card</Caption>
        <Box variant="text" padded={false}>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
            {(['primary', 'success', 'info'] as const).map((color) => (
              <Card key={color} size="sm" color={color} title={color} subtitle="A card in a box">
                Grouped by the box around them.
              </Card>
            ))}
          </div>
        </Box>
      </section>
    </div>
  );
}
