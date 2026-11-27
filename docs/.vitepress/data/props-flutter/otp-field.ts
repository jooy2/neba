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
  OtpField: [
    variantRow('OtpField', 'NebaVariant.outline'),
    sizeRow('OtpField'),
    colorRow('OtpField'),
    densityRow('OtpField'),
    elevationRow('OtpField'),
    from('OtpField', 'length', {
      type: 'int',
      description: {
        ko: '코드의 자리수. 2–12로 잘립니다. 한 칸짜리는 TextField이고, 열두 칸을 넘기면 휴대폰 화면에 들어가지 않습니다',
        en: 'How many characters the code has. Clamped to 2–12: a single box is a TextField, and past twelve the row stops fitting a phone'
      }
    }),
    from('OtpField', 'charset', {
      type: 'NebaOtpCharset',
      default: 'NebaOtpCharset.numeric'
    }),
    from('OtpField', 'mask', { type: 'bool' }),
    from('OtpField', 'groupSize', { type: 'int?' }),
    from('OtpField', 'separator', { type: `${WIDGET}?`, default: "Text('–')" }),
    from('OtpField', 'value', {
      type: 'String?',
      description: {
        ko: '코드. onValueChange와 함께 주면 controlled가 되고, 주지 않으면 필드가 defaultValue에서 시작하는 자기 코드를 둡니다',
        en: 'The code, for a controlled field with onValueChange. Leave it out and the field keeps its own, starting from defaultValue'
      }
    }),
    from('OtpField', 'defaultValue', { type: 'String?' }),
    from('OtpField', 'onValueChange', { type: 'ValueChanged<String>?' }),
    from('OtpField', 'onComplete', {
      type: 'ValueChanged<String>?',
      description: {
        ko: '모든 칸이 찼을 때. 코드를 검증할 시점이며, 제출할 폼이 없는 Flutter에서는 React의 autoSubmit이 하던 일도 여기서 합니다',
        en: "Fires once every cell is filled: the moment to verify the code, and with no form to submit in Flutter, where React's autoSubmit would have submitted it"
      }
    }),
    from('OtpField', 'onValueInvalid', {
      type: 'ValueChanged<String>?',
      description: {
        ko: '입력되거나 붙여넣어진 글자에 charset이 거부하는 문자가 있었거나 칸보다 많았을 때',
        en: 'Fires when typed or pasted text held characters the charset rejects, or more than the cells hold'
      }
    }),
    from('OtpField', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '칸 위에 놓이는 필드 이름. 보통 Text이며, 누르면 caret이 첫 칸으로 가고 화면 낭독기는 이것을 필드 이름으로 읽습니다',
        en: "The field's name above the cells, usually a Text. A tap on it puts the caret in the first cell, and a screen reader hears it as the field's name"
      }
    }),
    from('OtpField', 'description', { type: `${WIDGET}?` }),
    from('OtpField', 'error', { type: `${WIDGET}?` }),
    from('OtpField', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('OtpField', 'readOnly', { type: 'bool' }),
    from('OtpField', 'disabled', { type: 'bool' }),
    semanticLabelRow,
    focusRows[0],
    renamed('OtpField', 'autoFocus', 'autofocus', { type: 'bool' })
  ]
} satisfies Record<string, PropRow[]>;
