/**
 * The words the library says on its own behalf.
 *
 * Almost nothing in Neba writes text a reader sees — a Button says whatever it
 * was handed, a Card's title is the caller's. The exceptions are the strings a
 * component has to invent because there is nowhere else for them to come from:
 * the sentence behind a link that opens a new tab, the label on the button that
 * uncovers a Spoiler, the word under a chat message that says it was read.
 *
 * Those are collected here rather than defaulted inside each component, for the
 * reason every other table in `internal/` exists: they are a set. A product in
 * Korean does not want eight components each defaulting to English and each
 * needing its own override prop, and the next component that needs a word —
 * a picker's "Today", a Pagination's "Next page" — should get it from the same
 * place rather than starting a second table beside this one.
 *
 * **One exported table per namespace, and never one table of all of them.** A
 * bundler drops an unused `export const`, and it cannot drop a key out of an
 * object literal — so a Chip that needs the word "Remove" and reaches it
 * through a single table holding every namespace ships the ColorPicker's seven
 * colour words and the Table's seven column words in eighteen languages too.
 * That was thirty-eight kilobytes of translations behind a two-kilobyte
 * component. Split per namespace, the Chip carries the four `action` strings
 * and nothing else. Adding a namespace is therefore a new `export const`
 * beside the others, not a new key inside one of them.
 *
 * What is *not* in here is anything `Intl` already knows. Month names, weekday
 * names, AM/PM and number formats come from the platform, which speaks more
 * languages than this file ever will. This is only for the words the platform
 * has no opinion about.
 *
 * Every component that reads this takes a `locale` and an override prop for the
 * string itself, so an unsupported language is never a dead end: `locale` gets
 * you a translation for free, and the prop gets you one for anything else.
 */

import * as React from 'react';

/**
 * One namespace's strings, in every language that has them.
 *
 * `''` is English and is complete by construction — every other tag fills in as
 * much as it has and is merged over English when it is read, so a half-finished
 * translation is a half-finished translation rather than a page of blanks.
 */
export interface MessageTable<T> {
  '': T;
  [tag: string]: Partial<T>;
}

/**
 * The words more than one component needs.
 *
 * The one namespace here that is not a component, and it exists because five
 * of them draw the same × and would otherwise each carry their own "Close" in
 * eighteen languages. A reader meeting that button on a Dialog, a Drawer, a
 * Popover and a Toast should hear the same word every time, which is easier to
 * guarantee when there is only one of it.
 */
export interface ActionMessages {
  /** The × on a Dialog, a Drawer, a Popover and a Toast. */
  close: string;
  /**
   * And the one on an Alert, which is a different act: a dialog is closed
   * because it has been answered, an alert is waved away.
   */
  dismiss: string;
  /** The × that empties a Combobox. */
  clear: string;
  /** The × on a Chip. */
  remove: string;
}

/** The `action` namespace, as Alert, Chip, Combobox, Dialog, Drawer, Popover and Toast read it. */
export const actionMessages: MessageTable<ActionMessages> = {
  '': {
    close: 'Close',
    dismiss: 'Dismiss',
    clear: 'Clear',
    remove: 'Remove'
  }
};

/** TextLink. */
export interface LinkMessages {
  /**
   * What is read out after a link that opens a new tab, and never drawn. A
   * window changing under the reader is the one thing about a link that is
   * invisible until it has already happened.
   */
  newTab: string;
}

/** The `link` namespace, as TextLink read it. */
export const linkMessages: MessageTable<LinkMessages> = {
  '': {
    newTab: '(opens in a new tab)'
  }
};

/** Spoiler. */
export interface SpoilerMessages {
  /** The button that uncovers the content. */
  reveal: string;
  /** And the one that covers it again, when the Spoiler is reversible. */
  hide: string;
  /** The line above the button, saying why the content is covered. */
  notice: string;
}

/** The `spoiler` namespace, as Spoiler read it. */
export const spoilerMessages: MessageTable<SpoilerMessages> = {
  '': {
    reveal: 'Reveal',
    hide: 'Hide',
    notice: 'This may contain spoilers'
  }
};

