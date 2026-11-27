import {
  colorRow,
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  semanticLabelRow,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  TextField: [
    variantRow('TextField', 'NebaVariant.outline'),
    sizeRow('TextField'),
    colorRow('TextField'),
    densityRow('TextField'),
    elevationRow('TextField'),
    from('TextField', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '필드의 이름. 보통 Text이며, 누르면 caret이 필드로 들어가고 화면 낭독기는 이것을 필드 이름으로 읽습니다',
        en: "The field's name, usually a Text. A tap on it puts the caret in the field, and a screen reader hears it as the field's name"
      }
    }),
    from('TextField', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top'
    }),
    {
      name: 'placeholder',
      type: 'String?',
      description: {
        ko: '비어 있는 동안 보이는 글자. float 라벨 아래에서는 라벨이 올라간 뒤에야 보입니다',
        en: 'What the field shows while it is empty. Under a float label it shows only once the label has moved up'
      }
    },
    from('TextField', 'description', { type: `${WIDGET}?` }),
    from('TextField', 'error', { type: `${WIDGET}?` }),
    from('TextField', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('TextField', 'multiline', {
      type: 'bool',
      description: {
        ko: '여러 줄을 받고 글이 늘면 함께 늘어납니다. 나머지 축은 그대로',
        en: 'Takes more than one line and grows with the text. Every other axis stays identical'
      }
    }),
    from('TextField', 'rows', {
      type: 'int',
      description: {
        ko: 'multiline일 때 최소한 보이는 줄 수. 1이면 한 줄 필드와 높이가 정확히 같습니다',
        en: 'The fewest lines a multiline field shows. One row is exactly as tall as a single-line field'
      }
    }),
    from('TextField', 'startIcon', {
      type: `${WIDGET}?`,
      description: {
        ko: '글 앞에 놓이는 아이콘. 필드가 내려주는 IconTheme으로 글 크기의 1.2배가 되고, focus를 받기 전에는 흐리게 그려집니다',
        en: 'Before the text, drawn at 1.2 times its size through the IconTheme the field hands down, and muted until the field holds the focus'
      }
    }),
    from('TextField', 'endIcon', { type: `${WIDGET}?` }),
    from('TextField', 'loading', {
      type: 'bool',
      description: {
        ko: 'endIcon 자리에 도는 링을 띄웁니다. 입력은 계속 가능합니다',
        en: 'A turning ring in place of endIcon. Typing is still allowed'
      }
    }),
    from('TextField', 'readOnly', { type: 'bool' }),
    from('TextField', 'disabled', { type: 'bool' }),
    from('TextField', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '주어진 너비만큼 늘어납니다. 주지 않으면 글자 스무 개쯤의 너비이고, 주어진 너비가 그보다 좁으면 거기에 맞춥니다',
        en: 'Stretches to the width it is given. Otherwise about twenty characters wide, or the width it is given when that is less'
      }
    }),
    from('TextField', 'shortcuts', {
      type: 'Map<ShortcutActivator, VoidCallback>?',
      description: {
        ko: '필드가 focus를 가진 동안 반응할 키 조합과 그때 할 일. SingleActivator(LogicalKeyboardKey.enter, control: true) 형태입니다. 바인딩한 키는 소비되므로 줄바꿈이나 제출로 이어지지 않습니다',
        en: 'Key combinations to act on while the field holds the focus: SingleActivator(LogicalKeyboardKey.enter, control: true). A bound key is taken, so it does not also type a new line or submit'
      }
    }),
    {
      name: 'controller',
      type: 'TextEditingController?',
      description: {
        ko: '호출하는 쪽이 들고 있는 글. 주지 않으면 필드가 자기 것을 둡니다',
        en: 'The text, when the caller holds it. Without one the field keeps its own'
      }
    },
    {
      name: 'initialValue',
      type: 'String?',
      description: {
        ko: '자기 글을 두는 필드가 처음 가지는 글. React의 defaultValue입니다',
        en: "The text a field that keeps its own starts with: React's defaultValue"
      }
    },
    renamed('TextField', 'onChange', 'onChanged', {
      type: 'ValueChanged<String>?',
      description: {
        ko: '사용자가 글을 바꿀 때마다 새 글로 호출됩니다',
        en: 'Called with the text each time the reader changes it'
      }
    }),
    {
      name: 'onSubmitted',
      type: 'ValueChanged<String>?',
      description: {
        ko: '사용자가 키보드에서 제출하면 그 글로 호출됩니다',
        en: 'Called with the text when the reader submits it from the keyboard'
      }
    },
    {
      name: 'style',
      type: 'TextStyle?',
      description: {
        ko: '필드 안 글에 덮어씌우는 스타일. 높이가 하한이므로 크기보다 큰 글을 쓰면 필드가 늘어납니다. React의 classNames.control에 해당합니다',
        en: "Laid over the text inside the field. Text set larger than the size grows the field, since its height is a floor. React's classNames.control"
      }
    },
    {
      name: 'keyboardType',
      type: 'TextInputType?',
      description: {
        ko: '터치 화면이 띄울 키보드. 기본값은 글, multiline이면 여러 줄 글입니다',
        en: 'The keyboard a touch screen shows. Defaults to text, or multiline text'
      }
    },
    {
      name: 'textInputAction',
      type: 'TextInputAction?',
      description: {
        ko: '키보드의 동작 키가 보여 주고 하는 일',
        en: "What the keyboard's action key says and does"
      }
    },
    {
      name: 'obscureText',
      type: 'bool',
      default: 'false',
      description: {
        ko: '모든 글자를 점으로 그립니다. 비밀번호용이며 React의 type="password"에 해당합니다. multiline과 함께 쓸 수 없습니다',
        en: 'Draws every character as a dot, for a password: React\'s type="password". Not with multiline'
      }
    },
    {
      name: 'autofillHints',
      type: 'Iterable<String>?',
      default: 'const <String>[]',
      description: {
        ko: '플랫폼이 채워 넣을 수 있는 값. AutofillHints.email 등이며 null이면 자동 완성에서 빠집니다',
        en: 'What the platform may fill the field with: AutofillHints.email and the rest. null keeps it out of autofill'
      }
    },
    {
      name: 'inputFormatters',
      type: 'List<TextInputFormatter>?',
      description: {
        ko: '입력되는 글에 적용하는 formatter',
        en: 'Formatters applied to the text as it is typed'
      }
    },
    {
      name: 'maxLength',
      type: 'int?',
      description: {
        ko: '필드가 받는 최대 글자 수. 화면 낭독기도 이 값과 현재 글자 수를 읽습니다',
        en: 'The most characters the field takes. A screen reader hears it, and how many there are'
      }
    },
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
