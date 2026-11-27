import {
  colorRow,
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
  DateTimePicker: [
    variantRow('DateTimePicker', 'NebaVariant.outline'),
    sizeRow('DateTimePicker'),
    colorRow('DateTimePicker'),
    from('DateTimePicker', 'density', {
      type: 'NebaDensity?',
      default: 'NebaDensity.standard',
      description: {
        ko: '트리거의 좌우 여백과 시계 열 사이의 간격. 높이나 글자 크기는 바꾸지 않습니다',
        en: "The trigger's inline padding and the gap between the clock's columns. Never the height or the type"
      }
    }),
    elevationRow('DateTimePicker'),
    from('DateTimePicker', 'value', {
      type: 'DateTime?',
      description: {
        ko: '선택된 순간. controlled picker에 씁니다. null이면 picker가 defaultValue에서 시작해 상태를 스스로 관리하고, 순간을 갖고 있다가 null이 되면 비워집니다',
        en: 'The chosen moment, for a controlled picker. Left null, the picker keeps its own state from defaultValue; a value that goes from a moment to null empties it'
      }
    }),
    from('DateTimePicker', 'defaultValue', { type: 'DateTime?' }),
    from('DateTimePicker', 'onValueChange', {
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 순간으로 호출되고, 비우면 null로 호출됩니다',
        en: 'Called with the moment now chosen, and null once the picker is emptied'
      }
    }),
    from('DateTimePicker', 'defaultMonth', { type: 'DateTime?' }),
    from('DateTimePicker', 'minDate', { type: 'DateTime?' }),
    from('DateTimePicker', 'maxDate', { type: 'DateTime?' }),
    from('DateTimePicker', 'shouldDisableDate', { type: 'bool Function(DateTime date)?' }),
    from('DateTimePicker', 'hour12', {
      type: 'bool?',
      description: {
        ko: '12시간 다이얼과 오전/오후 열. 기본값은 locale의 NebaDateNames.hour12이며, 영어는 12시간입니다',
        en: "A 12-hour dial with an AM/PM column. Defaults to the locale's NebaDateNames.hour12, which is 12 hours in English"
      }
    }),
    from('DateTimePicker', 'showSeconds', { type: 'bool' }),
    from('DateTimePicker', 'hourStep', { type: 'int' }),
    from('DateTimePicker', 'minuteStep', { type: 'int' }),
    from('DateTimePicker', 'secondStep', { type: 'int' }),
    from('DateTimePicker', 'shouldDisableTime', {
      type: 'bool Function(DateTime value, NebaTimeUnit unit)?'
    }),
    from('DateTimePicker', 'showNowButton', { type: 'bool' }),
    from('DateTimePicker', 'open', { type: 'bool?' }),
    from('DateTimePicker', 'defaultOpen', { type: 'bool' }),
    from('DateTimePicker', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('DateTimePicker', 'locale', {
      type: 'Locale?',
      description: {
        ko: '날짜와 시각을 쓰고 이름 붙이는 언어와 주의 시작을 정하는 지역. 이름과 표기는 registerNebaDateNames로 등록한 NebaDateNames에서 오고, 등록하지 않은 언어는 영어입니다. 기본값은 NebaProvider, 그다음 앱의 locale',
        en: "The language the day and the time are written and named in, and the region the week starts by. The names and the patterns come from the NebaDateNames registered with registerNebaDateNames, English for a language with none. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('DateTimePicker', 'weekStartsOn', {
      type: 'NebaWeekday?',
      description: {
        ko: '주가 시작하는 요일. DateTime.weekday처럼 월요일이 1, 일요일이 7입니다. 기본값은 locale의 지역을 따릅니다',
        en: "Which day the week starts on, counted as DateTime.weekday counts it: Monday is 1, Sunday 7. Defaults to the locale's region"
      }
    }),
    from('DateTimePicker', 'format', {
      type: 'String Function(DateTime value)?',
      description: {
        ko: '트리거가 순간을 쓰는 방식. 기본값은 locale의 NebaDateNames.dateTime으로, 중간 길이 날짜와 시각을 한 문자열로 씁니다',
        en: "How the trigger writes the moment. Defaults to the locale's NebaDateNames.dateTime, a medium date and a time in one string"
      }
    }),
    from('DateTimePicker', 'placeholder', {
      type: `${WIDGET}?`,
      description: {
        ko: '아무것도 고르지 않았을 때 트리거에 흐리게 보이는 내용. 보통 Text입니다',
        en: 'Shown muted in the trigger while nothing is chosen, usually a Text'
      }
    }),
    from('DateTimePicker', 'clearable', {
      type: 'bool',
      description: {
        ko: '값을 비우는 ×를 트리거에, Clear 버튼을 푸터에 답니다',
        en: 'Offers the × in the trigger and the Clear button in the footer that empty it'
      }
    }),
    from('DateTimePicker', 'closeOnSelect', { type: 'bool' }),
    from('DateTimePicker', 'labels', {
      type: 'NebaPickerLabels?',
      description: {
        ko: '화면 낭독기가 듣는 문자열과 푸터가 말하는 문자열. 준 것만 locale의 표현을 대신합니다',
        en: "The strings a screen reader hears and the footer says. Each one given takes the place of the locale's"
      }
    }),
    from('DateTimePicker', 'startIcon', { type: `${WIDGET}?` }),
    {
      name: 'showStartIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '값 앞에 글리프를 그릴지. false는 React의 startIcon={false}이며, float 라벨이 내려앉을 자리를 줍니다',
        en: "Whether a glyph is drawn before the value at all. false is React's startIcon={false}, and gives a float label somewhere to rest"
      }
    },
    from('DateTimePicker', 'fullWidth', { type: 'bool' }),
    from('DateTimePicker', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: 'picker의 이름. 보통 Text이며, 화면 낭독기는 이것을 듣고 이어서 트리거가 말하는 순간을 듣습니다',
        en: "The picker's name, usually a Text. A screen reader hears it, then the moment the trigger says"
      }
    }),
    from('DateTimePicker', 'description', { type: `${WIDGET}?` }),
    from('DateTimePicker', 'error', { type: `${WIDGET}?` }),
    from('DateTimePicker', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('DateTimePicker', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top',
      description: {
        ko: '라벨 위치. 트리거 위, 위쪽 테두리를 끊어 낸 노치, 또는 아무것도 고르지 않았고 트리거에 포커스가 없고 팝업이 닫혀 있는 동안 placeholder 자리. 앞쪽 글리프가 있으면 float도 노치에 머물므로 showStartIcon: false로 내려앉게 합니다',
        en: 'Where the label is drawn: above the trigger, in a notch cut into its top edge, or in place of the placeholder while nothing is chosen, the trigger does not hold the focus and the popup is closed. The glyph at the start keeps float in the notch; showStartIcon: false lets it rest'
      }
    }),
    from('DateTimePicker', 'readOnly', {
      type: 'bool',
      description: {
        ko: '값은 보이지만 바뀌지 않고, 팝업도 열리지 않습니다. focus는 받으며 평평해지고 채도가 빠집니다',
        en: 'Shown but not changeable, and the popup does not open. Keeps the focus, goes flat and drains the saturation'
      }
    }),
    from('DateTimePicker', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
