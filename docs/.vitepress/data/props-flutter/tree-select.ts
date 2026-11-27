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
  TreeSelect: [
    variantRow('TreeSelect', 'NebaVariant.outline'),
    sizeRow('TreeSelect'),
    colorRow('TreeSelect'),
    densityRow('TreeSelect'),
    elevationRow('TreeSelect'),
    from('TreeSelect', 'items', { type: 'List<NebaTreeSelectItem<T>>' }),
    from('TreeSelect', 'value', {
      type: 'List<T>?',
      description: {
        ko: '담긴 값들. 하나만 담을 때도 리스트이며 아무것도 없으면 빈 리스트입니다. null이면 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'The values held: a list even when only one may be held, and empty for none. Left null, the tree select keeps its own state from defaultValue'
      }
    }),
    from('TreeSelect', 'defaultValue', { type: 'List<T>?' }),
    from('TreeSelect', 'onValueChange', { type: 'ValueChanged<List<T>>?' }),
    from('TreeSelect', 'multiple', { type: 'bool' }),
    from('TreeSelect', 'selectableBranches', { type: 'bool' }),
    from('TreeSelect', 'searchable', { type: 'bool' }),
    from('TreeSelect', 'clearLabel', { type: 'String?' }),
    from('TreeSelect', 'searchPlaceholder', {
      type: 'String?',
      description: {
        ko: '검색 필드의 placeholder이자 화면 낭독기가 부르는 이름. 기본값은 locale의 표현입니다',
        en: "The search field's placeholder, and its name for a screen reader. Defaults to the locale's word"
      }
    }),
    from('TreeSelect', 'expanded', { type: 'List<T>?' }),
    from('TreeSelect', 'defaultExpanded', { type: 'List<T>?' }),
    from('TreeSelect', 'onExpandedChange', { type: 'ValueChanged<List<T>>?' }),
    from('TreeSelect', 'format', {
      type: 'Widget Function(List<NebaTreeSelectItem<T>> chosen)?',
      description: {
        ko: 'trigger가 담긴 것을 쓰는 방식. 위젯을 돌려줍니다. 기본값은 라벨을 쉼표로 이은 것',
        en: 'How the trigger writes what is held, as a widget. The labels, comma-joined, by default'
      }
    }),
    from('TreeSelect', 'closeOnSelect', { type: 'bool?', default: '!multiple' }),
    from('TreeSelect', 'open', { type: 'bool?' }),
    from('TreeSelect', 'defaultOpen', { type: 'bool' }),
    from('TreeSelect', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('TreeSelect', 'placeholder', { type: `${WIDGET}?` }),
    from('TreeSelect', 'clearable', { type: 'bool' }),
    from('TreeSelect', 'locale', {
      type: 'Locale?',
      description: {
        ko: '지우기 버튼, 검색 필드, 결과 없음 문구를 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the clear button, the search field and the no-matches line. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('TreeSelect', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '컨트롤의 이름. 보통 Text이며, 화면 낭독기는 이것을 trigger의 이름으로 읽습니다',
        en: "The control's name, usually a Text. A screen reader hears it as the trigger's name"
      }
    }),
    from('TreeSelect', 'description', { type: `${WIDGET}?` }),
    from('TreeSelect', 'error', { type: `${WIDGET}?` }),
    from('TreeSelect', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('TreeSelect', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top'
    }),
    {
      name: 'startIcon',
      type: `${WIDGET}?`,
      description: {
        ko: '값 앞에 놓이는 아이콘. 글 크기의 1.2배로 흐리게 그려집니다',
        en: 'Before the value, drawn muted at 1.2 times its size'
      }
    },
    {
      name: 'fullWidth',
      type: 'bool',
      default: 'false',
      description: {
        ko: '주어진 너비만큼 늘어납니다. 주지 않으면 trigger는 지금 쓰고 있는 것만큼의 너비입니다',
        en: 'Stretches to the width it is given. Otherwise the trigger is as wide as what it is writing'
      }
    },
    from('TreeSelect', 'readOnly', {
      type: 'bool',
      description: {
        ko: '담긴 것은 보이지만 바뀌지 않습니다. 팝업도 열리지 않으며, trigger는 focus를 받고 평평해집니다',
        en: 'Shows what it holds and does not open: the trigger keeps the focus and goes flat'
      }
    }),
    from('TreeSelect', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    ...focusRows
  ],

  TreeSelectItem: [
    from('TreeSelectItem', 'value', { type: 'T' }),
    from('TreeSelectItem', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '행과 trigger에 그려지는 것. 보통 Text이며, 없으면 value의 텍스트입니다',
        en: "What the row and the trigger draw, usually a Text. The value's own text when left out"
      }
    }),
    from('TreeSelectItem', 'searchLabel', {
      type: 'String?',
      description: {
        ko: '검색이 대조하는 문자열. 없으면 label이 Text일 때 그 글자, 그다음 value의 텍스트입니다',
        en: "What a search matches against. Falls back to the label's words when it is a Text, then to the value's text"
      }
    }),
    from('TreeSelectItem', 'startIcon', { type: `${WIDGET}?` }),
    from('TreeSelectItem', 'selectable', { type: 'bool?' }),
    from('TreeSelectItem', 'disabled', { type: 'bool', default: 'false' }),
    from('TreeSelectItem', 'children', {
      type: 'List<NebaTreeSelectItem<T>>',
      default: 'const []'
    })
  ]
} satisfies Record<string, PropRow[]>;
