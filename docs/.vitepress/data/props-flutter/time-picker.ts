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
  TimePicker: [
    variantRow('TimePicker', 'NebaVariant.outline'),
    sizeRow('TimePicker'),
    colorRow('TimePicker'),
    from('TimePicker', 'density', {
      type: 'NebaDensity?',
      default: 'NebaDensity.standard',
      description: {
        ko: '트리거의 좌우 여백과 시계 열 사이의 간격. 높이나 글자 크기는 바꾸지 않습니다',
        en: "The trigger's inline padding and the gap between the clock's columns. Never the height or the type"
      }
    }),
    elevationRow('TimePicker'),
    from('TimePicker', 'value', {
      type: 'DateTime?',
      description: {
        ko: '선택된 시각. DateTime이므로 날짜도 함께 지닙니다(referenceDate 참고). controlled picker에 쓰며, null이면 picker가 defaultValue에서 시작해 상태를 스스로 관리하고, 시각을 갖고 있다가 null이 되면 비워집니다',
        en: 'The chosen time, a DateTime that carries a day as well (see referenceDate), for a controlled picker. Left null, the picker keeps its own state from defaultValue; a value that goes from a time to null empties it'
      }
    }),
    from('TimePicker', 'defaultValue', { type: 'DateTime?' }),
    from('TimePicker', 'onValueChange', {
      type: 'ValueChanged<DateTime?>?',
      description: {
        ko: '고른 시각으로 호출되고, 비우면 null로 호출됩니다',
        en: 'Called with the time now chosen, and null once the picker is emptied'
      }
    }),
    from('TimePicker', 'referenceDate', {
      type: 'DateTime?',
      description: {
        ko: '값이 아직 없을 때 고른 시각이 얹히는 날. 기본값은 오늘 0시라 빈 picker에서 고른 시는 정각이 되고, picker가 빌드되어 있는 동안 그대로라 자정을 넘겨 열어 둔 팝업도 다음 날로 넘어가지 않습니다',
        en: 'The day a chosen time is written onto while there is no value yet. It defaults to midnight today, so an hour picked on an empty picker lands on the hour, and it is held for as long as the picker is built, so a clock left open across midnight does not move to the next day'
      }
    }),
    from('TimePicker', 'minTime', { type: 'DateTime?' }),
    from('TimePicker', 'maxTime', { type: 'DateTime?' }),
    from('TimePicker', 'hour12', {
      type: 'bool?',
      description: {
        ko: '12시간 다이얼과 오전/오후 열. 기본값은 locale의 NebaDateNames.hour12이며, 영어는 12시간입니다',
        en: "A 12-hour dial with an AM/PM column. Defaults to the locale's NebaDateNames.hour12, which is 12 hours in English"
      }
    }),
    from('TimePicker', 'showSeconds', {
      type: 'bool',
      description: {
        ko: '초 열을 추가하고, 트리거에도 초를 씁니다',
        en: 'Adds the seconds column, and the seconds to the trigger'
      }
    }),
    from('TimePicker', 'hourStep', { type: 'int' }),
    from('TimePicker', 'minuteStep', { type: 'int' }),
    from('TimePicker', 'secondStep', { type: 'int' }),
    from('TimePicker', 'shouldDisableTime', {
      type: 'bool Function(DateTime value, NebaTimeUnit unit)?'
    }),
    from('TimePicker', 'showNowButton', { type: 'bool' }),
    from('TimePicker', 'open', { type: 'bool?' }),
    from('TimePicker', 'defaultOpen', { type: 'bool' }),
    from('TimePicker', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('TimePicker', 'locale', {
      type: 'Locale?',
      description: {
        ko: '시각을 쓰는 언어와 picker가 스스로 하는 말의 언어. 오전·오후와 시각의 표기는 registerNebaDateNames로 등록한 NebaDateNames에서 오고, 등록하지 않은 언어는 영어입니다. 기본값은 NebaProvider, 그다음 앱의 locale',
        en: "The language the time is written in and the picker's own words are in. AM, PM and how a time is written come from the NebaDateNames registered with registerNebaDateNames, English for a language with none. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('TimePicker', 'format', {
      type: 'String Function(DateTime value)?',
      description: {
        ko: '트리거가 시각을 쓰는 방식. 기본값은 locale의 NebaDateNames.time이고, showSeconds면 timeWithSeconds입니다',
        en: "How the trigger writes the time. Defaults to the locale's NebaDateNames.time, or timeWithSeconds with showSeconds"
      }
    }),
    from('TimePicker', 'placeholder', {
      type: `${WIDGET}?`,
      description: {
        ko: '아무것도 고르지 않았을 때 트리거에 흐리게 보이는 내용. 보통 Text입니다',
        en: 'Shown muted in the trigger while nothing is chosen, usually a Text'
      }
    }),
    from('TimePicker', 'clearable', {
      type: 'bool',
      description: {
        ko: '값을 비우는 ×를 트리거에, Clear 버튼을 푸터에 답니다',
        en: 'Offers the × in the trigger and the Clear button in the footer that empty it'
      }
    }),
    from('TimePicker', 'closeOnSelect', { type: 'bool' }),
    from('TimePicker', 'labels', {
      type: 'NebaPickerLabels?',
      description: {
        ko: '화면 낭독기가 듣는 열 이름과 푸터가 말하는 문자열. 준 것만 locale의 표현을 대신합니다',
        en: "The columns' names a screen reader hears and the strings the footer says. Each one given takes the place of the locale's"
      }
    }),
    from('TimePicker', 'startIcon', { type: `${WIDGET}?` }),
    {
      name: 'showStartIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '값 앞에 글리프를 그릴지. false는 React의 startIcon={false}이며, float 라벨이 내려앉을 자리를 줍니다',
        en: "Whether a glyph is drawn before the value at all. false is React's startIcon={false}, and gives a float label somewhere to rest"
      }
    },
    from('TimePicker', 'fullWidth', { type: 'bool' }),
    from('TimePicker', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: 'picker의 이름. 보통 Text이며, 화면 낭독기는 이것을 듣고 이어서 트리거가 말하는 시각을 듣습니다',
        en: "The picker's name, usually a Text. A screen reader hears it, then the time the trigger says"
      }
    }),
    from('TimePicker', 'description', { type: `${WIDGET}?` }),
    from('TimePicker', 'error', { type: `${WIDGET}?` }),
    from('TimePicker', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('TimePicker', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top',
      description: {
        ko: '라벨 위치. 트리거 위, 위쪽 테두리를 끊어 낸 노치, 또는 아무것도 고르지 않았고 트리거에 포커스가 없고 팝업이 닫혀 있는 동안 placeholder 자리. 앞쪽 글리프가 있으면 float도 노치에 머물므로 showStartIcon: false로 내려앉게 합니다',
        en: 'Where the label is drawn: above the trigger, in a notch cut into its top edge, or in place of the placeholder while nothing is chosen, the trigger does not hold the focus and the popup is closed. The glyph at the start keeps float in the notch; showStartIcon: false lets it rest'
      }
    }),
    from('TimePicker', 'readOnly', {
      type: 'bool',
      description: {
        ko: '값은 보이지만 바뀌지 않고, 팝업도 열리지 않습니다. focus는 받으며 평평해지고 채도가 빠집니다',
        en: 'Shown but not changeable, and the popup does not open. Keeps the focus, goes flat and drains the saturation'
      }
    }),
    from('TimePicker', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
