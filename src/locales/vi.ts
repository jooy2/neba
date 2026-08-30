/**
 * Vietnamese.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, vi } from 'neba/locales';
 *
 * registerMessages('vi', vi);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const vi: NebaLocale = {
  action: {
    close: 'Đóng',
    dismiss: 'Bỏ qua',
    clear: 'Xóa',
    remove: 'Gỡ bỏ'
  },
  link: { newTab: '(mở trong tab mới)' },
  spoiler: {
    reveal: 'Hiện nội dung',
    hide: 'Ẩn',
    notice: 'Có thể chứa nội dung tiết lộ'
  },
  chat: {
    sending: 'Đang gửi',
    sent: 'Đã gửi',
    delivered: 'Đã nhận',
    read: 'Đã xem',
    failed: 'Chưa gửi được',
    typing: 'Đang nhập…'
  },
  empty: { title: 'Không có gì ở đây' },
  table: {
    search: 'Tìm kiếm',
    selectAll: 'Chọn tất cả các hàng',
    selectRow: 'Chọn hàng',
    rowsPerPage: 'Số hàng mỗi trang',
    range: '{start}–{end} trên {total}',
    selected: 'Đã chọn {count}',
    empty: 'Không có dữ liệu'
  },
  color: {
    area: 'Độ bão hòa và độ sáng',
    hue: 'Sắc độ',
    alpha: 'Độ mờ đục',
    value: 'Giá trị màu',
    swatches: 'Màu dựng sẵn',
    clear: 'Xóa',
    empty: 'Chọn màu'
  },
  rating: {
    label: 'Đánh giá',
    value: '{value} trên {max}',
    empty: 'Chưa đánh giá'
  },
  number: {
    increase: 'Tăng',
    decrease: 'Giảm'
  },
  pagination: {
    label: 'Phân trang',
    page: 'Trang {page}',
    status: 'Trang {page} trên {total}',
    previous: 'Trang trước',
    next: 'Trang sau',
    first: 'Trang đầu',
    last: 'Trang cuối'
  },
  carousel: {
    label: 'Băng chuyền',
    slide: 'Trang chiếu {index} trên {total}',
    previous: 'Trang chiếu trước',
    next: 'Trang chiếu sau'
  },
  scroll: { previous: 'Cuộn lùi lại', next: 'Cuộn tới' },
  breadcrumb: {
    label: 'Đường dẫn',
    expand: 'Hiện các bước đã ẩn'
  },
  anchor: { label: 'Trên trang này' },
  transfer: {
    source: 'Có sẵn',
    target: 'Đã chọn',
    toTarget: 'Chuyển sang đã chọn',
    toSource: 'Trả về có sẵn',
    search: 'Tìm kiếm',
    selectAll: 'Chọn tất cả',
    empty: 'Không có gì ở đây'
  },
  combobox: {
    empty: 'Không có kết quả',
    remove: 'Gỡ bỏ {label}'
  },
  overlay: {
    label: 'Lớp phủ'
  },
  window: {
    minimize: 'Thu nhỏ',
    maximize: 'Phóng to',
    restore: 'Khôi phục',
    resize: 'Thay đổi kích thước cửa sổ'
  },
  layout: {
    skipToContent: 'Chuyển đến nội dung',
    sidebar: 'Thanh bên',
    openSidebar: 'Mở thanh bên',
    closeSidebar: 'Đóng thanh bên',
    resizeSidebar: 'Thay đổi kích thước thanh bên'
  },
  code: {
    code: 'Mã',
    copy: 'Sao chép',
    copied: 'Đã sao chép',
    copyFailed: 'Không sao chép được',
    raw: 'Thô',
    prompt: 'Dấu nhắc'
  },
  steps: {
    previous: 'Trước',
    next: 'Tiếp',
    done: 'Xong',
    restart: 'Bắt đầu lại',
    completed: 'Đã hoàn tất mọi bước',
    steps: 'Các bước',
    position: '{index} trên {total}',
    step: 'Bước {index}: {title}'
  }
};
