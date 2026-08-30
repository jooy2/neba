/**
 * Indonesian.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, id } from 'neba/locales';
 *
 * registerMessages('id', id);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const id: NebaLocale = {
  action: {
    close: 'Tutup',
    dismiss: 'Abaikan',
    clear: 'Bersihkan',
    remove: 'Hapus'
  },
  link: { newTab: '(terbuka di tab baru)' },
  spoiler: {
    reveal: 'Tampilkan',
    hide: 'Sembunyikan',
    notice: 'Mungkin mengandung spoiler'
  },
  chat: {
    sending: 'Mengirim',
    sent: 'Terkirim',
    delivered: 'Diterima',
    read: 'Dibaca',
    failed: 'Gagal terkirim',
    typing: 'Sedang mengetik…'
  },
  empty: { title: 'Tidak ada apa-apa di sini' },
  table: {
    search: 'Cari',
    selectAll: 'Pilih semua baris',
    selectRow: 'Pilih baris',
    rowsPerPage: 'Baris per halaman',
    range: '{start}–{end} dari {total}',
    selected: '{count} dipilih',
    empty: 'Tidak ada data'
  },
  color: {
    area: 'Saturasi dan kecerahan',
    hue: 'Rona',
    alpha: 'Opasitas',
    value: 'Nilai warna',
    swatches: 'Warna preset',
    clear: 'Hapus',
    empty: 'Pilih warna'
  },
  rating: {
    label: 'Peringkat',
    value: '{value} dari {max}',
    empty: 'Belum ada peringkat'
  },
  number: {
    increase: 'Tambah',
    decrease: 'Kurangi'
  },
  pagination: {
    label: 'Penomoran halaman',
    page: 'Halaman {page}',
    status: 'Halaman {page} dari {total}',
    previous: 'Halaman sebelumnya',
    next: 'Halaman berikutnya',
    first: 'Halaman pertama',
    last: 'Halaman terakhir'
  },
  carousel: {
    label: 'Korsel',
    slide: 'Slide {index} dari {total}',
    previous: 'Slide sebelumnya',
    next: 'Slide berikutnya'
  },
  scroll: { previous: 'Gulir ke belakang', next: 'Gulir ke depan' },
  breadcrumb: {
    label: 'Remah roti',
    expand: 'Tampilkan langkah tersembunyi'
  },
  anchor: { label: 'Di halaman ini' },
  transfer: {
    source: 'Tersedia',
    target: 'Terpilih',
    toTarget: 'Pindahkan ke terpilih',
    toSource: 'Kembalikan ke tersedia',
    search: 'Cari',
    selectAll: 'Pilih semua',
    empty: 'Tidak ada apa pun'
  },
  combobox: {
    empty: 'Tidak ada yang cocok',
    remove: 'Hapus {label}'
  },
  overlay: {
    label: 'Hamparan'
  },
  window: {
    minimize: 'Perkecil',
    maximize: 'Perbesar',
    restore: 'Pulihkan',
    resize: 'Ubah ukuran jendela'
  },
  layout: {
    skipToContent: 'Lompat ke konten',
    sidebar: 'Bilah sisi',
    openSidebar: 'Buka bilah sisi',
    closeSidebar: 'Tutup bilah sisi',
    resizeSidebar: 'Ubah ukuran bilah sisi'
  },
  code: {
    code: 'Kode',
    copy: 'Salin',
    copied: 'Tersalin',
    copyFailed: 'Tidak dapat menyalin',
    raw: 'Mentah',
    prompt: 'Prompt'
  },
  steps: {
    previous: 'Sebelumnya',
    next: 'Berikutnya',
    done: 'Selesai',
    skip: 'Lewati',
    restart: 'Mulai lagi',
    completed: 'Semua langkah selesai',
    steps: 'Langkah',
    position: '{index} dari {total}',
    step: 'Langkah {index}: {title}'
  }
};
