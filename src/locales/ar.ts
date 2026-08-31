/**
 * Arabic.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, ar } from 'neba/locales';
 *
 * registerMessages('ar', ar);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const ar: NebaLocale = {
  action: {
    close: 'إغلاق',
    dismiss: 'تجاهل',
    clear: 'مسح',
    remove: 'إزالة'
  },
  confirm: {
    confirm: 'تأكيد',
    cancel: 'إلغاء'
  },
  link: { newTab: '(يفتح في علامة تبويب جديدة)' },
  spoiler: {
    reveal: 'إظهار',
    hide: 'إخفاء',
    notice: 'قد يحتوي على حرق للأحداث'
  },
  chat: {
    sending: 'جارٍ الإرسال',
    sent: 'تم الإرسال',
    delivered: 'تم التسليم',
    read: 'تمت القراءة',
    failed: 'لم يتم الإرسال',
    typing: 'يكتب الآن…'
  },
  empty: { title: 'لا يوجد شيء هنا' },
  table: {
    search: 'بحث',
    selectAll: 'تحديد كل الصفوف',
    selectRow: 'تحديد الصف',
    rowsPerPage: 'صفوف لكل صفحة',
    range: '{start}–{end} من {total}',
    selected: 'تم تحديد {count}',
    empty: 'لا توجد بيانات',
    exportCsv: 'تصدير CSV'
  },
  color: {
    area: 'التشبع والسطوع',
    hue: 'درجة اللون',
    alpha: 'العتامة',
    value: 'قيمة اللون',
    swatches: 'ألوان جاهزة',
    clear: 'مسح',
    empty: 'اختر لونًا'
  },
  rating: {
    label: 'التقييم',
    value: '{value} من {max}',
    empty: 'بدون تقييم'
  },
  number: {
    increase: 'زيادة',
    decrease: 'إنقاص'
  },
  pagination: {
    label: 'ترقيم الصفحات',
    page: 'الصفحة {page}',
    status: 'الصفحة {page} من {total}',
    previous: 'الصفحة السابقة',
    next: 'الصفحة التالية',
    first: 'الصفحة الأولى',
    last: 'الصفحة الأخيرة'
  },
  carousel: {
    label: 'شريط عرض',
    slide: 'الشريحة {index} من {total}',
    previous: 'الشريحة السابقة',
    next: 'الشريحة التالية'
  },
  chart: { label: 'رسم بياني' },
  scroll: { label: 'محتوى قابل للتمرير', previous: 'التمرير للخلف', next: 'التمرير للأمام' },
  breadcrumb: {
    label: 'مسار التنقل',
    expand: 'إظهار الخطوات المخفية'
  },
  anchor: { label: 'في هذه الصفحة' },
  transfer: {
    source: 'المتاح',
    target: 'المحدد',
    toTarget: 'النقل إلى المحدد',
    toSource: 'الإرجاع إلى المتاح',
    search: 'بحث',
    selectAll: 'تحديد الكل',
    empty: 'لا شيء هنا'
  },
  command: {
    label: 'لوحة الأوامر',
    search: 'اكتب أمراً أو ابحث…',
    empty: 'لا توجد أوامر مطابقة'
  },
  combobox: {
    empty: 'لا توجد نتائج مطابقة',
    remove: 'إزالة {label}'
  },
  overlay: {
    label: 'تراكب'
  },
  window: {
    minimize: 'تصغير',
    maximize: 'تكبير',
    restore: 'استعادة',
    resize: 'تغيير حجم النافذة'
  },
  layout: {
    skipToContent: 'تخطي إلى المحتوى',
    sidebar: 'الشريط الجانبي',
    openSidebar: 'فتح الشريط الجانبي',
    closeSidebar: 'إغلاق الشريط الجانبي',
    resizeSidebar: 'تغيير حجم الشريط الجانبي'
  },
  code: {
    code: 'شفرة',
    copy: 'نسخ',
    copied: 'تم النسخ',
    copyFailed: 'تعذّر النسخ',
    raw: 'خام',
    prompt: 'موجّه الأوامر'
  },
  steps: {
    previous: 'السابق',
    next: 'التالي',
    done: 'تم',
    skip: 'تخطي',
    restart: 'البدء من جديد',
    completed: 'اكتملت جميع الخطوات',
    steps: 'الخطوات',
    position: '{index} من {total}',
    step: 'الخطوة {index}: {title}'
  }
};
