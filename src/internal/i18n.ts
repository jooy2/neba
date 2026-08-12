/**
 * The words the library says on its own behalf.
 *
 * Almost nothing in Neba writes text a reader sees — a Button says whatever it
 * was handed, a Card's title is the caller's. The exceptions are the strings a
 * component has to invent because there is nowhere else for them to come from:
 * the sentence behind a link that opens a new tab, the label on the button that
 * uncovers a Spoiler, the word under a chat message that says it was read.
 *
 * Those are collected here rather than defaulted inside each component, for the
 * reason every other table in `internal/` exists: they are a set. A product in
 * Korean does not want eight components each defaulting to English and each
 * needing its own override prop, and the next component that needs a word —
 * a picker's "Today", a Pagination's "Next page" — should get it from the same
 * place rather than starting a second table beside this one.
 *
 * What is *not* in here is anything `Intl` already knows. Month names, weekday
 * names, AM/PM and number formats come from the platform, which speaks more
 * languages than this file ever will. This is only for the words the platform
 * has no opinion about.
 *
 * Every component that reads this takes a `locale` and an override prop for the
 * string itself, so an unsupported language is never a dead end: `locale` gets
 * you a translation for free, and the prop gets you one for anything else.
 */

import * as React from 'react';

/**
 * One namespace per component, rather than one flat list of keys.
 *
 * A namespace is what makes a partial translation possible: a locale supplies
 * whatever it has and the rest falls back to English one namespace at a time,
 * so adding a namespace here does not silently blank the strings in every
 * language that has not caught up with it yet.
 */
