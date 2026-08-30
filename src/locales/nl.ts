/**
 * Dutch.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, nl } from 'neba/locales';
 *
 * registerMessages('nl', nl);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const nl: NebaLocale = {
  action: {
    close: 'Sluiten',
    dismiss: 'Negeren',
    clear: 'Wissen',
    remove: 'Verwijderen'
  },
  link: { newTab: '(opent in een nieuw tabblad)' },
  spoiler: {
    reveal: 'Tonen',
    hide: 'Verbergen',
    notice: 'Kan spoilers bevatten'
  },
  chat: {
    sending: 'Wordt verzonden',
    sent: 'Verzonden',
    delivered: 'Afgeleverd',
    read: 'Gelezen',
    failed: 'Niet verzonden',
    typing: 'Aan het typen…'
  },
  empty: { title: 'Hier is niets' },
  table: {
    search: 'Zoeken',
    selectAll: 'Alle rijen selecteren',
    selectRow: 'Rij selecteren',
    rowsPerPage: 'Rijen per pagina',
    range: '{start}–{end} van {total}',
    selected: '{count} geselecteerd',
    empty: 'Geen gegevens'
  },
  color: {
    area: 'Verzadiging en helderheid',
    hue: 'Kleurtoon',
    alpha: 'Dekking',
    value: 'Kleurwaarde',
    swatches: 'Vooraf ingestelde kleuren',
    clear: 'Wissen',
    empty: 'Kies een kleur'
  },
  rating: {
    label: 'Beoordeling',
    value: '{value} van {max}',
    empty: 'Geen beoordeling'
  },
  number: {
    increase: 'Verhogen',
    decrease: 'Verlagen'
  },
  pagination: {
    label: 'Paginering',
    page: 'Pagina {page}',
    status: 'Pagina {page} van {total}',
    previous: 'Vorige pagina',
    next: 'Volgende pagina',
    first: 'Eerste pagina',
    last: 'Laatste pagina'
  },
  carousel: {
    label: 'Carrousel',
    slide: 'Dia {index} van {total}',
    previous: 'Vorige dia',
    next: 'Volgende dia'
  },
  chart: { label: 'Grafiek' },
  scroll: { previous: 'Terugscrollen', next: 'Vooruitscrollen' },
  breadcrumb: {
    label: 'Kruimelpad',
    expand: 'Verborgen stappen tonen'
  },
  anchor: { label: 'Op deze pagina' },
  transfer: {
    source: 'Beschikbaar',
    target: 'Geselecteerd',
    toTarget: 'Naar geselecteerd verplaatsen',
    toSource: 'Terug naar beschikbaar',
    search: 'Zoeken',
    selectAll: 'Alles selecteren',
    empty: 'Niets aanwezig'
  },
  command: {
    label: 'Opdrachtenpalet',
    search: 'Typ een opdracht of zoek…',
    empty: 'Geen opdrachten gevonden'
  },
  combobox: {
    empty: 'Geen resultaten',
    remove: '{label} verwijderen'
  },
  overlay: {
    label: 'Overlay'
  },
  window: {
    minimize: 'Minimaliseren',
    maximize: 'Maximaliseren',
    restore: 'Vorig formaat',
    resize: 'Venstergrootte wijzigen'
  },
  layout: {
    skipToContent: 'Naar inhoud springen',
    sidebar: 'Zijbalk',
    openSidebar: 'Zijbalk openen',
    closeSidebar: 'Zijbalk sluiten',
    resizeSidebar: 'Zijbalk vergroten of verkleinen'
  },
  code: {
    code: 'Code',
    copy: 'Kopiëren',
    copied: 'Gekopieerd',
    copyFailed: 'Kopiëren mislukt',
    raw: 'Onopgemaakt',
    prompt: 'Prompt'
  },
  steps: {
    previous: 'Vorige',
    next: 'Volgende',
    done: 'Klaar',
    skip: 'Overslaan',
    restart: 'Opnieuw beginnen',
    completed: 'Alle stappen voltooid',
    steps: 'Stappen',
    position: '{index} van {total}',
    step: 'Stap {index}: {title}'
  }
};
