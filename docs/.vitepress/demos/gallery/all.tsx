import type { ReactNode } from 'react';
import { Box, Button, Card, TextField } from 'neba';
import { DEFAULT_LOCALE, type Locale } from '../../data/i18n';

/**
 * The component index: one card per component, each holding a live instance of
 * the thing it links to. Chrome is drawn with VitePress's own palette variables
 * so the grid belongs to the docs, while what sits inside every card is the
 * real component on the real acrylic surface.
 *
 * Unlike the other demos this one is documentation rather than a code sample,
 * so it takes the locale `Demo.vue` passes in and localises its own copy.
 */

type Text = Record<Locale, string>;

interface Entry {
  name: string;
  summary: Text;
  /** Appended to the locale's base path. */
  path: string;
  preview: ReactNode;
}

interface Group {
  title: string;
  note: Text;
  entries: Entry[];
}

const GROUPS: Group[] = [
  {
    title: 'Inputs',
    note: {
      ko: '사용자가 값을 넣거나 액션을 실행하는 컨트롤',
      en: 'Controls that take a value or run an action'
    },
    entries: [
      {
        name: 'Button',
        summary: { ko: '액션을 실행하는 컨트롤', en: 'Runs an action' },
        path: '/components/inputs/button',
        preview: (
          <div className="flex flex-wrap items-center justify-center gap-2">
            <Button size="sm">Save</Button>
            <Button size="sm" variant="outline">
              Cancel
            </Button>
            <Button size="sm" variant="text">
              Details
            </Button>
          </div>
        )
      },
      {
        name: 'TextField',
        summary: {
          ko: '한 줄 또는 여러 줄 텍스트 입력',
          en: 'Single- or multi-line text input'
        },
        path: '/components/inputs/text-field',
        preview: (
          <div className="w-full max-w-52">
            <TextField size="sm" label="Email" placeholder="jane@example.com" fullWidth />
          </div>
        )
      }
    ]
  },
  {
    title: 'Surfaces',
    note: {
      ko: '다른 것을 담아 두는 아크릴 시트',
      en: 'Sheets of acrylic that hold everything else'
    },
    entries: [
      {
        name: 'Box',
        summary: {
          ko: '가장 단순한 표면. 묶는 일만 합니다',
          en: 'The plainest surface — it groups, and that is all'
        },
        path: '/components/surfaces/box',
        preview: (
          <div className="flex w-full max-w-56 flex-col gap-2">
            <Box size="sm">outline</Box>
            <Box size="sm" variant="solid" color="info">
              solid
            </Box>
          </div>
        )
      },
      {
        name: 'Card',
        summary: {
          ko: '제목·본문·푸터가 놓인 Box',
          en: 'A Box with a title, a body and a footer on it'
        },
        path: '/components/surfaces/card',
        preview: (
          <div className="w-full max-w-56">
            <Card
              size="sm"
              title="Starter"
              subtitle="One project"
              footer={<Button size="xs">Choose</Button>}
            >
              Ready for real users.
            </Card>
          </div>
        )
      }
    ]
  }
];

function EntryCard({ entry, locale, base }: { entry: Entry; locale: Locale; base: string }) {
  return (
    <a
      href={`${base}${entry.path}`}
      className="flex flex-col overflow-hidden rounded-xl border border-[var(--vp-c-divider)] transition-colors hover:border-[var(--vp-c-brand-1)]"
    >
      <div className="flex min-h-36 flex-1 items-center justify-center bg-[var(--vp-c-bg-soft)] p-5">
        {entry.preview}
      </div>
      <div className="flex flex-col gap-0.5 border-t border-[var(--vp-c-divider)] bg-[var(--vp-c-bg)] px-4 py-3">
        <span className="text-[0.875rem] font-semibold text-[var(--vp-c-text-1)]">
          {entry.name}
        </span>
        <span className="text-[0.75rem] text-[var(--vp-c-text-2)]">{entry.summary[locale]}</span>
      </div>
    </a>
  );
}

export default function AllComponents({
  locale = DEFAULT_LOCALE,
  base = ''
}: {
  locale?: Locale;
  /** URL prefix of the locale this page is in — `''` at the root, `/ko` otherwise. */
  base?: string;
}) {
  return (
    <div className="flex flex-col gap-10">
      {GROUPS.map((group) => (
        <section key={group.title} className="flex flex-col gap-4">
          <div className="flex flex-col gap-1">
            <span className="text-[0.8125rem] font-semibold tracking-wide text-[var(--vp-c-text-1)] uppercase">
              {group.title}
            </span>
            <span className="text-[0.8125rem] text-[var(--vp-c-text-2)]">{group.note[locale]}</span>
          </div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {group.entries.map((entry) => (
              <EntryCard key={entry.name} entry={entry} locale={locale} base={base} />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}
