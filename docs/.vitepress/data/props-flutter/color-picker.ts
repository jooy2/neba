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
  ColorPicker: [
    from('ColorPicker', 'value', {
      type: 'String?',
      description: {
        ko: 'CSS 색상 문자열. 직접 제어할 때 씁니다. null이면 picker가 defaultValue에서 시작해 상태를 스스로 관리하고, 빈 문자열은 아무 색도 고르지 않은 상태입니다',
        en: 'The colour, as a CSS string, for a controlled picker. Left null, the picker keeps its own state from defaultValue; an empty string is a picker with nothing chosen'
      }
    }),
    from('ColorPicker', 'defaultValue', { type: 'String' }),
    from('ColorPicker', 'onValueChange', {
      type: 'ValueChanged<String>?',
      description: {
        ko: 'format이 정한 표기로 새 색을 전달합니다. ×로 비우면 빈 문자열을 전달합니다',
        en: 'Called with the new colour, written in format, or with an empty string when the × empties the picker'
      }
    }),
    from('ColorPicker', 'format', { type: 'NebaColorFormat', default: 'NebaColorFormat.hex' }),
    from('ColorPicker', 'alpha', { type: 'bool' }),
    from('ColorPicker', 'swatches', {
      type: 'List<String>?',
      description: {
        ko: '패널 아래의 기본 색들. 리스트를 주면 내장 세트를 대체하고, 빈 리스트면 그리지 않습니다',
        en: 'The ready-made colours under the panel. A list replaces the built-in set, and an empty one draws none'
      }
    }),
    from('ColorPicker', 'inline', { type: 'bool' }),
    from('ColorPicker', 'editable', { type: 'bool' }),
    from('ColorPicker', 'clearable', { type: 'bool' }),
    from('ColorPicker', 'open', { type: 'bool?' }),
    from('ColorPicker', 'defaultOpen', { type: 'bool' }),
    from('ColorPicker', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('ColorPicker', 'locale', {
      type: 'Locale?',
      default: undefined,
      description: {
        ko: '접근성 이름들의 언어. 지정하지 않으면 NebaProvider의 것, 다음으로 앱의 것을 따릅니다. 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the accessible names are written in. Defaults to NebaProvider's, then the app's; a language nobody registered falls back to English"
      }
    }),
    from('ColorPicker', 'labels', {
      type: 'NebaColorPickerLabels?',
      description: {
        ko: '그 이름들을 하나씩 덮어씁니다. area, areaValue, hue, alpha, value, swatches, clear, empty 필드 중 null로 둔 것은 locale의 문구를 씁니다',
        en: "Overrides for those names, one at a time: of the fields area, areaValue, hue, alpha, value, swatches, clear and empty, any left null keeps the locale's word"
      }
    }),
    from('ColorPicker', 'fullWidth', { type: 'bool' }),
    from('ColorPicker', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: 'picker의 이름. 보통 Text이며, 화면 낭독기는 이것을 trigger나 inline 패널의 이름으로 읽습니다',
        en: "The picker's name, usually a Text. A screen reader hears it as the trigger's name, or as the name of an inline panel"
      }
    }),
    from('ColorPicker', 'description', { type: `${WIDGET}?` }),
    from('ColorPicker', 'error', { type: `${WIDGET}?` }),
    from('ColorPicker', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('ColorPicker', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top'
    }),
    from('ColorPicker', 'readOnly', {
      type: 'bool',
      description: {
        ko: '색은 보이지만 바뀌지 않습니다. 패널은 열리지만 사각형과 레일, 스와치는 focus 순서에서 빠지고, 텍스트 필드는 읽기 전용으로 남아 값을 선택하고 복사할 수 있습니다',
        en: 'Shown but not changeable. The panel still opens; the square, the rails and the swatches leave the focus order, and the text field stays in it, read-only, so its value can still be selected and copied'
      }
    }),
    from('ColorPicker', 'disabled', { type: 'bool' }),
    variantRow('ColorPicker', 'NebaVariant.outline'),
    sizeRow('ColorPicker'),
    colorRow('ColorPicker'),
    densityRow('ColorPicker'),
    elevationRow('ColorPicker'),
    from('ColorPicker', 'required', {
      type: 'bool',
      default: 'false',
      description: {
        ko: '색이 필요하다는 사실을 화면 낭독기에 알립니다. 폼 제출을 막는 주체는 없습니다',
        en: 'Whether a screen reader hears that a colour is required. Nothing holds a form back'
      }
    }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
