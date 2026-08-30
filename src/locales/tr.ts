/**
 * Turkish.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, tr } from 'neba/locales';
 *
 * registerMessages('tr', tr);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const tr: NebaLocale = {
  action: {
    close: 'Kapat',
    dismiss: 'Yoksay',
    clear: 'Temizle',
    remove: 'Kaldır'
  },
  link: { newTab: '(yeni sekmede açılır)' },
  spoiler: {
    reveal: 'Göster',
    hide: 'Gizle',
    notice: 'Spoiler içerebilir'
  },
  chat: {
    sending: 'Gönderiliyor',
    sent: 'Gönderildi',
    delivered: 'İletildi',
    read: 'Okundu',
    failed: 'Gönderilemedi',
    typing: 'Yazıyor…'
  },
  empty: { title: 'Burada bir şey yok' },
  table: {
    search: 'Ara',
    selectAll: 'Tüm satırları seç',
    selectRow: 'Satırı seç',
    rowsPerPage: 'Sayfa başına satır',
    range: '{total} kayıttan {start}–{end}',
    selected: '{count} seçildi',
    empty: 'Veri yok'
  },
  color: {
    area: 'Doygunluk ve parlaklık',
    hue: 'Renk tonu',
    alpha: 'Opaklık',
    value: 'Renk değeri',
    swatches: 'Hazır renkler',
    clear: 'Temizle',
    empty: 'Bir renk seçin'
  },
  rating: {
    label: 'Değerlendirme',
    value: '{max} üzerinden {value}',
    empty: 'Değerlendirilmedi'
  },
  number: {
    increase: 'Artır',
    decrease: 'Azalt'
  },
  pagination: {
    label: 'Sayfalama',
    page: '{page}. sayfa',
    status: '{total} sayfadan {page}. sayfa',
    previous: 'Önceki sayfa',
    next: 'Sonraki sayfa',
    first: 'İlk sayfa',
    last: 'Son sayfa'
  },
  carousel: {
    label: 'Karusel',
    slide: '{total} slayttan {index}. slayt',
    previous: 'Önceki slayt',
    next: 'Sonraki slayt'
  },
  scroll: { previous: 'Geri kaydır', next: 'İleri kaydır' },
  breadcrumb: {
    label: 'Gezinti yolu',
    expand: 'Gizli adımları göster'
  },
  anchor: { label: 'Bu sayfada' },
  transfer: {
    source: 'Kullanılabilir',
    target: 'Seçili',
    toTarget: 'Seçilenlere taşı',
    toSource: 'Kullanılabilire geri al',
    search: 'Ara',
    selectAll: 'Tümünü seç',
    empty: 'Burada bir şey yok'
  },
  combobox: {
    empty: 'Eşleşme yok',
    remove: '{label} kaldır'
  },
  overlay: {
    label: 'Kaplama'
  },
  window: {
    minimize: 'Simge durumuna küçült',
    maximize: 'Ekranı kapla',
    restore: 'Geri yükle',
    resize: 'Pencereyi yeniden boyutlandır'
  },
  layout: {
    skipToContent: 'İçeriğe geç',
    sidebar: 'Kenar çubuğu',
    openSidebar: 'Kenar çubuğunu aç',
    closeSidebar: 'Kenar çubuğunu kapat',
    resizeSidebar: 'Kenar çubuğunu yeniden boyutlandır'
  },
  code: {
    code: 'Kod',
    copy: 'Kopyala',
    copied: 'Kopyalandı',
    copyFailed: 'Kopyalanamadı',
    raw: 'Ham',
    prompt: 'Komut istemi'
  },
  steps: {
    previous: 'Önceki',
    next: 'Sonraki',
    done: 'Bitti',
    skip: 'Atla',
    restart: 'Baştan başla',
    completed: 'Tüm adımlar tamamlandı',
    steps: 'Adımlar',
    position: '{total} adımdan {index}. adım',
    step: 'Adım {index}: {title}'
  }
};
