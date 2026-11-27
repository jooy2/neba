import { colorRow, elevationRow, from, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Calendar: [
    sizeRow('Calendar'),
    colorRow('Calendar'),
    elevationRow('Calendar'),
    from('Calendar', 'mode', {
      type: 'NebaCalendarMode',
      default: 'NebaCalendarMode.single',
      description: {
        ko: '값이 무엇인지. 생성자가 정합니다. NebaCalendar는 하루, NebaCalendar.multiple은 날들의 리스트, NebaCalendar.range는 NebaCalendarRange(start, end) 구간',
        en: 'What the value is, which the constructor decides: NebaCalendar holds one day, NebaCalendar.multiple a list of days, NebaCalendar.range a NebaCalendarRange(start, end)'
      }
    }),
    from('Calendar', 'value', {
      type: 'DateTime? · List<DateTime>? · NebaCalendarRange?',
      description: {
        ko: '생성자에 따라 달라지는 값. controlled calendar에 씁니다. null이면 calendar가 defaultValue에서 시작해 상태를 스스로 관리하고, 날을 갖고 있다가 null이 되면 비워집니다',
        en: 'The value, whose type follows the constructor, for a controlled calendar. Left null, the calendar keeps its own state from defaultValue; a value that goes from a day to null empties it'
      }
    }),
    from('Calendar', 'defaultValue', {
      type: 'DateTime? · List<DateTime>? · NebaCalendarRange?'
    }),
    from('Calendar', 'onValueChange', {
      type: 'ValueChanged<DateTime?>? · ValueChanged<List<DateTime>>? · ValueChanged<NebaCalendarRange>?'
    }),
    from('Calendar', 'month', { type: 'DateTime?' }),
    from('Calendar', 'defaultMonth', { type: 'DateTime?' }),
    from('Calendar', 'onMonthChange', { type: 'ValueChanged<DateTime>?' }),
    from('Calendar', 'granularity', {
      type: 'NebaDateGranularity',
      default: 'NebaDateGranularity.day'
    }),
    from('Calendar', 'renderDay', {
      type: `${WIDGET}? Function(DateTime date)?`,
      description: {
        ko: '날짜 칸이 숫자 위에 그리는 것. 칸 크기의 Stack에 놓이므로 Positioned로 감싼 점은 준 자리에 놓입니다. 점, 개수, 막대를 위한 자리이고 하루치 일정을 담을 자리는 아닙니다',
        en: "What a day cell draws over its number, in a Stack the cell's size, so a Positioned dot lands where it is put. Room for a dot, a count or a bar, not a day of entries"
      }
    }),
    from('Calendar', 'bordered', { type: 'bool' }),
    from('Calendar', 'minDate', { type: 'DateTime?' }),
    from('Calendar', 'maxDate', { type: 'DateTime?' }),
    from('Calendar', 'shouldDisableDate', { type: 'bool Function(DateTime date)?' }),
    from('Calendar', 'weekStartsOn', {
      type: 'NebaWeekday?',
      description: {
        ko: '주가 시작하는 요일. DateTime.weekday처럼 월요일이 1, 일요일이 7입니다. 기본값은 locale의 지역을 따릅니다',
        en: "Which day the week starts on, counted as DateTime.weekday counts it: Monday is 1, Sunday 7. Defaults to the locale's region"
      }
    }),
    from('Calendar', 'locale', {
      type: 'Locale?',
      description: {
        ko: '월·요일 이름과 헤더의 연/월 순서를 정하는 언어, 주의 시작을 정하는 지역. 이름은 registerNebaDateNames로 등록한 NebaDateNames에서 오고, 등록하지 않은 언어는 영어입니다. 기본값은 NebaProvider, 그다음 앱의 locale',
        en: "The language of the month and weekday names and the header's order, and the region the week starts by. The names come from the NebaDateNames registered with registerNebaDateNames, English for a language with none. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Calendar', 'showOutsideDays', { type: 'bool' }),
    from('Calendar', 'labels', {
      type: 'NebaPickerLabels?',
      description: {
        ko: '화면 낭독기가 듣는 문자열. 준 것만 locale의 표현을 대신합니다',
        en: "The strings a screen reader hears. Each one given takes the place of the locale's"
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
