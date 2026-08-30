/**
 * Simplified Chinese.
 *
 * Keyed by script rather than by region: `zh-CN`, `zh-SG` and `zh-MY` all
 * resolve to this one.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, zhHans } from 'neba/locales';
 *
 * registerMessages('zh-hans', zhHans);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const zhHans: NebaLocale = {
  action: {
    close: '关闭',
    dismiss: '关闭',
    clear: '清除',
    remove: '移除'
  },
  link: { newTab: '(在新标签页中打开)' },
  spoiler: {
    reveal: '显示内容',
    hide: '隐藏',
    notice: '此内容可能包含剧透'
  },
  chat: {
    sending: '发送中',
    sent: '已发送',
    delivered: '已送达',
    read: '已读',
    failed: '发送失败',
    typing: '正在输入…'
  },
  empty: { title: '暂无内容' },
  table: {
    search: '搜索',
    selectAll: '全选所有行',
    selectRow: '选择此行',
    rowsPerPage: '每页行数',
    range: '第 {start}–{end} 行，共 {total} 行',
    selected: '已选择 {count} 行',
    empty: '暂无数据'
  },
  color: {
    area: '饱和度和明度',
    hue: '色相',
    alpha: '不透明度',
    value: '颜色值',
    swatches: '预设颜色',
    clear: '清除',
    empty: '选择颜色'
  },
  rating: {
    label: '评分',
    value: '{max} 分中的 {value} 分',
    empty: '未评分'
  },
  number: {
    increase: '增加',
    decrease: '减少'
  },
  pagination: {
    label: '分页',
    page: '第 {page} 页',
    status: '第 {page} 页，共 {total} 页',
    previous: '上一页',
    next: '下一页',
    first: '第一页',
    last: '最后一页'
  },
  carousel: {
    label: '轮播',
    slide: '第 {index} 张，共 {total} 张',
    previous: '上一张',
    next: '下一张'
  },
  scroll: { previous: '向前滚动', next: '向后滚动' },
  breadcrumb: {
    label: '面包屑导航',
    expand: '显示隐藏的层级'
  },
  anchor: { label: '本页内容' },
  transfer: {
    source: '可选',
    target: '已选',
    toTarget: '移到已选',
    toSource: '移回可选',
    search: '搜索',
    selectAll: '全选',
    empty: '这里没有内容'
  },
  combobox: {
    empty: '无匹配项',
    remove: '移除 {label}'
  },
  overlay: {
    label: '遮罩层'
  },
  window: {
    minimize: '最小化',
    maximize: '最大化',
    restore: '向下还原',
    resize: '调整窗口大小'
  },
  layout: {
    skipToContent: '跳到主要内容',
    sidebar: '侧边栏',
    openSidebar: '打开侧边栏',
    closeSidebar: '关闭侧边栏',
    resizeSidebar: '调整侧边栏宽度'
  },
  code: {
    code: '代码',
    copy: '复制',
    copied: '已复制',
    copyFailed: '无法复制',
    raw: '原始',
    prompt: '提示符'
  },
  steps: {
    previous: '上一步',
    next: '下一步',
    done: '完成',
    skip: '跳过',
    restart: '重新开始',
    completed: '所有步骤已完成',
    steps: '步骤',
    position: '第 {index} 步，共 {total} 步',
    step: '第 {index} 步：{title}'
  }
};