/** ChatBubble. */
export interface ChatMessages {
  /** The four steps a message goes through, as the mark under it. */
  sending: string;
  sent: string;
  delivered: string;
  read: string;
  /** And the fifth, which is not a step: it did not go. */
  failed: string;
  /** What the three dots mean. */
  typing: string;
}

/** The `chat` namespace, as ChatBubble read it. */
export const chatMessages: MessageTable<ChatMessages> = {
  '': {
    sending: 'Sending',
    sent: 'Sent',
    delivered: 'Delivered',
    read: 'Read',
    failed: 'Not sent',
    typing: 'Typing…'
  }
};

/** Empty. */
export interface EmptyMessages {
  /**
   * The headline over a region with nothing in it.
   *
   * The one string in here that is *drawn* at full size rather than read out
   * or written on a button, and it is here for the same reason the rest are:
   * an empty state has nothing to take its words from. What is missing is the
   * caller's — a search, an inbox, a folder — so the default says only that
   * there is nothing, and anything more specific is the `title` prop.
   */
  title: string;
}

/** The `empty` namespace, as Empty, DataTable, HeatmapChart and PieChart read it. */
export const emptyMessages: MessageTable<EmptyMessages> = {
  '': { title: 'Nothing here' }
};

/**
 * DataTable.
 *
 * A DataTable is the one component in the library that draws chrome of its
 * own — a search field, a header tick that chooses everything at once, a
 * footer counting what is on screen — so it is also the one that has the most
 * to say without being handed the words.
 */
export interface TableMessages {
  /** Placeholder and accessible name of the search field. */
  search: string;
  /** The tick in the header row, which chooses every row at once. */
  selectAll: string;
  /** The tick on a row. */
  selectRow: string;
  /** Beside the footer's page-size Select. */
  rowsPerPage: string;
  /**
   * Which rows are on screen, out of how many there are. `{start}`, `{end}`
   * and `{total}` are replaced with the numbers, already formatted for the
   * locale — a template rather than three fragments, because the order the
   * three appear in is exactly what differs between languages.
   */
  range: string;
  /** How many rows are chosen. `{count}` is replaced the same way. */
  selected: string;
  /**
   * What a table with no rows in it says. Shared with Table, which has the
   * same nothing to report and no chrome of its own to say it with.
   */
  empty: string;
}

/** The `table` namespace, as Table and DataTable read it. */
export const tableMessages: MessageTable<TableMessages> = {
  '': {
    search: 'Search',
    selectAll: 'Select all rows',
    selectRow: 'Select row',
    rowsPerPage: 'Rows per page',
    range: '{start}–{end} of {total}',
    selected: '{count} selected',
    empty: 'No data'
  }
};

/**
 * ColorPicker.
 *
 * All but one of these are names for something with no text on it: a square
 * of colour, two rails, a grid of swatches. A control a sighted reader
 * understands from a glance at a gradient is a control that says nothing at
 * all without them, which makes this the one namespace here where the strings
 * are the entire accessible interface rather than a convenience on top of it.
 */
export interface ColorMessages {
  /** The saturation/brightness square. */
  area: string;
  /** The rail beside it. */
  hue: string;
  /** The rail below that, when `alpha` is on. */
  alpha: string;
  /** The field the colour can be typed into. */
  value: string;
  /** The grid of ready-made colours. */
  swatches: string;
  /** The × that empties the control. */
  clear: string;
  /** What the trigger reads before anything has been chosen. */
  empty: string;
}

/** The `color` namespace, as ColorPicker read it. */
export const colorMessages: MessageTable<ColorMessages> = {
  '': {
    area: 'Saturation and brightness',
    hue: 'Hue',
    alpha: 'Opacity',
    value: 'Colour value',
    swatches: 'Preset colours',
    clear: 'Clear',
    empty: 'Choose a colour'
  }
};

/**
 * Rating.
 *
 * A row of stars is the same case the ColorPicker's rails are: the whole
 * control is a picture, and without these it says nothing at all to a reader
 * who is not looking at it.
 */
export interface RatingMessages {
  /** Names the group, when the caller has not named it themselves. */
  label: string;
  /**
   * What one star — and the whole control, once it is read only — is called.
   * `{value}` and `{max}` are replaced with the numbers, already formatted
   * for the locale.
   *
   * A sentence with both numbers in it rather than "3 stars", because a count
   * of stars is a plural in most languages and a fraction in none of them:
   * "3 out of 5" is one string per locale, and "3 stars" is one per locale
   * per plural form.
   */
  value: string;
  /** And what it is called before anything has been chosen. */
  empty: string;
}

