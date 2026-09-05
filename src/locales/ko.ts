/**
 * Korean.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, ko } from 'neba/locales';
 *
 * registerMessages('ko', ko);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const ko: NebaLocale = {
  action: {
    close: '닫기',
    dismiss: '알림 닫기',
    clear: '지우기',
    remove: '삭제'
  },
  confirm: {
    confirm: '확인',
    cancel: '취소'
  },
  link: { newTab: '(새 창에서 열림)' },
  spoiler: {
    reveal: '내용 보기',
    hide: '숨기기',
    notice: '스포일러가 포함되어 있을 수 있습니다'
  },
  chat: {
    sending: '보내는 중',
    sent: '보냄',
    delivered: '전달됨',
    read: '읽음',
    failed: '전송 실패',
    typing: '입력 중…'
  },
  empty: { title: '내용이 없습니다' },
  table: {
    search: '검색',
    selectAll: '모든 행 선택',
    selectRow: '행 선택',
    rowsPerPage: '페이지당 행 수',
    range: '전체 {total}개 중 {start}–{end}',
    selected: '{count}개 선택됨',
    empty: '데이터 없음',
    exportCsv: 'CSV 내보내기'
  },
  color: {
    area: '채도와 명도',
    hue: '색상',
    alpha: '불투명도',
    value: '색상 값',
    swatches: '기본 색상',
    clear: '지우기',
    empty: '색상 선택'
  },
  rating: {
    label: '별점',
    value: '{max}점 만점에 {value}점',
    empty: '별점 없음'
  },
  number: {
    increase: '값 늘리기',
    decrease: '값 줄이기'
  },
  pagination: {
    label: '페이지 매기기',
    page: '{page}페이지',
    status: '전체 {total}페이지 중 {page}페이지',
    previous: '이전 페이지',
    next: '다음 페이지',
    first: '첫 페이지',
    last: '마지막 페이지'
  },
  carousel: {
    label: '캐러셀',
    slide: '전체 {total}장 중 {index}장',
    previous: '이전 슬라이드',
    next: '다음 슬라이드',
    pause: '슬라이드 쇼 일시정지',
    play: '슬라이드 쇼 재생'
  },
  gallery: {
    label: '갤러리',
    item: '전체 {total}장 중 {index}장',
    previous: '이전 이미지',
    next: '다음 이미지'
  },
  image: { unavailable: '이미지를 불러올 수 없습니다' },
  chart: { label: '차트' },
  scroll: { label: '스크롤 영역', previous: '뒤로 스크롤', next: '앞으로 스크롤' },
  breadcrumb: {
    label: '탐색 경로',
    expand: '숨겨진 단계 보기'
  },
  anchor: { label: '이 페이지의 내용' },
  transfer: {
    source: '선택 가능',
    target: '선택함',
    toTarget: '선택함으로 이동',
    toSource: '선택 가능으로 되돌리기',
    search: '검색',
    selectAll: '모두 선택',
    empty: '항목이 없습니다'
  },
  command: {
    label: '명령 팔레트',
    search: '명령을 입력하거나 검색하세요…',
    empty: '명령을 찾을 수 없습니다'
  },
  combobox: {
    empty: '일치하는 항목 없음',
    remove: '{label} 삭제'
  },
  overlay: {
    label: '오버레이'
  },
  window: {
    minimize: '최소화',
    maximize: '최대화',
    restore: '이전 크기로 복원',
    resize: '창 크기 조절'
  },
  layout: {
    skipToContent: '본문으로 건너뛰기',
    sidebar: '사이드바',
    openSidebar: '사이드바 열기',
    closeSidebar: '사이드바 닫기',
    resizeSidebar: '사이드바 크기 조절'
  },
  code: {
    code: '코드',
    copy: '복사',
    copied: '복사됨',
    copyFailed: '복사할 수 없음',
    raw: '원본',
    prompt: '프롬프트'
  },
  steps: {
    previous: '이전',
    next: '다음',
    done: '완료',
    skip: '건너뛰기',
    restart: '처음으로',
    completed: '모든 단계를 마쳤습니다',
    steps: '단계',
    position: '{total}단계 중 {index}단계',
    step: '{index}단계: {title}'
  }
};
