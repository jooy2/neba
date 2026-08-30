/**
 * Russian.
 *
 * Registered rather than shipped, so a project that says nothing about
 * languages carries none of them:
 *
 * ```ts
 * import { registerMessages, ru } from 'neba/locales';
 *
 * registerMessages('ru', ru);
 * ```
 */

import type { NebaLocale } from '../internal/i18n.js';

export const ru: NebaLocale = {
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
  chart: { label: 'Диаграмма' },
  scroll: {
    label: 'Прокручиваемая область',
    previous: 'Прокрутить назад',
    next: 'Прокрутить вперёд'
  },
  breadcrumb: {
    label: 'Навигационная цепочка',
    expand: 'Показать скрытые шаги'
  },
  anchor: { label: 'На этой странице' },
  transfer: {
    source: 'Доступные',
    target: 'Выбранные',
    toTarget: 'Переместить в выбранные',
    toSource: 'Вернуть в доступные',
    search: 'Поиск',
    selectAll: 'Выбрать все',
    empty: 'Здесь пусто'
  },
  command: {
    label: 'Палитра команд',
    search: 'Введите команду или поиск…',
    empty: 'Команды не найдены'
  },
  combobox: {
    empty: 'Совпадений нет',
    remove: 'Удалить {label}'
  },
  overlay: {
    label: 'Наложение'
  },
  window: {
    minimize: 'Свернуть',
    maximize: 'Развернуть',
    restore: 'Восстановить',
    resize: 'Изменить размер окна'
  },
  layout: {
    skipToContent: 'Перейти к содержимому',
    sidebar: 'Боковая панель',
    openSidebar: 'Открыть боковую панель',
    closeSidebar: 'Закрыть боковую панель',
    resizeSidebar: 'Изменить размер боковой панели'
  },
  code: {
    code: 'Код',
    copy: 'Копировать',
    copied: 'Скопировано',
    copyFailed: 'Не удалось скопировать',
    raw: 'Без подсветки',
    prompt: 'Приглашение'
  },
  steps: {
    previous: 'Назад',
    next: 'Далее',
    done: 'Готово',
    skip: 'Пропустить',
    restart: 'Начать сначала',
    completed: 'Все шаги пройдены',
    steps: 'Шаги',
    position: '{index} из {total}',
    step: 'Шаг {index}: {title}'
  }
};
