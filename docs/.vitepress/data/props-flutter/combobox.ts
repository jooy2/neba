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
  Combobox: [
    from('Combobox', 'locale', {
      type: 'Locale?',
      description: {
        ko: '결과 없음 문구, 입력한 값을 더하는 행, 지우기 · 삭제 버튼의 이름을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "The language of the no-matches line, the row that adds what was typed and the clear and remove buttons. Defaults to NebaProvider's, then the app's"
      }
    }),
    variantRow('Combobox', 'NebaVariant.outline'),
    sizeRow('Combobox'),
    colorRow('Combobox'),
    densityRow('Combobox'),
    elevationRow('Combobox'),
    from('Combobox', 'items', {
      type: 'List<NebaComboboxOption<T>>',
      description: {
        ko: '옵션 목록. NebaComboboxOption(value, label, disabled)의 리스트이며, label은 위젯이 아니라 String입니다',
        en: 'The options, as a list of NebaComboboxOption(value, label, disabled): label is a String, not a widget'
      }
    }),
    from('Combobox', 'multiple', {
      name: 'NebaCombobox.multiple',
      type: 'constructor',
      default: undefined,
      description: {
        ko: '값을 여러 개 드는 combobox를 만드는 생성자. 고른 값은 필드 안의 칩이 되고, value · defaultValue · onValueChange가 리스트로 말합니다',
        en: 'The constructor of a combobox that holds more than one value. The chosen ones become chips inside the field, and value, defaultValue and onValueChange speak in lists'
      }
    }),
    from('Combobox', 'value', {
      type: 'T? · List<T>?',
      description: {
        ko: '선택된 값. NebaCombobox.multiple이면 리스트입니다. null이면 combobox가 defaultValue에서 시작해 상태를 스스로 관리합니다',
        en: 'The chosen value, a list with NebaCombobox.multiple. Left null, the combobox keeps its own state, starting from defaultValue'
      }
    }),
    from('Combobox', 'defaultValue', { type: 'T? · List<T>?' }),
    from('Combobox', 'onValueChange', {
      type: 'ValueChanged<T?>? · ValueChanged<List<T>>?',
      description: {
        ko: '값이 바뀔 때 새 값으로 호출됩니다. 하나를 드는 combobox는 지워지면 null을 받습니다',
        en: 'Called with the new value. A single combobox gets null once it is cleared'
      }
    }),
    from('Combobox', 'onInputValueChange', { type: 'ValueChanged<String>?' }),
    from('Combobox', 'filter', {
      type: 'NebaComboboxFilter<T>?',
      description: {
        ko: '입력한 글로 옵션을 걸러내는 함수. 주지 않으면 악센트와 대소문자를 무시하고 label에 입력한 글이 들어 있는 옵션만 남습니다. 늘 true를 돌려주는 함수는 거르기를 끕니다. 입력한 값을 더하는 행은 걸러지지 않습니다',
        en: 'Decides whether an option stays for what was typed. Left out, an option stays when its label holds the typed text, accents and case folded away. A function that always returns true turns filtering off. The row that adds what was typed is never filtered out'
      }
    }),
    from('Combobox', 'allowCustom', {
      type: 'bool',
      description: {
        ko: '목록에 없는 값을 고를 수 있는지. 입력한 글이 마지막 행으로 제안됩니다. 값이 String일 수 있는 combobox(String이나 Object? 위의 것)만 입력한 글을 값으로 들 수 있고, 다른 타입에서는 그 행이 나오지 않습니다',
        en: 'Whether a value the list does not have may be chosen, offered as the last row. Only a combobox whose values a String can be, one over String or Object?, holds what was typed; over any other type the row is never offered'
      }
    }),
    from('Combobox', 'customLabel', {
      type: `${WIDGET} Function(String query)?`
    }),
    from('Combobox', 'clearable', {
      type: 'bool',
      description: {
        ko: '무언가를 들고 있는 동안 필드를 비우는 ×를 보여 줍니다. 한 번 눌러 비워지는 필드는 실수로도 비워지므로 기본은 끔입니다',
        en: 'Shows a × that empties the field while it holds something. Off by default: a field that empties in one press empties by accident'
      }
    }),
    from('Combobox', 'emptyMessage', { type: `${WIDGET}?` }),
    from('Combobox', 'limit', { type: 'int' }),
    from('Combobox', 'placeholder', { type: 'String?' }),
    from('Combobox', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '필드의 이름. 보통 Text이며, 화면 낭독기는 이것을 필드 이름으로 읽습니다',
        en: "The field's name, usually a Text. A screen reader hears it as the field's name"
      }
    }),
    from('Combobox', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top'
    }),
    from('Combobox', 'description', { type: `${WIDGET}?` }),
    from('Combobox', 'error', { type: `${WIDGET}?` }),
    from('Combobox', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('Combobox', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '글 앞에 놓이는 아이콘. combobox가 내려주는 IconTheme으로 글 크기의 1.2배가 되고 흐리게 그려집니다',
        en: 'Before the text, drawn muted at 1.2 times its size through the IconTheme the combobox hands down'
      }
    }),
    from('Combobox', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '주어진 너비만큼 늘어납니다. 주지 않으면 칩 뒤로 글자 스무 개쯤이 들어가는 너비이고, 주어진 너비가 그보다 좁으면 거기에 맞춥니다',
        en: 'Stretches to the width it is given. Otherwise about twenty characters wide after its chips, or the width it is given when that is less'
      }
    }),
    from('Combobox', 'removeLabel', { type: 'String Function(String label)?' }),
    from('Combobox', 'clearLabel', { type: 'String?' }),
    from('Combobox', 'openLabel', {
      type: 'String?',
      description: {
        ko: 'label이 이름을 줄 수 있는 Text가 아닐 때 chevron의 접근성 이름. 기본값은 locale의 문구입니다',
        en: "Accessible name of the chevron when label is not a Text to name it by. Defaults to the locale's word"
      }
    }),
    from('Combobox', 'open', { type: 'bool?' }),
    from('Combobox', 'defaultOpen', { type: 'bool' }),
    from('Combobox', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Combobox', 'readOnly', {
      type: 'bool',
      description: {
        ko: '값은 보이지만 글을 받지 않고 바뀌지도 않습니다. 옵션을 읽을 수 있도록 목록은 열리지만 아무것도 고를 수 없고, 필드는 focus를 받으며 평평해지고 칩의 ×가 사라집니다',
        en: 'Shows its value but takes no text and does not change it. The list still opens so the options can be read, and nothing in it can be chosen; the field keeps the focus, goes flat, and its chips lose their ×'
      }
    }),
    from('Combobox', 'disabled', { type: 'bool' }),
    from('Combobox', 'shortcuts', {
      type: 'Map<ShortcutActivator, VoidCallback>?',
      description: {
        ko: '필드가 focus를 가진 동안 반응할 키 조합과 그때 할 일. 목록이 키에 반응하기 전에 실행되며 그 동작을 대신하지 않으므로, Enter에 건 바인딩은 선택과 함께 실행됩니다',
        en: 'Key combinations to act on while the field holds the focus. They run before the list acts on a key and do not replace it, so a binding on Enter runs alongside the choice'
      }
    }),
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
