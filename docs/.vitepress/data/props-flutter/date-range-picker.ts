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
  DateRangePicker: [
    variantRow('DateRangePicker', 'NebaVariant.outline'),
    sizeRow('DateRangePicker'),
    colorRow('DateRangePicker'),
    densityRow('DateRangePicker'),
    elevationRow('DateRangePicker'),
    from('DateRangePicker', 'value', {
      type: 'NebaDateRange?',
      description: {
        ko: '선택된 범위. NebaDateRange(start, end)이고 각 끝은 null일 수 있습니다. NebaCalendar.range의 값과 같은 타입입니다. controlled picker에 쓰며, null이면 picker가 defaultValue에서 시작해 상태를 스스로 관리하고, 범위를 갖고 있다가 null이 되면 비워집니다',
        en: "The chosen range, a NebaDateRange(start, end) with either end possibly null, the same type as NebaCalendar.range's value. For a controlled picker; left null, the picker keeps its own state from defaultValue, and a value that goes from a range to null empties it"
      }
    }),
    from('DateRangePicker', 'defaultValue', { type: 'NebaDateRange?' }),
    from('DateRangePicker', 'onValueChange', {
      type: 'ValueChanged<NebaDateRange>?',
      description: {
        ko: '두 끝이 다 정해졌을 때 그 범위로 불리고, 비우면 두 끝이 null인 NebaDateRange()로 불립니다. 반쪽 범위로는 불리지 않습니다',
        en: 'Called with the range once both ends are chosen, and with NebaDateRange(), both ends null, once it is cleared. Never with half a range'
      }
    }),
    from('DateRangePicker', 'defaultMonth', { type: 'DateTime?' }),
    from('DateRangePicker', 'minDate', { type: 'DateTime?' }),
    from('DateRangePicker', 'maxDate', { type: 'DateTime?' }),
    from('DateRangePicker', 'shouldDisableDate', {
      type: 'bool Function(DateTime date)?',
      description: {
        ko: '범위 안에 있지만 고를 수 없는 날을 막습니다. picker가 다시 빌드될 때마다 다시 묻고, 띠가 포인터를 따라갈 때는 묻지 않습니다',
        en: 'Blocks days inside the bounds that still cannot be chosen. Asked again whenever the picker is built again, and not as the band follows the pointer'
      }
    }),
    from('DateRangePicker', 'monthCount', { type: 'int', default: '2' }),
    from('DateRangePicker', 'startPlaceholder', {
      type: `${WIDGET}?`,
      description: {
        ko: '시작이 비었을 때 트리거의 앞쪽 절반에 흐리게 보이는 내용. 보통 Text입니다',
        en: 'Shown muted in the first half of the trigger while the start is unchosen, usually a Text'
      }
    }),
    from('DateRangePicker', 'endPlaceholder', { type: `${WIDGET}?` }),
    from('DateRangePicker', 'presets', {
      type: 'List<NebaDateRangePreset>?',
      description: {
        ko: '달력 옆에 놓이는 단축 범위들. NebaDateRangePreset(label:, value:)는 고정된 범위이고, NebaDateRangePreset.computed(label:, value: () => …)는 눌린 시점에 범위를 계산합니다',
        en: 'Shortcuts listed beside the calendars. NebaDateRangePreset(label:, value:) is a fixed range, and NebaDateRangePreset.computed(label:, value: () => …) works its range out when it is pressed'
      }
    }),
    from('DateRangePicker', 'open', { type: 'bool?' }),
    from('DateRangePicker', 'defaultOpen', { type: 'bool' }),
    from('DateRangePicker', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('DateRangePicker', 'locale', {
      type: 'Locale?',
      description: {
        ko: '날짜를 쓰고 이름 붙이는 언어와 주의 시작을 정하는 지역. 이름과 표기는 registerNebaDateNames로 등록한 NebaDateNames에서 오고, 등록하지 않은 언어는 영어입니다. 기본값은 NebaProvider, 그다음 앱의 locale',
        en: "The language the dates are written and named in, and the region the week starts by. The names and the patterns come from the NebaDateNames registered with registerNebaDateNames, English for a language with none. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('DateRangePicker', 'weekStartsOn', {
      type: 'NebaWeekday?',
      description: {
        ko: '주가 시작하는 요일. DateTime.weekday처럼 월요일이 1, 일요일이 7입니다. 기본값은 locale의 지역을 따릅니다',
        en: "Which day the week starts on, counted as DateTime.weekday counts it: Monday is 1, Sunday 7. Defaults to the locale's region"
      }
    }),
    from('DateRangePicker', 'format', {
      type: 'String Function(DateTime date)?',
      description: {
        ko: '트리거의 각 끝이 날짜를 쓰는 방식. 기본값은 locale의 NebaDateNames로 쓴 중간 길이 날짜입니다',
        en: "How each end of the trigger writes its date. Defaults to a medium date in the locale's NebaDateNames"
      }
    }),
    from('DateRangePicker', 'clearable', {
      type: 'bool',
      description: {
        ko: '두 끝을 비우는 ×를 트리거에, Clear 버튼을 푸터에 답니다',
        en: 'Offers the × in the trigger and the Clear button in the footer that empty both ends'
      }
    }),
    from('DateRangePicker', 'closeOnSelect', { type: 'bool' }),
    from('DateRangePicker', 'labels', {
      type: 'NebaPickerLabels?',
      description: {
        ko: '화면 낭독기가 듣는 문자열과 푸터가 말하는 문자열. 준 것만 locale의 표현을 대신합니다',
        en: "The strings a screen reader hears and the footer says. Each one given takes the place of the locale's"
      }
    }),
    from('DateRangePicker', 'startIcon', { type: `${WIDGET}?` }),
    {
      name: 'showStartIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '값 앞에 글리프를 그릴지. false는 React의 startIcon={false}이며, float 라벨이 내려앉을 자리를 줍니다',
        en: "Whether a glyph is drawn before the value at all. false is React's startIcon={false}, and gives a float label somewhere to rest"
      }
    },
    from('DateRangePicker', 'fullWidth', { type: 'bool' }),
    from('DateRangePicker', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: 'picker의 이름. 보통 Text이며, 화면 낭독기는 이것을 듣고 이어서 트리거가 말하는 범위를 듣습니다',
        en: "The picker's name, usually a Text. A screen reader hears it, then the range the trigger says"
      }
    }),
    from('DateRangePicker', 'description', { type: `${WIDGET}?` }),
    from('DateRangePicker', 'error', { type: `${WIDGET}?` }),
    from('DateRangePicker', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('DateRangePicker', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top',
      description: {
        ko: '라벨 위치. 트리거 위, 위쪽 테두리를 끊어 낸 노치, 또는 어느 끝도 고르지 않았고 트리거에 포커스가 없고 팝업이 닫혀 있는 동안 두 placeholder 자리. 앞쪽 글리프가 있으면 float도 노치에 머물므로 showStartIcon: false로 내려앉게 합니다',
        en: 'Where the label is drawn: above the trigger, in a notch cut into its top edge, or in place of both placeholders while neither end is chosen, the trigger does not hold the focus and the popup is closed. The glyph at the start keeps float in the notch; showStartIcon: false lets it rest'
      }
    }),
    from('DateRangePicker', 'readOnly', {
      type: 'bool',
      description: {
        ko: '값은 보이지만 바뀌지 않고, 팝업도 열리지 않습니다. focus는 받으며 평평해지고 채도가 빠집니다',
        en: 'Shown but not changeable, and the popup does not open. Keeps the focus, goes flat and drains the saturation'
      }
    }),
    from('DateRangePicker', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