export interface NebaMessages {
  /**
   * The words more than one component needs.
   *
   * The one namespace here that is not a component, and it exists because five
   * of them draw the same × and would otherwise each carry their own "Close" in
   * eighteen languages. A reader meeting that button on a Dialog, a Drawer, a
   * Popover and a Toast should hear the same word every time, which is easier to
   * guarantee when there is only one of it.
   */
  action: {
    /** The × on a Dialog, a Drawer, a Popover and a Toast. */
    close: string;
    /**
     * And the one on an Alert, which is a different act: a dialog is closed
     * because it has been answered, an alert is waved away.
     */
    dismiss: string;
    /** The × that empties a Combobox. */
    clear: string;
    /** The × on a Chip. */
    remove: string;
  };
  /** TextLink. */
  link: {
    /**
     * What is read out after a link that opens a new tab, and never drawn. A
     * window changing under the reader is the one thing about a link that is
     * invisible until it has already happened.
     */
    newTab: string;
  };
  /** Spoiler. */
  spoiler: {
    /** The button that uncovers the content. */
    reveal: string;
    /** And the one that covers it again, when the Spoiler is reversible. */
    hide: string;
    /** The line above the button, saying why the content is covered. */
    notice: string;
  };
  /** ChatBubble. */
  chat: {
    /** The four steps a message goes through, as the mark under it. */
    sending: string;
    sent: string;
    delivered: string;
    read: string;
    /** And the fifth, which is not a step: it did not go. */
    failed: string;
    /** What the three dots mean. */
    typing: string;
  };
  /** Empty. */
  empty: {
    /**
     * The headline over a region with nothing in it.
     *
     * The one string in here that is *drawn* at full size rather than read out
     * or written on a button, and it is here for the same reason the rest are:
     * an empty state has nothing to take its words from. What is missing is the
     * caller's — a search, an inbox, a folder — so the default says only that
     * there is nothing, and anything more specific is the `title` prop.
     */
    title: string;
  };
  /**
   * DataTable.
   *
   * A DataTable is the one component in the library that draws chrome of its
   * own — a search field, a header tick that chooses everything at once, a
   * footer counting what is on screen — so it is also the one that has the most
   * to say without being handed the words.
   */
  table: {
    /** Placeholder and accessible name of the search field. */
    search: string;
    /** The tick in the header row, which chooses every row at once. */
    selectAll: string;
    /** The tick on a row. */
    selectRow: string;
    /** Beside the footer's page-size Select. */
    rowsPerPage: string;
    /**
     * Which rows are on screen, out of how many there are. `{start}`, `{end}`
     * and `{total}` are replaced with the numbers, already formatted for the
     * locale — a template rather than three fragments, because the order the
     * three appear in is exactly what differs between languages.
     */
    range: string;
    /** How many rows are chosen. `{count}` is replaced the same way. */
    selected: string;
    /**
     * What a table with no rows in it says. Shared with Table, which has the
     * same nothing to report and no chrome of its own to say it with.
     */
    empty: string;
  };
  /**
   * ColorPicker.
   *
   * All but one of these are names for something with no text on it: a square
   * of colour, two rails, a grid of swatches. A control a sighted reader
   * understands from a glance at a gradient is a control that says nothing at
   * all without them, which makes this the one namespace here where the strings
   * are the entire accessible interface rather than a convenience on top of it.
   */
  color: {
    /** The saturation/brightness square. */
    area: string;
    /** The rail beside it. */
    hue: string;
    /** The rail below that, when `alpha` is on. */
    alpha: string;
    /** The field the colour can be typed into. */
    value: string;
    /** The grid of ready-made colours. */
    swatches: string;
    /** The × that empties the control. */
    clear: string;
    /** What the trigger reads before anything has been chosen. */
    empty: string;
  };
  /**
   * Rating.
   *
   * A row of stars is the same case the ColorPicker's rails are: the whole
   * control is a picture, and without these it says nothing at all to a reader
   * who is not looking at it.
   */
  rating: {
    /** Names the group, when the caller has not named it themselves. */
    label: string;
    /**
     * What one star — and the whole control, once it is read only — is called.
     * `{value}` and `{max}` are replaced with the numbers, already formatted
     * for the locale.
     *
     * A sentence with both numbers in it rather than "3 stars", because a count
     * of stars is a plural in most languages and a fraction in none of them:
     * "3 out of 5" is one string per locale, and "3 stars" is one per locale
     * per plural form.
     */
    value: string;
    /** And what it is called before anything has been chosen. */
    empty: string;
  };
  /**
   * NumberField.
   *
   * Two buttons with an arrow on each and nothing else, which is the same case
   * the ColorPicker's rails are.
   */
  number: {
    /** The stepper that goes up. */
    increase: string;
    /** And the one that goes down. */
    decrease: string;
  };
  /**
   * Pagination.
   *
   * Every string here names a control that is a number or an arrow, so without
   * them the row reads out as a list of digits with no idea what they page
   * through.
   */
  pagination: {
    /** Names the `<nav>` landmark. */
    label: string;
    /** One page button. `{page}` is replaced with the number. */
    page: string;
    /**
     * Where the reader is, read out rather than drawn. `{page}` and `{total}`
     * are both replaced — one sentence rather than two fragments, because a
     * count of pages and the page you are on go in opposite orders depending on
     * the language.
     */
    status: string;
    previous: string;
    next: string;
    first: string;
    last: string;
  };
  /** Carousel. */
  carousel: {
    /** Names the region, beside the `carousel` roledescription. */
    label: string;
    /** One slide. `{index}` and `{total}` are replaced with the numbers. */
    slide: string;
    previous: string;
    next: string;
  };
  /** Breadcrumb. */
  breadcrumb: {
    /** Names the `<nav>` landmark. */
    label: string;
    /** The `…` that puts the folded middle of the trail back. */
    expand: string;
  };
  /** Combobox. */
  combobox: {
    /** The line where the list would be, when nothing matched what was typed. */
    empty: string;
    /** The × on one chosen entry. `{label}` is replaced with its own label. */
    remove: string;
  };
  /** Overlay. */
  overlay: {
    /** Names the sheet that covers whatever it was wrapped around. */
    label: string;
  };
}

/** A translation may fill in as much or as little of the table as it has. */
type PartialMessages = {
  [Namespace in keyof NebaMessages]?: Partial<NebaMessages[Namespace]>;
};

/**
 * English is the base, and the only entry that is complete by construction —
 * every other locale is merged over it, so a missing string is an English one
 * rather than an empty box.
 */
