/**
 * Polish.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, pl } from 'neba/locales';
 *
 * registerMessages('pl', pl);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const pl: NebaLocale = {
  action: {
    close: 'Zamknij',
    dismiss: 'Odrzuć',
    clear: 'Wyczyść',
    remove: 'Usuń'
  },
  confirm: {
    confirm: 'Potwierdź',
    cancel: 'Anuluj'
  },
  link: { newTab: '(otwiera się w nowej karcie)' },
  spoiler: {
    reveal: 'Pokaż',
    hide: 'Ukryj',
    notice: 'Może zawierać spoilery'
  },
  chat: {
    sending: 'Wysyłanie',
    sent: 'Wysłano',
    delivered: 'Dostarczono',
    read: 'Przeczytano',
    failed: 'Nie wysłano',
    typing: 'Pisze…'
  },
  empty: { title: 'Nic tu nie ma' },
  table: {
    search: 'Szukaj',
    selectAll: 'Zaznacz wszystkie wiersze',
    selectRow: 'Zaznacz wiersz',
    rowsPerPage: 'Wierszy na stronę',
    range: '{start}–{end} z {total}',
    selected: 'Zaznaczono: {count}',
    empty: 'Brak danych'
  },
  color: {
    area: 'Nasycenie i jasność',
    hue: 'Barwa',
    alpha: 'Krycie',
    value: 'Wartość koloru',
    swatches: 'Kolory predefiniowane',
    clear: 'Wyczyść',
    empty: 'Wybierz kolor'
  },
  rating: {
    label: 'Ocena',
    value: '{value} z {max}',
    empty: 'Brak oceny'
  },
  number: {
    increase: 'Zwiększ',
    decrease: 'Zmniejsz'
  },
  pagination: {
    label: 'Paginacja',
    page: 'Strona {page}',
    status: 'Strona {page} z {total}',
    previous: 'Poprzednia strona',
    next: 'Następna strona',
    first: 'Pierwsza strona',
    last: 'Ostatnia strona'
  },
  carousel: {
    label: 'Karuzela',
    slide: 'Slajd {index} z {total}',
    previous: 'Poprzedni slajd',
    next: 'Następny slajd'
  },
  chart: { label: 'Wykres' },
  scroll: { label: 'Przewijalna zawartość', previous: 'Przewiń wstecz', next: 'Przewiń dalej' },
  breadcrumb: {
    label: 'Ścieżka nawigacji',
    expand: 'Pokaż ukryte kroki'
  },
  anchor: { label: 'Na tej stronie' },
  transfer: {
    source: 'Dostępne',
    target: 'Wybrane',
    toTarget: 'Przenieś do wybranych',
    toSource: 'Przenieś do dostępnych',
    search: 'Szukaj',
    selectAll: 'Zaznacz wszystko',
    empty: 'Nic tu nie ma'
  },
  command: {
    label: 'Paleta poleceń',
    search: 'Wpisz polecenie lub wyszukaj…',
    empty: 'Nie znaleziono poleceń'
  },
  combobox: {
    empty: 'Brak wyników',
    remove: 'Usuń {label}'
  },
  overlay: {
    label: 'Nakładka'
  },
  window: {
    minimize: 'Minimalizuj',
    maximize: 'Maksymalizuj',
    restore: 'Przywróć',
    resize: 'Zmień rozmiar okna'
  },
  layout: {
    skipToContent: 'Przejdź do treści',
    sidebar: 'Panel boczny',
    openSidebar: 'Otwórz panel boczny',
    closeSidebar: 'Zamknij panel boczny',
    resizeSidebar: 'Zmień szerokość panelu bocznego'
  },
  code: {
    code: 'Kod',
    copy: 'Kopiuj',
    copied: 'Skopiowano',
    copyFailed: 'Nie udało się skopiować',
    raw: 'Surowy',
    prompt: 'Znak zachęty'
  },
  steps: {
    previous: 'Wstecz',
    next: 'Dalej',
    done: 'Gotowe',
    skip: 'Pomiń',
    restart: 'Zacznij od nowa',
    completed: 'Wszystkie kroki ukończone',
    steps: 'Kroki',
    position: '{index} z {total}',
    step: 'Krok {index}: {title}'
  }
};
