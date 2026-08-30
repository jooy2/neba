/**
 * Italian.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, it } from 'neba/locales';
 *
 * registerMessages('it', it);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const it: NebaLocale = {
  action: {
    close: 'Chiudi',
    dismiss: 'Ignora',
    clear: 'Cancella',
    remove: 'Rimuovi'
  },
  link: { newTab: '(si apre in una nuova scheda)' },
  spoiler: {
    reveal: 'Mostra',
    hide: 'Nascondi',
    notice: 'Può contenere spoiler'
  },
  chat: {
    sending: 'Invio in corso',
    sent: 'Inviato',
    delivered: 'Consegnato',
    read: 'Letto',
    failed: 'Non inviato',
    typing: 'Sta scrivendo…'
  },
  empty: { title: 'Non c’è nulla' },
  table: {
    search: 'Cerca',
    selectAll: 'Seleziona tutte le righe',
    selectRow: 'Seleziona riga',
    rowsPerPage: 'Righe per pagina',
    range: '{start}–{end} di {total}',
    selected: '{count} selezionate',
    empty: 'Nessun dato'
  },
  color: {
    area: 'Saturazione e luminosità',
    hue: 'Tonalità',
    alpha: 'Opacità',
    value: 'Valore del colore',
    swatches: 'Colori predefiniti',
    clear: 'Cancella',
    empty: 'Scegli un colore'
  },
  rating: {
    label: 'Valutazione',
    value: '{value} su {max}',
    empty: 'Nessuna valutazione'
  },
  number: {
    increase: 'Aumenta',
    decrease: 'Diminuisci'
  },
  pagination: {
    label: 'Impaginazione',
    page: 'Pagina {page}',
    status: 'Pagina {page} di {total}',
    previous: 'Pagina precedente',
    next: 'Pagina successiva',
    first: 'Prima pagina',
    last: 'Ultima pagina'
  },
  carousel: {
    label: 'Carosello',
    slide: 'Diapositiva {index} di {total}',
    previous: 'Diapositiva precedente',
    next: 'Diapositiva successiva'
  },
  chart: { label: 'Grafico' },
  scroll: { label: 'Contenuto scorrevole', previous: 'Scorri indietro', next: 'Scorri avanti' },
  breadcrumb: {
    label: 'Percorso di navigazione',
    expand: 'Mostra i passaggi nascosti'
  },
  anchor: { label: 'In questa pagina' },
  transfer: {
    source: 'Disponibili',
    target: 'Selezionati',
    toTarget: 'Sposta tra i selezionati',
    toSource: 'Riporta tra i disponibili',
    search: 'Cerca',
    selectAll: 'Seleziona tutto',
    empty: 'Nessun elemento'
  },
  command: {
    label: 'Tavolozza comandi',
    search: 'Digita un comando o cerca…',
    empty: 'Nessun comando trovato'
  },
  combobox: {
    empty: 'Nessun risultato',
    remove: 'Rimuovi {label}'
  },
  overlay: {
    label: 'Sovrapposizione'
  },
  window: {
    minimize: 'Riduci a icona',
    maximize: 'Ingrandisci',
    restore: 'Ripristina',
    resize: 'Ridimensiona la finestra'
  },
  layout: {
    skipToContent: 'Vai al contenuto',
    sidebar: 'Barra laterale',
    openSidebar: 'Apri barra laterale',
    closeSidebar: 'Chiudi barra laterale',
    resizeSidebar: 'Ridimensiona barra laterale'
  },
  code: {
    code: 'Codice',
    copy: 'Copia',
    copied: 'Copiato',
    copyFailed: 'Impossibile copiare',
    raw: 'Grezzo',
    prompt: 'Prompt'
  },
  steps: {
    previous: 'Indietro',
    next: 'Avanti',
    done: 'Fatto',
    skip: 'Salta',
    restart: 'Ricomincia',
    completed: 'Tutti i passaggi completati',
    steps: 'Passaggi',
    position: '{index} di {total}',
    step: 'Passaggio {index}: {title}'
  }
};
