import {
  colorRow,
  densityRow,
  elevationRow,
  focusRows,
  from,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  DatePicker: [
    variantRow('DatePicker', 'NebaVariant.outline'),
    sizeRow('DatePicker'),
    colorRow('DatePicker'),
    densityRow('DatePicker'),
    elevationRow('DatePicker'),
    from('DatePicker', 'value', {
      type: 'DateTime?',
      description: {
        ko: '선택된 날. controlled picker에 씁니다. null이면 picker가 defaultValue에서 시작해 상태를 스스로 관리하고, 날을 갖고 있다가 null이 되면 비워집니다',
        en: 'The chosen day, for a controlled picker. Left null, the picker keeps its own state from defaultValue; a value that goes from a day to null empties it'
      }
    }),
    from('DatePicker', 'defaultValue', { type: 'DateTime?' }),
    from('DatePicker', 'onValueChange', {
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 날로 호출되고, 비우면 null로 호출됩니다. 값에 시각이 있었다면 그 시각은 그대로 둡니다',
        en: 'Called with the day now chosen, and null once the picker is emptied. A time of day the value had is kept'
      }
    }),
    from('DatePicker', 'granularity', {
      type: 'NebaDateGranularity',
      default: 'NebaDateGranularity.day',
      description: {
        ko: '무엇을 묻는지, 하루, 한 달, 한 해. month와 year는 그 그리드에서 열려 거기서 끝나고, 값은 고른 단위의 첫날(3월 1일, 1월 1일)이 됩니다. format 기본값과 푸터 버튼, 아래 세 프롭이 읽는 단위가 모두 여기를 따릅니다',
        en: 'Which unit the picker asks for: a day, a whole month, a whole year. At month and year the calendar opens on that grid and stops there, and the value is the first day of what was chosen. The default format, the footer button and the unit the three props below are read at all follow it'
      }
    }),
    from('DatePicker', 'defaultMonth', { type: 'DateTime?' }),
    from('DatePicker', 'minDate', { type: 'DateTime?' }),
    from('DatePicker', 'maxDate', { type: 'DateTime?' }),
    from('DatePicker', 'shouldDisableDate', { type: 'bool Function(DateTime date)?' }),
    from('DatePicker', 'weekStartsOn', {
      type: 'NebaWeekday?',
      description: {
        ko: '주가 시작하는 요일. DateTime.weekday처럼 월요일이 1, 일요일이 7입니다. 기본값은 locale의 지역을 따릅니다',
        en: "Which day the week starts on, counted as DateTime.weekday counts it: Monday is 1, Sunday 7. Defaults to the locale's region"
      }
    }),
    from('DatePicker', 'showTodayButton', { type: 'bool' }),
    from('DatePicker', 'open', { type: 'bool?' }),
    from('DatePicker', 'defaultOpen', { type: 'bool' }),
    from('DatePicker', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('DatePicker', 'locale', {
      type: 'Locale?',
      description: {
        ko: '날짜를 쓰고 이름 붙이는 언어와 주의 시작을 정하는 지역. 이름과 표기는 registerNebaDateNames로 등록한 NebaDateNames에서 오고, 등록하지 않은 언어는 영어입니다. 기본값은 NebaProvider, 그다음 앱의 locale',
        en: "The language the dates are written and named in, and the region the week starts by. The names and the patterns come from the NebaDateNames registered with registerNebaDateNames, English for a language with none. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('DatePicker', 'format', {
      type: 'String Function(DateTime date)?',
      description: {
        ko: '트리거가 날짜를 쓰는 방식. 기본값은 granularity를 따라 locale의 NebaDateNames로 쓴 중간 길이 날짜, 연월, 연도입니다',
        en: "How the trigger writes the date. Defaults to what granularity asks for, in the locale's NebaDateNames: a medium date, a month of a year, or a year"
      }
    }),
    from('DatePicker', 'placeholder', {
      type: `${WIDGET}?`,
      description: {
        ko: '아무것도 고르지 않았을 때 트리거에 흐리게 보이는 내용. 보통 Text입니다',
        en: 'Shown muted in the trigger while nothing is chosen, usually a Text'
      }
    }),
    from('DatePicker', 'clearable', {
      type: 'bool',
      description: {
        ko: '값을 비우는 ×를 트리거에, Clear 버튼을 푸터에 답니다',
        en: 'Offers the × in the trigger and the Clear button in the footer that empty it'
      }
    }),
    from('DatePicker', 'closeOnSelect', { type: 'bool' }),
    from('DatePicker', 'labels', {
      type: 'NebaPickerLabels?',
      description: {
        ko: '화면 낭독기가 듣고 푸터가 말하는 문자열. 준 것만 locale의 표현을 대신합니다',
        en: "The strings a screen reader hears and the footer says. Each one given takes the place of the locale's"
      }
    }),
    from('DatePicker', 'startIcon', { type: `${WIDGET}?` }),
    {
      name: 'showStartIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '값 앞에 글리프를 그릴지. false는 React의 startIcon={false}이며, float 라벨이 내려앉을 자리를 줍니다',
        en: "Whether a glyph is drawn before the value at all. false is React's startIcon={false}, and gives a float label somewhere to rest"
      }
    },
    from('DatePicker', 'fullWidth', { type: 'bool' }),
    from('DatePicker', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: 'picker의 이름. 보통 Text이며, 화면 낭독기는 이것을 듣고 이어서 트리거가 말하는 날짜를 듣습니다',
        en: "The picker's name, usually a Text. A screen reader hears it, then the date the trigger says"
      }
    }),
    from('DatePicker', 'description', { type: `${WIDGET}?` }),
    from('DatePicker', 'error', { type: `${WIDGET}?` }),
    from('DatePicker', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('DatePicker', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top',
      description: {
        ko: '라벨 위치. 트리거 위, 위쪽 테두리를 끊어 낸 노치, 또는 아무것도 고르지 않았고 트리거에 포커스가 없고 팝업이 닫혀 있는 동안 placeholder 자리. 앞쪽 글리프가 있으면 float도 노치에 머물므로 showStartIcon: false로 내려앉게 합니다',
        en: 'Where the label is drawn: above the trigger, in a notch cut into its top edge, or in place of the placeholder while nothing is chosen, the trigger does not hold the focus and the popup is closed. The glyph at the start keeps float in the notch; showStartIcon: false lets it rest'
      }
    }),
    from('DatePicker', 'readOnly', {
      type: 'bool',
      description: {
        ko: '값은 보이지만 바뀌지 않고, 팝업도 열리지 않습니다. focus는 받으며 평평해지고 채도가 빠집니다',
        en: 'Shown but not changeable, and the popup does not open. Keeps the focus, goes flat and drains the saturation'
      }
    }),
    from('DatePicker', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
