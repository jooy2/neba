/**
 * Hindi.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, hi } from 'neba/locales';
 *
 * registerMessages('hi', hi);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const hi: NebaLocale = {
  action: {
    close: 'बंद करें',
    dismiss: 'खारिज करें',
    clear: 'साफ़ करें',
    remove: 'हटाएँ'
  },
  confirm: {
    confirm: 'पुष्टि करें',
    cancel: 'रद्द करें'
  },
  link: { newTab: '(नए टैब में खुलता है)' },
  spoiler: {
    reveal: 'दिखाएँ',
    hide: 'छिपाएँ',
    notice: 'इसमें स्पॉइलर हो सकते हैं'
  },
  chat: {
    sending: 'भेजा जा रहा है',
    sent: 'भेजा गया',
    delivered: 'डिलीवर हुआ',
    read: 'पढ़ा गया',
    failed: 'नहीं भेजा गया',
    typing: 'टाइप कर रहे हैं…'
  },
  empty: { title: 'यहाँ कुछ नहीं है' },
  table: {
    search: 'खोजें',
    selectAll: 'सभी पंक्तियाँ चुनें',
    selectRow: 'पंक्ति चुनें',
    rowsPerPage: 'प्रति पृष्ठ पंक्तियाँ',
    range: '{total} में से {start}–{end}',
    selected: '{count} चुनी गईं',
    empty: 'कोई डेटा नहीं',
    exportCsv: 'CSV निर्यात करें'
  },
  color: {
    area: 'संतृप्ति और चमक',
    hue: 'रंग',
    alpha: 'अपारदर्शिता',
    value: 'रंग मान',
    swatches: 'पूर्व निर्धारित रंग',
    clear: 'साफ़ करें',
    empty: 'एक रंग चुनें'
  },
  rating: {
    label: 'रेटिंग',
    value: '{max} में से {value}',
    empty: 'कोई रेटिंग नहीं'
  },
  number: {
    increase: 'बढ़ाएँ',
    decrease: 'घटाएँ'
  },
  pagination: {
    label: 'पृष्ठ क्रमांकन',
    page: 'पृष्ठ {page}',
    status: '{total} में से पृष्ठ {page}',
    previous: 'पिछला पृष्ठ',
    next: 'अगला पृष्ठ',
    first: 'पहला पृष्ठ',
    last: 'अंतिम पृष्ठ'
  },
  carousel: {
    label: 'कैरोसेल',
    slide: '{total} में से स्लाइड {index}',
    previous: 'पिछली स्लाइड',
    next: 'अगली स्लाइड'
  },
  chart: { label: 'चार्ट' },
  scroll: {
    label: 'स्क्रॉल करने योग्य सामग्री',
    previous: 'पीछे स्क्रॉल करें',
    next: 'आगे स्क्रॉल करें'
  },
  breadcrumb: {
    label: 'ब्रेडक्रंब',
    expand: 'छिपे हुए चरण दिखाएँ'
  },
  anchor: { label: 'इस पृष्ठ पर' },
  transfer: {
    source: 'उपलब्ध',
    target: 'चयनित',
    toTarget: 'चयनित में ले जाएँ',
    toSource: 'उपलब्ध में वापस भेजें',
    search: 'खोजें',
    selectAll: 'सभी चुनें',
    empty: 'यहाँ कुछ नहीं है'
  },
  command: {
    label: 'कमांड पैलेट',
    search: 'कमांड लिखें या खोजें…',
    empty: 'कोई कमांड नहीं मिली'
  },
  combobox: {
    empty: 'कोई मिलान नहीं',
    remove: '{label} हटाएँ'
  },
  overlay: {
    label: 'ओवरले'
  },
  window: {
    minimize: 'छोटा करें',
    maximize: 'बड़ा करें',
    restore: 'पुनर्स्थापित करें',
    resize: 'विंडो का आकार बदलें'
  },
  layout: {
    skipToContent: 'सामग्री पर जाएँ',
    sidebar: 'साइडबार',
    openSidebar: 'साइडबार खोलें',
    closeSidebar: 'साइडबार बंद करें',
    resizeSidebar: 'साइडबार का आकार बदलें'
  },
  code: {
    code: 'कोड',
    copy: 'कॉपी करें',
    copied: 'कॉपी हो गया',
    copyFailed: 'कॉपी नहीं हो सका',
    raw: 'मूल',
    prompt: 'प्रॉम्प्ट'
  },
  steps: {
    previous: 'पिछला',
    next: 'अगला',
    done: 'पूर्ण',
    skip: 'छोड़ें',
    restart: 'फिर से शुरू करें',
    completed: 'सभी चरण पूरे हुए',
    steps: 'चरण',
    position: '{total} में से {index}',
    step: 'चरण {index}: {title}'
  }
};
