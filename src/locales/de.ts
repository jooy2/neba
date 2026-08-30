/**
 * German.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, de } from 'neba/locales';
 *
 * registerMessages('de', de);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const de: NebaLocale = {
  action: {
    close: 'Schließen',
    dismiss: 'Ausblenden',
    clear: 'Löschen',
    remove: 'Entfernen'
  },
  link: { newTab: '(wird in einem neuen Tab geöffnet)' },
  spoiler: {
    reveal: 'Anzeigen',
    hide: 'Ausblenden',
    notice: 'Kann Spoiler enthalten'
  },
  chat: {
    sending: 'Wird gesendet',
    sent: 'Gesendet',
    delivered: 'Zugestellt',
    read: 'Gelesen',
    failed: 'Nicht gesendet',
    typing: 'Schreibt…'
  },
  empty: { title: 'Nichts vorhanden' },
  table: {
    search: 'Suchen',
    selectAll: 'Alle Zeilen auswählen',
    selectRow: 'Zeile auswählen',
    rowsPerPage: 'Zeilen pro Seite',
    range: '{start}–{end} von {total}',
    selected: '{count} ausgewählt',
    empty: 'Keine Daten'
  },
  color: {
    area: 'Sättigung und Helligkeit',
    hue: 'Farbton',
    alpha: 'Deckkraft',
    value: 'Farbwert',
    swatches: 'Vorgegebene Farben',
    clear: 'Löschen',
    empty: 'Farbe auswählen'
  },
  rating: {
    label: 'Bewertung',
    value: '{value} von {max}',
    empty: 'Keine Bewertung'
  },
  number: {
    increase: 'Erhöhen',
    decrease: 'Verringern'
  },
  pagination: {
    label: 'Seitennavigation',
    page: 'Seite {page}',
    status: 'Seite {page} von {total}',
    previous: 'Vorherige Seite',
    next: 'Nächste Seite',
    first: 'Erste Seite',
    last: 'Letzte Seite'
  },
  carousel: {
    label: 'Karussell',
    slide: 'Folie {index} von {total}',
    previous: 'Vorherige Folie',
    next: 'Nächste Folie'
  },
  chart: { label: 'Diagramm' },
  scroll: { previous: 'Zurückscrollen', next: 'Weiterscrollen' },
  breadcrumb: {
    label: 'Breadcrumb-Navigation',
    expand: 'Ausgeblendete Schritte anzeigen'
  },
  anchor: { label: 'Auf dieser Seite' },
  transfer: {
    source: 'Verfügbar',
    target: 'Ausgewählt',
    toTarget: 'Zu Ausgewählt verschieben',
    toSource: 'Zurück zu Verfügbar',
    search: 'Suchen',
    selectAll: 'Alle auswählen',
    empty: 'Nichts vorhanden'
  },
  command: {
    label: 'Befehlspalette',
    search: 'Befehl eingeben oder suchen…',
    empty: 'Keine Befehle gefunden'
  },
  combobox: {
    empty: 'Keine Treffer',
    remove: '{label} entfernen'
  },
  overlay: {
    label: 'Overlay'
  },
  window: {
    minimize: 'Minimieren',
    maximize: 'Maximieren',
    restore: 'Wiederherstellen',
    resize: 'Fenstergröße ändern'
  },
  layout: {
    skipToContent: 'Zum Inhalt springen',
    sidebar: 'Seitenleiste',
    openSidebar: 'Seitenleiste öffnen',
    closeSidebar: 'Seitenleiste schließen',
    resizeSidebar: 'Seitenleiste anpassen'
  },
  code: {
    code: 'Code',
    copy: 'Kopieren',
    copied: 'Kopiert',
    copyFailed: 'Kopieren nicht möglich',
    raw: 'Unformatiert',
    prompt: 'Eingabeaufforderung'
  },
  steps: {
    previous: 'Zurück',
    next: 'Weiter',
    done: 'Fertig',
    skip: 'Überspringen',
    restart: 'Von vorn beginnen',
    completed: 'Alle Schritte abgeschlossen',
    steps: 'Schritte',
    position: '{index} von {total}',
    step: 'Schritt {index}: {title}'
  }
};