const base: NebaMessages = {
  action: {
    close: 'Close',
    dismiss: 'Dismiss',
    clear: 'Clear',
    remove: 'Remove'
  },
  link: {
    newTab: '(opens in a new tab)'
  },
  spoiler: {
    reveal: 'Reveal',
    hide: 'Hide',
    notice: 'This may contain spoilers'
  },
  chat: {
    sending: 'Sending',
    sent: 'Sent',
    delivered: 'Delivered',
    read: 'Read',
    failed: 'Not sent',
    typing: 'Typing…'
  },
  empty: { title: 'Nothing here' },
  table: {
    search: 'Search',
    selectAll: 'Select all rows',
    selectRow: 'Select row',
    rowsPerPage: 'Rows per page',
    range: '{start}–{end} of {total}',
    selected: '{count} selected',
    empty: 'No data'
  },
  color: {
    area: 'Saturation and brightness',
    hue: 'Hue',
    alpha: 'Opacity',
    value: 'Colour value',
    swatches: 'Preset colours',
    clear: 'Clear',
    empty: 'Choose a colour'
  },
  rating: {
    label: 'Rating',
    value: '{value} out of {max}',
    empty: 'No rating'
  },
  number: {
    increase: 'Increase',
    decrease: 'Decrease'
  },
  pagination: {
    label: 'Pagination',
    page: 'Page {page}',
    status: 'Page {page} of {total}',
    previous: 'Previous page',
    next: 'Next page',
    first: 'First page',
    last: 'Last page'
  },
  carousel: {
    label: 'Carousel',
    slide: 'Slide {index} of {total}',
    previous: 'Previous slide',
    next: 'Next slide'
  },
  breadcrumb: {
    label: 'Breadcrumb',
    expand: 'Show hidden steps'
  },
  combobox: {
    empty: 'No matches',
    remove: 'Remove {label}'
  },
  overlay: {
    label: 'Overlay'
  }
};

/**
 * The translations, keyed by the lowercased tag they answer to.
 *
 * Chinese is keyed by script rather than by region, because that is the axis
 * the words actually differ on — `zh-TW` and `zh-HK` want the same characters
 * as each other and different ones from `zh-CN`. The regions are mapped onto
 * the two scripts below.
 */
