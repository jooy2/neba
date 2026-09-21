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
  confirm: {
    confirm: 'Подтвердить',
    cancel: 'Отмена'
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
    empty: 'Нет данных',
    exportCsv: 'Экспорт CSV',
    noGroup: 'Без группы'
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
    next: 'Следующий слайд',
    pause: 'Приостановить слайд-шоу',
    play: 'Запустить слайд-шоу'
  },
  picker: {
    previousMonth: 'Предыдущий месяц',
    nextMonth: 'Следующий месяц',
    previousYear: 'Предыдущий год',
    nextYear: 'Следующий год',
    previousYears: 'Предыдущие годы',
    nextYears: 'Следующие годы',
    chooseMonth: 'Выбрать месяц',
    chooseYear: 'Выбрать год',
    today: 'Сегодня',
    thisMonth: 'Этот месяц',
    thisYear: 'Этот год',
    now: 'Сейчас',
    clear: 'Очистить',
    done: 'Готово',
    hour: 'Часы',
    minute: 'Минуты',
    second: 'Секунды',
    meridiem: 'AM/PM',
    start: 'Начало',
    end: 'Конец'
  },
  gallery: {
    label: 'Галерея',
    item: 'Изображение {index} из {total}',
    previous: 'Предыдущее изображение',
    next: 'Следующее изображение'
  },
  image: { unavailable: 'Изображение недоступно', preview: 'Увеличить изображение' },
  chart: {
    label: 'Диаграмма',
    size: 'Размер',
    title: 'Метка',
    start: 'Начало',
    end: 'Конец',
    summary: 'Точек данных: {count}. Диапазон: от {min} до {max}.',
    exportCsv: 'Экспорт CSV'
  },
  panes: { handle: 'Изменить размер панелей' },
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
    remove: 'Удалить {label}',
    add: 'Добавить «{label}»',
    open: 'Открыть'
  },
  toast: {
    label: 'Уведомления'
  },
  overlay: {
    label: 'Загрузка'
  },
  window: {
    minimize: 'Свернуть',
    maximize: 'Развернуть',
    restore: 'Восстановить',
    resize: 'Изменить размер окна',
    resizeHint: 'Используйте клавиши со стрелками, чтобы изменить размер окна'
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
  },
  otp: {
    slot: 'Символ {index} из {total}'
  },
  file: {
    title: 'Перетащите файлы сюда или нажмите, чтобы выбрать',
    remove: 'Удалить {name}'
  },
  timeline: {
    complete: 'Завершено',
    upcoming: 'Предстоит'
  },
  run: {
    pending: 'Ожидание',
    running: 'Выполняется',
    success: 'Завершено',
    error: 'Ошибка'
  },
  tool: {
    arguments: 'Аргументы',
    result: 'Результат'
  },
  approval: {
    request: 'Нужно разрешение',
    answered: 'Дан ответ',
    low: 'Низкий риск',
    medium: 'Средний риск',
    high: 'Высокий риск'
  },
  reasoning: {
    thinking: 'Размышляет…',
    thought: 'Размышлял {duration}',
    done: 'Размышление завершено'
  },
  context: {
    label: 'Контекст',
    input: 'Ввод',
    output: 'Вывод',
    reasoning: 'Рассуждение',
    cached: 'Из кэша',
    cost: 'Примерная стоимость',
    usage: '{used} из {max}'
  },
  sources: {
    title: 'Источники',
    citation: 'Источник {index}'
  },
  prompt: {
    send: 'Отправить',
    stop: 'Остановить',
    drop: 'Перетащите файлы сюда, чтобы прикрепить'
  }
};
