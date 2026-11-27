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
  NumberField: [
    variantRow('NumberField', 'NebaVariant.outline'),
    sizeRow('NumberField'),
    colorRow('NumberField'),
    densityRow('NumberField'),
    elevationRow('NumberField'),
    from('NumberField', 'value', {
      type: 'double?',
      description: {
        ko: '값. onValueChange와 함께 주면 controlled가 되고, 주지 않으면 필드가 defaultValue에서 시작하는 자기 값을 둡니다. null이 비어 있음이며, controlled 필드의 값이 null이 되면 필드가 비워집니다',
        en: 'The number, for a controlled field with onValueChange. Leave it out and the field keeps its own, starting from defaultValue. null means empty, and a controlled field whose value turns null is cleared'
      }
    }),
    from('NumberField', 'defaultValue', { type: 'double?' }),
    from('NumberField', 'onValueChange', { type: 'ValueChanged<double?>?' }),
    from('NumberField', 'onValueCommitted', {
      type: 'ValueChanged<double?>?',
      description: {
        ko: '값이 자리를 잡을 때. 타이핑 후 blur, stepper를 뗄 때, 키와 휠에서는 onValueChange와 함께',
        en: 'Called when the value settles: on blur after typing, on the release of a stepper, and together with onValueChange for a key or the wheel'
      }
    }),
    from('NumberField', 'min', { type: 'double?' }),
    from('NumberField', 'max', { type: 'double?' }),
    from('NumberField', 'step', {
      type: 'double',
      description: { ko: '한 걸음의 크기', en: 'How far one step goes' }
    }),
    from('NumberField', 'largeStep', { type: 'double' }),
    from('NumberField', 'smallStep', { type: 'double' }),
    from('NumberField', 'snapOnStep', { type: 'bool' }),
    from('NumberField', 'wheel', { type: 'bool' }),
    from('NumberField', 'format', {
      type: 'String Function(double value)?',
      description: {
        ko: '값을 글자로 쓰는 함수. 통화, 단위, 백분율을 앱이 쓰는 formatter와 언어로 쓰며, 필드는 그 글을 보여 주고 값으로는 숫자를 보고합니다. 없으면 점과 소수 세 자리까지로 꾸밈없이 씁니다',
        en: "Writes the value as text, so a currency, a unit or a percentage is written in the app's own formatter and language while the field still reports the number. Without it the number is written plainly, with a point and at most three decimals"
      }
    }),
    {
      name: 'parse',
      type: 'double? Function(String text)?',
      description: {
        ko: '입력된 글을 숫자로 읽는 함수. 숫자가 아니면 null을 돌려줍니다. 없으면 숫자와 점 하나, 앞의 부호만 읽고 자릿수 쉼표, 통화 기호, 단위는 건너뜁니다. 소수점을 쉼표로 쓰거나 백분율을 쓰는 format에는 짝이 필요합니다',
        en: 'Reads typed text back into a number, or null for text that is not one. Without it the digits, one point and a leading sign are read, and grouping commas, currency signs and units are passed over. A format that writes a decimal comma or a percentage needs one'
      }
    },
    from('NumberField', 'steppers', {
      type: 'NebaNumberFieldSteppers',
      default: 'NebaNumberFieldSteppers.end'
    }),
    from('NumberField', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '필드의 이름. 보통 Text이며, 누르면 caret이 필드로 들어가고 화면 낭독기는 이것을 필드 이름으로 읽습니다',
        en: "The field's name, usually a Text. A tap on it puts the caret in the field, and a screen reader hears it as the field's name"
      }
    }),
    from('NumberField', 'labelPlacement', {
      type: 'NebaLabelPlacement?',
      default: 'NebaLabelPlacement.top'
    }),
    from('NumberField', 'placeholder', { type: 'String?' }),
    from('NumberField', 'description', { type: `${WIDGET}?` }),
    from('NumberField', 'error', { type: `${WIDGET}?` }),
    from('NumberField', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('NumberField', 'startIcon', { type: `${WIDGET}?` }),
    from('NumberField', 'endIcon', { type: `${WIDGET}?` }),
    from('NumberField', 'readOnly', { type: 'bool' }),
    from('NumberField', 'disabled', { type: 'bool' }),
    from('NumberField', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '주어진 너비만큼 늘어납니다. 주지 않으면 글자 스무 개쯤에 stepper를 더한 너비이고, 주어진 너비가 그보다 좁으면 거기에 맞춥니다',
        en: 'Stretches to the width it is given. Otherwise about twenty characters wide and its steppers, or the width it is given when that is less'
      }
    }),
    from('NumberField', 'shortcuts', {
      type: 'Map<ShortcutActivator, VoidCallback>?',
      description: {
        ko: '필드가 focus를 가진 동안 반응할 키 조합과 그때 할 일. 묶인 키는 소비되지만 값을 움직이는 키는 binding이 실행된 다음에도 값을 움직입니다',
        en: 'Key combinations to act on while the field holds the focus. A bound key is taken, except the keys that step, which still step after the binding has run'
      }
    }),
    {
      name: 'style',
      type: 'TextStyle?',
      description: {
        ko: '필드 안 숫자에 덮어씌우는 스타일. React의 classNames.control에 해당합니다',
        en: "Laid over the number inside the field. React's classNames.control"
      }
    },
    semanticLabelRow,
    ...focusRows
  ]
} satisfies Record<string, PropRow[]>;