const translations: Record<string, PartialMessages> = {
  ko: {
    action: {
      close: '닫기',
      dismiss: '알림 닫기',
      clear: '지우기',
      remove: '삭제'
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
      empty: '데이터 없음'
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
      next: '다음 슬라이드'
    },
    breadcrumb: {
      label: '탐색 경로',
      expand: '숨겨진 단계 보기'
    },
    combobox: {
      empty: '일치하는 항목 없음',
      remove: '{label} 삭제'
    },
    overlay: {
      label: '오버레이'
    }
  },
  ja: {
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
    }
  },
  'zh-hans': {
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
    breadcrumb: {
      label: '面包屑导航',
      expand: '显示隐藏的层级'
    },
    combobox: {
      empty: '无匹配项',
      remove: '移除 {label}'
    },
    overlay: {
      label: '遮罩层'
    }
  },
  'zh-hant': {
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
    }
  },
  es: {
    action: {
      close: 'Cerrar',
      dismiss: 'Descartar',
      clear: 'Borrar',
      remove: 'Quitar'
    },
    link: { newTab: '(se abre en una pestaña nueva)' },
    spoiler: {
      reveal: 'Mostrar',
      hide: 'Ocultar',
      notice: 'Puede contener spoilers'
    },
    chat: {
      sending: 'Enviando',
      sent: 'Enviado',
      delivered: 'Entregado',
      read: 'Leído',
      failed: 'No enviado',
      typing: 'Escribiendo…'
    },
    empty: { title: 'No hay nada aquí' },
    table: {
      search: 'Buscar',
      selectAll: 'Seleccionar todas las filas',
      selectRow: 'Seleccionar fila',
      rowsPerPage: 'Filas por página',
      range: '{start}–{end} de {total}',
      selected: '{count} seleccionadas',
      empty: 'Sin datos'
    },
    color: {
      area: 'Saturación y brillo',
      hue: 'Tono',
      alpha: 'Opacidad',
      value: 'Valor del color',
      swatches: 'Colores predefinidos',
      clear: 'Borrar',
      empty: 'Elegir un color'
    },
    rating: {
      label: 'Valoración',
      value: '{value} de {max}',
      empty: 'Sin valoración'
    },
    number: {
      increase: 'Aumentar',
      decrease: 'Disminuir'
    },
    pagination: {
      label: 'Paginación',
      page: 'Página {page}',
      status: 'Página {page} de {total}',
      previous: 'Página anterior',
      next: 'Página siguiente',
      first: 'Primera página',
      last: 'Última página'
    },
    carousel: {
      label: 'Carrusel',
      slide: 'Diapositiva {index} de {total}',
      previous: 'Diapositiva anterior',
      next: 'Diapositiva siguiente'
    },
    breadcrumb: {
      label: 'Ruta de navegación',
      expand: 'Mostrar los pasos ocultos'
    },
    combobox: {
      empty: 'Sin coincidencias',
      remove: 'Quitar {label}'
    },
    overlay: {
      label: 'Superposición'
    }
  },
  pt: {
    action: {
      close: 'Fechar',
      dismiss: 'Dispensar',
      clear: 'Limpar',
      remove: 'Remover'
    },
    link: { newTab: '(abre em uma nova aba)' },
    spoiler: {
      reveal: 'Mostrar',
      hide: 'Ocultar',
      notice: 'Pode conter spoilers'
    },
    chat: {
      sending: 'Enviando',
      sent: 'Enviado',
      delivered: 'Entregue',
      read: 'Lido',
      failed: 'Não enviado',
      typing: 'Digitando…'
    },
    empty: { title: 'Nada por aqui' },
    table: {
      search: 'Pesquisar',
      selectAll: 'Selecionar todas as linhas',
      selectRow: 'Selecionar linha',
      rowsPerPage: 'Linhas por página',
      range: '{start}–{end} de {total}',
      selected: '{count} selecionadas',
      empty: 'Sem dados'
    },
    color: {
      area: 'Saturação e brilho',
      hue: 'Matiz',
      alpha: 'Opacidade',
      value: 'Valor da cor',
      swatches: 'Cores predefinidas',
      clear: 'Limpar',
      empty: 'Escolher uma cor'
    },
    rating: {
      label: 'Avaliação',
      value: '{value} de {max}',
      empty: 'Sem avaliação'
    },
    number: {
      increase: 'Aumentar',
      decrease: 'Diminuir'
    },
    pagination: {
      label: 'Paginação',
      page: 'Página {page}',
      status: 'Página {page} de {total}',
      previous: 'Página anterior',
      next: 'Próxima página',
      first: 'Primeira página',
      last: 'Última página'
    },
    carousel: {
      label: 'Carrossel',
      slide: 'Slide {index} de {total}',
      previous: 'Slide anterior',
      next: 'Próximo slide'
    },
    breadcrumb: {
      label: 'Trilha de navegação',
      expand: 'Mostrar as etapas ocultas'
    },
    combobox: {
      empty: 'Nenhuma correspondência',
      remove: 'Remover {label}'
    },
    overlay: {
      label: 'Sobreposição'
    }
  },
  fr: {
    action: {
      close: 'Fermer',
      dismiss: 'Ignorer',
      clear: 'Effacer',
      remove: 'Supprimer'
    },
    link: { newTab: '(s’ouvre dans un nouvel onglet)' },
    spoiler: {
      reveal: 'Afficher',
      hide: 'Masquer',
      notice: 'Peut contenir des spoilers'
    },
    chat: {
      sending: 'Envoi en cours',
      sent: 'Envoyé',
      delivered: 'Distribué',
      read: 'Lu',
      failed: 'Non envoyé',
      typing: 'En train d’écrire…'
    },
    empty: { title: 'Rien ici' },
    table: {
      search: 'Rechercher',
      selectAll: 'Sélectionner toutes les lignes',
      selectRow: 'Sélectionner la ligne',
      rowsPerPage: 'Lignes par page',
      range: '{start}–{end} sur {total}',
      selected: '{count} sélectionnées',
      empty: 'Aucune donnée'
    },
    color: {
      area: 'Saturation et luminosité',
      hue: 'Teinte',
      alpha: 'Opacité',
      value: 'Valeur de la couleur',
      swatches: 'Couleurs prédéfinies',
      clear: 'Effacer',
      empty: 'Choisir une couleur'
    },
    rating: {
      label: 'Note',
      value: '{value} sur {max}',
      empty: 'Aucune note'
    },
    number: {
      increase: 'Augmenter',
      decrease: 'Diminuer'
    },
    pagination: {
      label: 'Pagination',
      page: 'Page {page}',
      status: 'Page {page} sur {total}',
      previous: 'Page précédente',
      next: 'Page suivante',
      first: 'Première page',
      last: 'Dernière page'
    },
    carousel: {
      label: 'Carrousel',
      slide: 'Diapositive {index} sur {total}',
      previous: 'Diapositive précédente',
      next: 'Diapositive suivante'
    },
    breadcrumb: {
      label: 'Fil d’Ariane',
      expand: 'Afficher les étapes masquées'
    },
    combobox: {
      empty: 'Aucun résultat',
      remove: 'Supprimer {label}'
    },
    overlay: {
      label: 'Superposition'
    }
  },
  de: {
    action: {
      close: 'Schließen',
      dismiss: 'Ausblenden',
      clear: 'Löschen',
      remove: 'Entfernen'
    },
    link: { newTab: '(wird in einem neuen Tab geöffnet)' },
    spoiler: {
      reveal: 'Anzeigen',
      hide: 'Ausblenden',
      notice: 'Kann Spoiler enthalten'
    },
    chat: {
      sending: 'Wird gesendet',
      sent: 'Gesendet',
      delivered: 'Zugestellt',
      read: 'Gelesen',
      failed: 'Nicht gesendet',
      typing: 'Schreibt…'
    },
    empty: { title: 'Nichts vorhanden' },
    table: {
      search: 'Suchen',
      selectAll: 'Alle Zeilen auswählen',
      selectRow: 'Zeile auswählen',
      rowsPerPage: 'Zeilen pro Seite',
      range: '{start}–{end} von {total}',
      selected: '{count} ausgewählt',
      empty: 'Keine Daten'
    },
    color: {
      area: 'Sättigung und Helligkeit',
      hue: 'Farbton',
      alpha: 'Deckkraft',
      value: 'Farbwert',
      swatches: 'Vorgegebene Farben',
      clear: 'Löschen',
      empty: 'Farbe auswählen'
    },
    rating: {
      label: 'Bewertung',
      value: '{value} von {max}',
      empty: 'Keine Bewertung'
    },
    number: {
      increase: 'Erhöhen',
      decrease: 'Verringern'
    },
    pagination: {
      label: 'Seitennavigation',
      page: 'Seite {page}',
      status: 'Seite {page} von {total}',
      previous: 'Vorherige Seite',
      next: 'Nächste Seite',
      first: 'Erste Seite',
      last: 'Letzte Seite'
    },
    carousel: {
      label: 'Karussell',
      slide: 'Folie {index} von {total}',
      previous: 'Vorherige Folie',
      next: 'Nächste Folie'
    },
    breadcrumb: {
      label: 'Breadcrumb-Navigation',
      expand: 'Ausgeblendete Schritte anzeigen'
    },
    combobox: {
      empty: 'Keine Treffer',
      remove: '{label} entfernen'
    },
    overlay: {
      label: 'Overlay'
    }
  },
  it: {
    action: {
      close: 'Chiudi',
      dismiss: 'Ignora',
      clear: 'Cancella',
      remove: 'Rimuovi'
    },
    link: { newTab: '(si apre in una nuova scheda)' },
    spoiler: {
      reveal: 'Mostra',
      hide: 'Nascondi',
      notice: 'Può contenere spoiler'
    },
    chat: {
      sending: 'Invio in corso',
      sent: 'Inviato',
      delivered: 'Consegnato',
      read: 'Letto',
      failed: 'Non inviato',
      typing: 'Sta scrivendo…'
    },
    empty: { title: 'Non c’è nulla' },
    table: {
      search: 'Cerca',
      selectAll: 'Seleziona tutte le righe',
      selectRow: 'Seleziona riga',
      rowsPerPage: 'Righe per pagina',
      range: '{start}–{end} di {total}',
      selected: '{count} selezionate',
      empty: 'Nessun dato'
    },
    color: {
      area: 'Saturazione e luminosità',
      hue: 'Tonalità',
      alpha: 'Opacità',
      value: 'Valore del colore',
      swatches: 'Colori predefiniti',
      clear: 'Cancella',
      empty: 'Scegli un colore'
    },
    rating: {
      label: 'Valutazione',
      value: '{value} su {max}',
      empty: 'Nessuna valutazione'
    },
    number: {
      increase: 'Aumenta',
      decrease: 'Diminuisci'
    },
    pagination: {
      label: 'Impaginazione',
      page: 'Pagina {page}',
      status: 'Pagina {page} di {total}',
      previous: 'Pagina precedente',
      next: 'Pagina successiva',
      first: 'Prima pagina',
      last: 'Ultima pagina'
    },
    carousel: {
      label: 'Carosello',
      slide: 'Diapositiva {index} di {total}',
      previous: 'Diapositiva precedente',
      next: 'Diapositiva successiva'
    },
    breadcrumb: {
      label: 'Percorso di navigazione',
      expand: 'Mostra i passaggi nascosti'
    },
    combobox: {
      empty: 'Nessun risultato',
      remove: 'Rimuovi {label}'
    },
    overlay: {
      label: 'Sovrapposizione'
    }
  },
  nl: {
    action: {
      close: 'Sluiten',
      dismiss: 'Negeren',
      clear: 'Wissen',
      remove: 'Verwijderen'
    },
    link: { newTab: '(opent in een nieuw tabblad)' },
    spoiler: {
      reveal: 'Tonen',
      hide: 'Verbergen',
      notice: 'Kan spoilers bevatten'
    },
    chat: {
      sending: 'Wordt verzonden',
      sent: 'Verzonden',
      delivered: 'Afgeleverd',
      read: 'Gelezen',
      failed: 'Niet verzonden',
      typing: 'Aan het typen…'
    },
    empty: { title: 'Hier is niets' },
    table: {
      search: 'Zoeken',
      selectAll: 'Alle rijen selecteren',
      selectRow: 'Rij selecteren',
      rowsPerPage: 'Rijen per pagina',
      range: '{start}–{end} van {total}',
      selected: '{count} geselecteerd',
      empty: 'Geen gegevens'
    },
    color: {
      area: 'Verzadiging en helderheid',
      hue: 'Kleurtoon',
      alpha: 'Dekking',
      value: 'Kleurwaarde',
      swatches: 'Vooraf ingestelde kleuren',
      clear: 'Wissen',
      empty: 'Kies een kleur'
    },
    rating: {
      label: 'Beoordeling',
      value: '{value} van {max}',
      empty: 'Geen beoordeling'
    },
    number: {
      increase: 'Verhogen',
      decrease: 'Verlagen'
    },
    pagination: {
      label: 'Paginering',
      page: 'Pagina {page}',
      status: 'Pagina {page} van {total}',
      previous: 'Vorige pagina',
      next: 'Volgende pagina',
      first: 'Eerste pagina',
      last: 'Laatste pagina'
    },
    carousel: {
      label: 'Carrousel',
      slide: 'Dia {index} van {total}',
      previous: 'Vorige dia',
      next: 'Volgende dia'
    },
    breadcrumb: {
      label: 'Kruimelpad',
      expand: 'Verborgen stappen tonen'
    },
    combobox: {
      empty: 'Geen resultaten',
      remove: '{label} verwijderen'
    },
    overlay: {
      label: 'Overlay'
    }
  },
  pl: {
    action: {
      close: 'Zamknij',
      dismiss: 'Odrzuć',
      clear: 'Wyczyść',
      remove: 'Usuń'
    },
    link: { newTab: '(otwiera się w nowej karcie)' },
    spoiler: {
      reveal: 'Pokaż',
      hide: 'Ukryj',
      notice: 'Może zawierać spoilery'
    },
    chat: {
      sending: 'Wysyłanie',
      sent: 'Wysłano',
      delivered: 'Dostarczono',
      read: 'Przeczytano',
      failed: 'Nie wysłano',
      typing: 'Pisze…'
    },
    empty: { title: 'Nic tu nie ma' },
    table: {
      search: 'Szukaj',
      selectAll: 'Zaznacz wszystkie wiersze',
      selectRow: 'Zaznacz wiersz',
      rowsPerPage: 'Wierszy na stronę',
      range: '{start}–{end} z {total}',
      selected: 'Zaznaczono: {count}',
      empty: 'Brak danych'
    },
    color: {
      area: 'Nasycenie i jasność',
      hue: 'Barwa',
      alpha: 'Krycie',
      value: 'Wartość koloru',
      swatches: 'Kolory predefiniowane',
      clear: 'Wyczyść',
      empty: 'Wybierz kolor'
    },
    rating: {
      label: 'Ocena',
      value: '{value} z {max}',
      empty: 'Brak oceny'
    },
    number: {
      increase: 'Zwiększ',
      decrease: 'Zmniejsz'
    },
    pagination: {
      label: 'Paginacja',
      page: 'Strona {page}',
      status: 'Strona {page} z {total}',
      previous: 'Poprzednia strona',
      next: 'Następna strona',
      first: 'Pierwsza strona',
      last: 'Ostatnia strona'
    },
    carousel: {
      label: 'Karuzela',
      slide: 'Slajd {index} z {total}',
      previous: 'Poprzedni slajd',
      next: 'Następny slajd'
    },
    breadcrumb: {
      label: 'Ścieżka nawigacji',
      expand: 'Pokaż ukryte kroki'
    },
    combobox: {
      empty: 'Brak wyników',
      remove: 'Usuń {label}'
    },
    overlay: {
      label: 'Nakładka'
    }
  },
  ru: {
    action: {
      close: 'Закрыть',
      dismiss: 'Скрыть',
      clear: 'Очистить',
      remove: 'Удалить'
    },
    link: { newTab: '(откроется в новой вкладке)' },
    spoiler: {
      reveal: 'Показать',
      hide: 'Скрыть',
      notice: 'Может содержать спойлеры'
    },
    chat: {
      sending: 'Отправляется',
      sent: 'Отправлено',
      delivered: 'Доставлено',
      read: 'Прочитано',
      failed: 'Не отправлено',
      typing: 'Печатает…'
    },
    empty: { title: 'Здесь пусто' },
    table: {
      search: 'Поиск',
      selectAll: 'Выбрать все строки',
      selectRow: 'Выбрать строку',
      rowsPerPage: 'Строк на странице',
      range: '{start}–{end} из {total}',
      selected: 'Выбрано: {count}',
      empty: 'Нет данных'
    },
    color: {
      area: 'Насыщенность и яркость',
      hue: 'Оттенок',
      alpha: 'Непрозрачность',
      value: 'Значение цвета',
      swatches: 'Готовые цвета',
      clear: 'Очистить',
      empty: 'Выберите цвет'
    },
    rating: {
      label: 'Оценка',
      value: '{value} из {max}',
      empty: 'Без оценки'
    },
    number: {
      increase: 'Увеличить',
      decrease: 'Уменьшить'
    },
    pagination: {
      label: 'Постраничная навигация',
      page: 'Страница {page}',
      status: 'Страница {page} из {total}',
      previous: 'Предыдущая страница',
      next: 'Следующая страница',
      first: 'Первая страница',
      last: 'Последняя страница'
    },
    carousel: {
      label: 'Карусель',
      slide: 'Слайд {index} из {total}',
      previous: 'Предыдущий слайд',
      next: 'Следующий слайд'
    },
    breadcrumb: {
      label: 'Навигационная цепочка',
      expand: 'Показать скрытые шаги'
    },
    combobox: {
      empty: 'Совпадений нет',
      remove: 'Удалить {label}'
    },
    overlay: {
      label: 'Наложение'
    }
  },
  tr: {
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
    breadcrumb: {
      label: 'Gezinti yolu',
      expand: 'Gizli adımları göster'
    },
    combobox: {
      empty: 'Eşleşme yok',
      remove: '{label} kaldır'
    },
    overlay: {
      label: 'Kaplama'
    }
  },
  ar: {
    action: {
      close: 'إغلاق',
      dismiss: 'تجاهل',
      clear: 'مسح',
      remove: 'إزالة'
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
      empty: 'لا توجد بيانات'
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
    breadcrumb: {
      label: 'مسار التنقل',
      expand: 'إظهار الخطوات المخفية'
    },
    combobox: {
      empty: 'لا توجد نتائج مطابقة',
      remove: 'إزالة {label}'
    },
    overlay: {
      label: 'تراكب'
    }
  },
  hi: {
    action: {
      close: 'बंद करें',
      dismiss: 'खारिज करें',
      clear: 'साफ़ करें',
      remove: 'हटाएँ'
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
      empty: 'कोई डेटा नहीं'
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
    breadcrumb: {
      label: 'ब्रेडक्रंब',
      expand: 'छिपे हुए चरण दिखाएँ'
    },
    combobox: {
      empty: 'कोई मिलान नहीं',
      remove: '{label} हटाएँ'
    },
    overlay: {
      label: 'ओवरले'
    }
  },
  id: {
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
    breadcrumb: {
      label: 'Remah roti',
      expand: 'Tampilkan langkah tersembunyi'
    },
    combobox: {
      empty: 'Tidak ada yang cocok',
      remove: 'Hapus {label}'
    },
    overlay: {
      label: 'Hamparan'
    }
  },
  vi: {
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
    breadcrumb: {
      label: 'Đường dẫn',
      expand: 'Hiện các bước đã ẩn'
    },
    combobox: {
      empty: 'Không có kết quả',
      remove: 'Gỡ bỏ {label}'
    },
    overlay: {
      label: 'Lớp phủ'
    }
  },
  th: {
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
    breadcrumb: {
      label: 'เส้นทางนำทาง',
      expand: 'แสดงขั้นตอนที่ซ่อนอยู่'
    },
    combobox: {
      empty: 'ไม่พบรายการที่ตรงกัน',
      remove: 'นำ {label} ออก'
    },
    overlay: {
      label: 'เลเยอร์ซ้อน'
    }
  }
};

/**
 * The tags that are a different spelling of an entry above.
 *
 * Only the Chinese ones for now, and they are the reason the table is keyed by
 * script: a reader in Taipei asking for `zh-TW` and one in Hong Kong asking for
 * `zh-HK` want the same words, and a table keyed by region would hold that pair
 * twice. Bare `zh` resolves to Simplified, which is what every other library
 * that has had to pick one has picked.
 */
const aliases: Record<string, string> = {
  zh: 'zh-hans',
  'zh-cn': 'zh-hans',
  'zh-my': 'zh-hans',
  'zh-sg': 'zh-hans',
  'zh-hk': 'zh-hant',
  'zh-mo': 'zh-hant',
  'zh-tw': 'zh-hant'
};

/**
 * A BCP 47 tag, broadest match last.
 *
 * `zh-Hant-TW` asks for `zh-hant`, then `zh-tw`, then `zh`; `pt-BR` asks for
 * `pt-br` and then `pt`. The subtags are found by shape rather than by
 * position, because a tag can carry an extension or a variant between them and
 * `split('-')[1]` would take that for the script.
 */
function candidates(locale: string): string[] {
  const subtags = locale.toLowerCase().split(/[-_]/).filter(Boolean);
  const language = subtags[0];

  if (!language) {
    return [];
  }

  const rest = subtags.slice(1);
  const script = rest.find((subtag) => /^[a-z]{4}$/.test(subtag));
  const region = rest.find((subtag) => /^([a-z]{2}|\d{3})$/.test(subtag));

  return [
    script ? `${language}-${script}` : '',
    region ? `${language}-${region}` : '',
    language
  ].filter(Boolean);
}

/**
 * Resolved tables, keyed by the tag that was asked for.
 *
 * A module-level cache rather than a `useMemo` per component: the merge is the
 * same work for every ChatBubble in a thread, and a thread is where this gets
 * called a hundred times.
 */
const resolved = new Map<string, NebaMessages>([['', base]]);

/**
 * The strings for a locale, merged over English.
 *
 * `undefined` is English rather than the runtime's own locale, and that is
 * deliberate: `navigator.language` differs between the server that renders the
 * markup and the browser that hydrates it, and text that changes between those
 * two is a hydration mismatch in the one part of the page a reader is looking
 * at. A component that should follow the reader is told which language to
 * follow.
 */
export function resolveMessages(locale?: string): NebaMessages {
  const key = locale?.trim() ?? '';
  const cached = resolved.get(key);

  if (cached) {
    return cached;
  }

  const match = candidates(key)
    .map((candidate) => translations[candidate] ?? translations[aliases[candidate] ?? ''])
    .find(Boolean);

  const messages: NebaMessages = match
    ? {
        action: { ...base.action, ...match.action },
        link: { ...base.link, ...match.link },
        spoiler: { ...base.spoiler, ...match.spoiler },
        chat: { ...base.chat, ...match.chat },
        empty: { ...base.empty, ...match.empty },
        table: { ...base.table, ...match.table },
        color: { ...base.color, ...match.color },
        rating: { ...base.rating, ...match.rating },
        number: { ...base.number, ...match.number },
        pagination: { ...base.pagination, ...match.pagination },
        carousel: { ...base.carousel, ...match.carousel },
        breadcrumb: { ...base.breadcrumb, ...match.breadcrumb },
        combobox: { ...base.combobox, ...match.combobox },
        overlay: { ...base.overlay, ...match.overlay }
      }
    : base;

  resolved.set(key, messages);

  return messages;
}

/** The same, as a hook, for the components that read it during a render. */
export function useMessages(locale?: string): NebaMessages {
  return React.useMemo(() => resolveMessages(locale), [locale]);
}

/**
 * Fills the `{placeholders}` in one of the strings above.
 *
 * Two of them carry numbers, and neither could be assembled out of fragments:
 * "1–25 of 1,204" is "전체 1,204개 중 1–25" in Korean and "1,204 kayıttan 1–25"
 * in Turkish, so what differs between languages is the *order*, which only a
 * whole sentence can state. A `{name}` with no value is left alone rather than
 * blanked, so a mistranslated placeholder shows up as itself instead of as a
 * hole in the middle of a sentence.
 */
export function fillMessage(template: string, values: Record<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (whole, name: string) => values[name] ?? whole);
}