/** The `rating` namespace, as Rating read it. */
export const ratingMessages: MessageTable<RatingMessages> = {
  '': {
    label: 'Rating',
    value: '{value} out of {max}',
    empty: 'No rating'
  }
};

/**
 * NumberField.
 *
 * Two buttons with an arrow on each and nothing else, which is the same case
 * the ColorPicker's rails are.
 */
export interface NumberMessages {
  /** The stepper that goes up. */
  increase: string;
  /** And the one that goes down. */
  decrease: string;
}

/** The `number` namespace, as NumberField read it. */
export const numberMessages: MessageTable<NumberMessages> = {
  '': {
    increase: 'Increase',
    decrease: 'Decrease'
  }
};

/**
 * Pagination.
 *
 * Every string here names a control that is a number or an arrow, so without
 * them the row reads out as a list of digits with no idea what they page
 * through.
 */
export interface PaginationMessages {
  /** Names the `<nav>` landmark. */
  label: string;
  /** One page button. `{page}` is replaced with the number. */
  page: string;
  /**
   * Where the reader is, read out rather than drawn. `{page}` and `{total}`
   * are both replaced — one sentence rather than two fragments, because a
   * count of pages and the page you are on go in opposite orders depending on
   * the language.
   */
  status: string;
  previous: string;
  next: string;
  first: string;
  last: string;
}

/** The `pagination` namespace, as Pagination read it. */
export const paginationMessages: MessageTable<PaginationMessages> = {
  '': {
    label: 'Pagination',
    page: 'Page {page}',
    status: 'Page {page} of {total}',
    previous: 'Previous page',
    next: 'Next page',
    first: 'First page',
    last: 'Last page'
  }
};

/** Carousel. */
export interface CarouselMessages {
  /** Names the region, beside the `carousel` roledescription. */
  label: string;
  /** One slide. `{index}` and `{total}` are replaced with the numbers. */
  slide: string;
  previous: string;
  next: string;
}

/** The `carousel` namespace, as Carousel read it. */
export const carouselMessages: MessageTable<CarouselMessages> = {
  '': {
    label: 'Carousel',
    slide: 'Slide {index} of {total}',
    previous: 'Previous slide',
    next: 'Next slide'
  }
};

/**
 * ScrollZone.
 *
 * Both buttons are an arrow with nothing else on them, and which way the
 * strip runs is a prop — so the words are logical rather than physical. A
 * vertical zone's "back" is up, and under RTL a horizontal one's is to the
 * right.
 */
export interface ScrollMessages {
  previous: string;
  next: string;
}

/** The `scroll` namespace, as ScrollZone read it. */
export const scrollMessages: MessageTable<ScrollMessages> = {
  '': {
    previous: 'Scroll back',
    next: 'Scroll forward'
  }
};

/** Breadcrumb. */
export interface BreadcrumbMessages {
  /** Names the `<nav>` landmark. */
  label: string;
  /** The `…` that puts the folded middle of the trail back. */
  expand: string;
}

/** The `breadcrumb` namespace, as Breadcrumb read it. */
export const breadcrumbMessages: MessageTable<BreadcrumbMessages> = {
  '': {
    label: 'Breadcrumb',
    expand: 'Show hidden steps'
  }
};

/** Combobox. */
export interface ComboboxMessages {
  /** The line where the list would be, when nothing matched what was typed. */
  empty: string;
  /** The × on one chosen entry. `{label}` is replaced with its own label. */
  remove: string;
}

/** The `combobox` namespace, as Combobox read it. */
export const comboboxMessages: MessageTable<ComboboxMessages> = {
  '': {
    empty: 'No matches',
    remove: 'Remove {label}'
  }
};

/** Overlay. */
export interface OverlayMessages {
  /** Names the sheet that covers whatever it was wrapped around. */
  label: string;
}

/** The `overlay` namespace, as Overlay read it. */
export const overlayMessages: MessageTable<OverlayMessages> = {
  '': {
    label: 'Overlay'
  }
};

