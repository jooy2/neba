/**
 * Traditional Chinese.
 *
 * Keyed by script rather than by region: `zh-TW`, `zh-HK` and `zh-MO` all
 * resolve to this one.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, zhHant } from 'neba/locales';
 *
 * registerMessages('zh-hant', zhHant);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const zhHant: NebaLocale = {
  action: {
    close: '關閉',
    dismiss: '關閉',
    clear: '清除',
    remove: '移除'
  },
  link: { newTab: '(在新分頁中開啟)' },
  spoiler: {
    reveal: '顯示內容',
    hide: '隱藏',
    notice: '此內容可能包含劇透'
  },
  chat: {
    sending: '傳送中',
    sent: '已傳送',
    delivered: '已送達',
    read: '已讀',
    failed: '傳送失敗',
    typing: '正在輸入…'
  },
  empty: { title: '沒有內容' },
  table: {
    search: '搜尋',
    selectAll: '全選所有列',
    selectRow: '選擇此列',
    rowsPerPage: '每頁列數',
    range: '第 {start}–{end} 列，共 {total} 列',
    selected: '已選擇 {count} 列',
    empty: '沒有資料'
  },
  color: {
    area: '飽和度與明度',
    hue: '色相',
    alpha: '不透明度',
    value: '顏色值',
    swatches: '預設顏色',
    clear: '清除',
    empty: '選擇顏色'
  },
  rating: {
    label: '評分',
    value: '{max} 分中的 {value} 分',
    empty: '未評分'
  },
  number: {
    increase: '增加',
    decrease: '減少'
  },
  pagination: {
    label: '分頁',
    page: '第 {page} 頁',
    status: '第 {page} 頁，共 {total} 頁',
    previous: '上一頁',
    next: '下一頁',
    first: '第一頁',
    last: '最後一頁'
  },
  carousel: {
    label: '輪播',
    slide: '第 {index} 張，共 {total} 張',
    previous: '上一張',
    next: '下一張'
  },
  scroll: { previous: '向前捲動', next: '向後捲動' },
  breadcrumb: {
    label: '麵包屑導覽',
    expand: '顯示隱藏的層級'
  },
  combobox: {
    empty: '沒有相符的項目',
    remove: '移除 {label}'
  },
  overlay: {
    label: '遮罩層'
  },
  window: {
    minimize: '最小化',
    maximize: '最大化',
    restore: '還原',
    resize: '調整視窗大小'
  },
  layout: {
    skipToContent: '跳至主要內容',
    sidebar: '側邊欄',
    openSidebar: '開啟側邊欄',
    closeSidebar: '關閉側邊欄',
    resizeSidebar: '調整側邊欄寬度'
  },
  code: {
    code: '程式碼',
    copy: '複製',
    copied: '已複製',
    copyFailed: '無法複製',
    raw: '原始',
    prompt: '提示符號'
  },
  steps: {
    previous: '上一步',
    next: '下一步',
    done: '完成',
    restart: '重新開始',
    completed: '所有步驟已完成',
    steps: '步驟',
    position: '第 {index} 步，共 {total} 步',
    step: '第 {index} 步：{title}'
  }
};
