/**
 * Thai.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, th } from 'neba/locales';
 *
 * registerMessages('th', th);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const th: NebaLocale = {
  action: {
    close: 'ปิด',
    dismiss: 'ปิดการแจ้งเตือน',
    clear: 'ล้าง',
    remove: 'นำออก'
  },
  link: { newTab: '(เปิดในแท็บใหม่)' },
  spoiler: {
    reveal: 'แสดงเนื้อหา',
    hide: 'ซ่อน',
    notice: 'อาจมีการเปิดเผยเนื้อหา'
  },
  chat: {
    sending: 'กำลังส่ง',
    sent: 'ส่งแล้ว',
    delivered: 'ส่งถึงแล้ว',
    read: 'อ่านแล้ว',
    failed: 'ส่งไม่สำเร็จ',
    typing: 'กำลังพิมพ์…'
  },
  empty: { title: 'ไม่มีอะไรที่นี่' },
  table: {
    search: 'ค้นหา',
    selectAll: 'เลือกทุกแถว',
    selectRow: 'เลือกแถวนี้',
    rowsPerPage: 'จำนวนแถวต่อหน้า',
    range: '{start}–{end} จาก {total}',
    selected: 'เลือกแล้ว {count} รายการ',
    empty: 'ไม่มีข้อมูล'
  },
  color: {
    area: 'ความอิ่มตัวและความสว่าง',
    hue: 'เฉดสี',
    alpha: 'ความทึบ',
    value: 'ค่าสี',
    swatches: 'สีที่กำหนดไว้',
    clear: 'ล้าง',
    empty: 'เลือกสี'
  },
  rating: {
    label: 'คะแนน',
    value: '{value} จาก {max}',
    empty: 'ยังไม่มีคะแนน'
  },
  number: {
    increase: 'เพิ่ม',
    decrease: 'ลด'
  },
  pagination: {
    label: 'การแบ่งหน้า',
    page: 'หน้า {page}',
    status: 'หน้า {page} จาก {total}',
    previous: 'หน้าก่อนหน้า',
    next: 'หน้าถัดไป',
    first: 'หน้าแรก',
    last: 'หน้าสุดท้าย'
  },
  carousel: {
    label: 'ภาพเลื่อน',
    slide: 'สไลด์ {index} จาก {total}',
    previous: 'สไลด์ก่อนหน้า',
    next: 'สไลด์ถัดไป'
  },
  chart: { label: 'แผนภูมิ' },
  scroll: { previous: 'เลื่อนย้อนกลับ', next: 'เลื่อนไปข้างหน้า' },
  breadcrumb: {
    label: 'เส้นทางนำทาง',
    expand: 'แสดงขั้นตอนที่ซ่อนอยู่'
  },
  anchor: { label: 'ในหน้านี้' },
  transfer: {
    source: 'ที่มีอยู่',
    target: 'ที่เลือก',
    toTarget: 'ย้ายไปที่เลือก',
    toSource: 'ย้ายกลับไปที่มีอยู่',
    search: 'ค้นหา',
    selectAll: 'เลือกทั้งหมด',
    empty: 'ไม่มีรายการ'
  },
  command: {
    label: 'แผงคำสั่ง',
    search: 'พิมพ์คำสั่งหรือค้นหา…',
    empty: 'ไม่พบคำสั่ง'
  },
  combobox: {
    empty: 'ไม่พบรายการที่ตรงกัน',
    remove: 'นำ {label} ออก'
  },
  overlay: {
    label: 'เลเยอร์ซ้อน'
  },
  window: {
    minimize: 'ย่อ',
    maximize: 'ขยาย',
    restore: 'คืนค่า',
    resize: 'ปรับขนาดหน้าต่าง'
  },
  layout: {
    skipToContent: 'ข้ามไปยังเนื้อหา',
    sidebar: 'แถบด้านข้าง',
    openSidebar: 'เปิดแถบด้านข้าง',
    closeSidebar: 'ปิดแถบด้านข้าง',
    resizeSidebar: 'ปรับขนาดแถบด้านข้าง'
  },
  code: {
    code: 'โค้ด',
    copy: 'คัดลอก',
    copied: 'คัดลอกแล้ว',
    copyFailed: 'คัดลอกไม่ได้',
    raw: 'ต้นฉบับ',
    prompt: 'พร้อมต์'
  },
  steps: {
    previous: 'ก่อนหน้า',
    next: 'ถัดไป',
    done: 'เสร็จสิ้น',
    skip: 'ข้าม',
    restart: 'เริ่มใหม่',
    completed: 'ครบทุกขั้นตอนแล้ว',
    steps: 'ขั้นตอน',
    position: '{index} จาก {total}',
    step: 'ขั้นตอนที่ {index}: {title}'
  }
};