/**
 * WindowPane.
 *
 * The three buttons on a title bar that are drawings of what they do, and the
 * handle that has no drawing at all. The × is `action.close`, which every
 * other component's close button already reads — a reader meeting it on a
 * Dialog and on a window should hear the same word.
 */
export interface WindowMessages {
  minimize: string;
  maximize: string;
  /** What the maximize button becomes once the window is maximized. */
  restore: string;
  /** Names the corner a pointer drags to resize. */
  resize: string;
}

/** The `window` namespace, as WindowPane read it. */
export const windowMessages: MessageTable<WindowMessages> = {
  '': {
    minimize: 'Minimize',
    maximize: 'Maximize',
    restore: 'Restore',
    resize: 'Resize window'
  }
};

/**
 * PageLayout, Header, Footer and Sidebar.
 *
 * A layout draws almost no text of its own — a header says whatever it was
 * handed — so what is here is only the words that exist *because* the page has
 * a structure: the link that jumps past it, the name of the region a reader
 * lands in, and the button that puts a sidebar back on screen once the window
 * is too narrow to hold one.
 */
export interface LayoutMessages {
  /**
   * The link that jumps a keyboard reader past the header and the sidebars,
   * drawn only while it holds the focus. It is the first thing in the document
   * and, on a page with forty links in its navigation, the difference between
   * reaching the article and tabbing through the site map first.
   */
  skipToContent: string;
  /** Names the `<aside>` when the caller gives it no name of its own. */
  sidebar: string;
  /** The button that brings back a sidebar the window has become too narrow to hold. */
  openSidebar: string;
  /** And the one that puts it away again. */
  closeSidebar: string;
  /** Names the edge a pointer drags to make a sidebar wider or narrower. */
  resizeSidebar: string;
}

/** The `layout` namespace, as PageLayout and Sidebar read it. */
export const layoutMessages: MessageTable<LayoutMessages> = {
  '': {
    skipToContent: 'Skip to content',
    sidebar: 'Sidebar',
    openSidebar: 'Open sidebar',
    closeSidebar: 'Close sidebar',
    resizeSidebar: 'Resize sidebar'
  }
};

/**
 * CodeBlock.
 *
 * The one component in the library whose chrome sits *on* the content rather
 * than beside it: a code block's buttons are inside the block, over the code,
 * and a reader who cannot see them still has to be told what they do.
 */
export interface CodeMessages {
  /** Names the block itself — the scrollable region, and the fallback when no `title` is given. */
  code: string;
  /** The button that puts the code on the clipboard. */
  copy: string;
  /** What that button says once it has. */
  copied: string;
  /** And what it says when the browser refused — a page served over plain HTTP, mostly. */
  copyFailed: string;
  /** The toggle that drops the colouring and shows the characters as they are. */
  raw: string;
  /** What is read out in place of a prompt symbol, which is decoration and not code. */
  prompt: string;
}

/** The `code` namespace, as CodeBlock reads it. */
export const codeMessages: MessageTable<CodeMessages> = {
  '': {
    code: 'Code',
    copy: 'Copy',
    copied: 'Copied',
    copyFailed: 'Could not copy',
    raw: 'Raw',
    prompt: 'Prompt'
  }
};

/**
 * HowToSteps.
 *
 * Five words and a pair of counted sentences. The counted ones carry `{index}`,
 * `{total}` and `{title}`, so a language that puts the number after the noun
 * can, which is the whole reason they are strings with slots rather than
 * numbers the component concatenates.
 */
export interface StepsMessages {
  /** The button that goes back one step. */
  previous: string;
  /** The one that goes forward. */
  next: string;
  /** And what it becomes on the last step. */
  done: string;
  /** The button under a finished guide. */
  restart: string;
  /** What a finished guide says. */
  completed: string;
  /** Names the list of steps for a screen reader. */
  steps: string;
  /** The counter over the step's body — `{index}` of `{total}`. */
  position: string;
  /** How one row in the list is announced. */
  step: string;
}

/** The `steps` namespace, as HowToSteps reads it. */
export const stepsMessages: MessageTable<StepsMessages> = {
  '': {
    previous: 'Previous',
    next: 'Next',
    done: 'Done',
    restart: 'Start over',
    completed: 'All steps complete',
    steps: 'Steps',
    position: '{index} of {total}',
    step: 'Step {index}: {title}'
  }
};

