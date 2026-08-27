/**
 * Japanese.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, ja } from 'neba/locales';
 *
 * registerMessages('ja', ja);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const ja: NebaLocale = {
  action: {
    close: '閉じる',
    dismiss: '閉じる',
    clear: 'クリア',
    remove: '削除'
  },
  link: { newTab: '(新しいタブで開きます)' },
  spoiler: {
    reveal: '表示する',
    hide: '隠す',
    notice: 'ネタバレを含む可能性があります'
  },
  chat: {
    sending: '送信中',
    sent: '送信済み',
    delivered: '配信済み',
    read: '既読',
    failed: '送信できませんでした',
    typing: '入力中…'
  },
  empty: { title: '表示するものがありません' },
  table: {
    search: '検索',
    selectAll: 'すべての行を選択',
    selectRow: '行を選択',
    rowsPerPage: '1 ページの行数',
    range: '{total} 件中 {start}–{end} 件',
    selected: '{count} 件を選択中',
    empty: 'データがありません'
  },
  color: {
    area: '彩度と明度',
    hue: '色相',
    alpha: '不透明度',
    value: 'カラー値',
    swatches: 'プリセットの色',
    clear: 'クリア',
    empty: '色を選択'
  },
  rating: {
    label: '評価',
    value: '{max} 段階中 {value}',
    empty: '評価なし'
  },
  number: {
    increase: '増やす',
    decrease: '減らす'
  },
  pagination: {
    label: 'ページ送り',
    page: '{page} ページ',
    status: '{total} ページ中 {page} ページ',
    previous: '前のページ',
    next: '次のページ',
    first: '最初のページ',
    last: '最後のページ'
  },
  carousel: {
    label: 'カルーセル',
    slide: '{total} 枚中 {index} 枚目',
    previous: '前のスライド',
    next: '次のスライド'
  },
  scroll: { previous: '前へスクロール', next: '次へスクロール' },
  breadcrumb: {
    label: 'パンくずリスト',
    expand: '省略された階層を表示'
  },
  combobox: {
    empty: '一致する項目がありません',
    remove: '{label} を削除'
  },
  overlay: {
    label: 'オーバーレイ'
  },
  window: {
    minimize: '最小化',
    maximize: '最大化',
    restore: '元のサイズに戻す',
    resize: 'ウィンドウのサイズを変更'
  }
};