/**
 * The tags that are a different spelling of an entry above.
 *
 * Only the Chinese ones for now, and they are the reason the table is keyed by
 * script: a reader in Taipei asking for `zh-TW` and one in Hong Kong asking for
 * `zh-HK` want the same words, and a table keyed by region would hold that pair
 * twice. Bare `zh` resolves to Simplified, which is what every other library
 * that has had to pick one has picked.
 */
const aliases: Record<string, string> = {
  zh: 'zh-hans',
  'zh-cn': 'zh-hans',
  'zh-my': 'zh-hans',
  'zh-sg': 'zh-hans',
  'zh-hk': 'zh-hant',
  'zh-mo': 'zh-hant',
  'zh-tw': 'zh-hant'
};

/**
 * A BCP 47 tag, broadest match last.
 *
 * `zh-Hant-TW` asks for `zh-hant`, then `zh-tw`, then `zh`; `pt-BR` asks for
 * `pt-br` and then `pt`. The subtags are found by shape rather than by
 * position, because a tag can carry an extension or a variant between them and
 * `split('-')[1]` would take that for the script.
 */
function candidates(locale: string): string[] {
  const subtags = locale.toLowerCase().split(/[-_]/).filter(Boolean);
  const language = subtags[0];

  if (!language) {
    return [];
  }

  const rest = subtags.slice(1);
  const script = rest.find((subtag) => /^[a-z]{4}$/.test(subtag));
  const region = rest.find((subtag) => /^([a-z]{2}|\d{3})$/.test(subtag));

  return [
    script ? `${language}-${script}` : '',
    region ? `${language}-${region}` : '',
    language
  ].filter(Boolean);
}

/**
 * Resolved namespaces, per table and per tag.
 *
 * Keyed by the table itself so the fourteen namespaces cannot collide, and weak
 * so a table a bundler dropped does not keep a cache alive. The merge is the
 * same work for every ChatBubble in a thread, and a thread is where this gets
 * called a hundred times.
 */
const resolved = new WeakMap<MessageTable<object>, Map<string, object>>();

/**
 * One namespace's strings for a locale, merged over English.
 *
 * `undefined` is English rather than the runtime's own locale, and that is
 * deliberate: `navigator.language` differs between the server that renders the
 * markup and the browser that hydrates it, and text that changes between those
 * two is a hydration mismatch in the one part of the page a reader is looking
 * at. A component that should follow the reader is told which language to
 * follow.
 */
export function resolveMessages<T extends object>(table: MessageTable<T>, locale?: string): T {
  const english = table[''];
  const key = locale?.trim() ?? '';

  if (!key) {
    return english;
  }

  let cache = resolved.get(table as MessageTable<object>);

  if (!cache) {
    cache = new Map();
    resolved.set(table as MessageTable<object>, cache);
  }

  const cached = cache.get(key);

  if (cached) {
    return cached as T;
  }

  const match = candidates(key)
    .map((candidate) => {
      const alias = aliases[candidate];

      return table[candidate] ?? (alias ? table[alias] : undefined);
    })
    .find(Boolean);

  const messages: T = match ? { ...english, ...match } : english;

  cache.set(key, messages);

  return messages;
}

/** The same, as a hook, for the components that read it during a render. */
export function useMessages<T extends object>(table: MessageTable<T>, locale?: string): T {
  return React.useMemo(() => resolveMessages(table, locale), [table, locale]);
}

/**
 * Fills the `{placeholders}` in one of the strings above.
 *
 * Two of them carry numbers, and neither could be assembled out of fragments:
 * "1–25 of 1,204" is "전체 1,204개 중 1–25" in Korean and "1,204 kayıttan 1–25"
 * in Turkish, so what differs between languages is the *order*, which only a
 * whole sentence can state. A `{name}` with no value is left alone rather than
 * blanked, so a mistranslated placeholder shows up as itself instead of as a
 * hole in the middle of a sentence.
 */
export function fillMessage(template: string, values: Record<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (whole, name: string) => values[name] ?? whole);
}

/**
 * A language, as `neba/locales` hands it over.
 *
 * Every namespace is optional and every string inside one is too: a locale
 * fills in what it has and English answers for the rest, so a translation that
 * has not caught up with a new component is a translation that has not caught
 * up rather than a page of blanks.
 */
export interface NebaLocale {
  /** Action. */
  action?: Partial<ActionMessages>;
  /** Link. */
  link?: Partial<LinkMessages>;
  /** Spoiler. */
  spoiler?: Partial<SpoilerMessages>;
  /** Chat. */
  chat?: Partial<ChatMessages>;
  /** Empty. */
  empty?: Partial<EmptyMessages>;
  /** Table. */
  table?: Partial<TableMessages>;
  /** Color. */
  color?: Partial<ColorMessages>;
  /** Rating. */
  rating?: Partial<RatingMessages>;
  /** Number. */
  number?: Partial<NumberMessages>;
  /** Pagination. */
  pagination?: Partial<PaginationMessages>;
  /** Carousel. */
  carousel?: Partial<CarouselMessages>;
  /** Scroll. */
  scroll?: Partial<ScrollMessages>;
  /** Breadcrumb. */
  breadcrumb?: Partial<BreadcrumbMessages>;
  /** Combobox. */
  combobox?: Partial<ComboboxMessages>;
  /** Overlay. */
  overlay?: Partial<OverlayMessages>;
  /** Window. */
  window?: Partial<WindowMessages>;
  /** Layout. */
  layout?: Partial<LayoutMessages>;
  /** Code. */
  code?: Partial<CodeMessages>;
  /** Steps. */
  steps?: Partial<StepsMessages>;
}

/** Namespace name to the table that holds it, for the one function that needs all of them. */
const byNamespace: Record<keyof NebaLocale, MessageTable<never>> = {
  action: actionMessages as MessageTable<never>,
  link: linkMessages as MessageTable<never>,
  spoiler: spoilerMessages as MessageTable<never>,
  chat: chatMessages as MessageTable<never>,
  empty: emptyMessages as MessageTable<never>,
  table: tableMessages as MessageTable<never>,
  color: colorMessages as MessageTable<never>,
  rating: ratingMessages as MessageTable<never>,
  number: numberMessages as MessageTable<never>,
  pagination: paginationMessages as MessageTable<never>,
  carousel: carouselMessages as MessageTable<never>,
  scroll: scrollMessages as MessageTable<never>,
  breadcrumb: breadcrumbMessages as MessageTable<never>,
  combobox: comboboxMessages as MessageTable<never>,
  overlay: overlayMessages as MessageTable<never>,
  window: windowMessages as MessageTable<never>,
  layout: layoutMessages as MessageTable<never>,
  code: codeMessages as MessageTable<never>,
  steps: stepsMessages as MessageTable<never>
};

/**
 * Teaches the library a language.
 *
 * English is the only one built in. Everything else is a module under
 * `neba/locales` that a project imports and registers once, at module scope,
 * before it renders:
 *
 * ```ts
 * import { registerMessages, ko } from 'neba/locales';
 *
 * registerMessages('ko', ko);
 * ```
 *
 * Shipping the other seventeen unconditionally would put them in the bundle of
 * every product that speaks one language, because a bundler cannot drop a key
 * out of an object literal — which is the same reason the namespaces above are
 * fourteen exports rather than one table. Registering is what makes the cost
 * follow the need.
 *
 * The tag is matched the way a `locale` prop is: by script, then by region,
 * then by language. Registering `zh-hans` answers `zh-CN` and a bare `zh`;
 * registering `pt` answers `pt-BR`.
 *
 * Calling this after a tree has rendered does not re-render it. It replaces
 * what a locale had, rather than merging into it, so a second call with a
 * partial locale is a correction and not an addition.
 */
export function registerMessages(tag: string, locale: NebaLocale): void {
  const key = tag.trim().toLowerCase();

  for (const [namespace, messages] of Object.entries(locale)) {
    const table = byNamespace[namespace as keyof NebaLocale];

    if (!table || !messages) {
      continue;
    }

    table[key] = messages as never;
    // The resolved-and-merged copies were made from what the table said before.
    resolved.delete(table as MessageTable<object>);
  }
}
