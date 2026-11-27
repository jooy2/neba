import { from, semanticLabelRow, sizeRow, WIDGET, type PropRow } from './shared';

export default {
  Form: [
    from('Form', 'onSubmit', {
      type: 'ValueChanged<Map<String, Object?>>?',
      description: {
        ko: 'submit()이 불렸을 때 모든 field가 유효해야만, 각 NebaFormField의 name을 키로 하는 값과 함께 호출됩니다',
        en: "Called when submit() finds every field valid, with each NebaFormField's value under its name"
      }
    }),
    from('Form', 'validationMode', {
      type: 'NebaFormValidationMode',
      default: 'NebaFormValidationMode.onSubmit'
    }),
    from('Form', 'errors', {
      type: 'Map<String, Object>?',
      description: {
        ko: 'field의 validator 바깥에서 온 오류(서버, 스키마)를 NebaFormField의 name으로 키를 잡아 전달합니다. String이나 한 줄에 하나씩 그려지는 List<String>입니다. 해당 field에 표시되고 그 field가 바뀌면 사라지며, 새 Map을 주면 다시 나타납니다. 제출을 막지는 않습니다',
        en: "Errors from outside the fields' validators, keyed by the name of the NebaFormField each belongs to: a String, or a List<String> drawn one message to a line. Shown on that field and cleared as soon as it changes; a new map shows them again. They do not stop a submit"
      }
    }),
    sizeRow('Form'),
    from('Form', 'spacing', {
      type: 'double?',
      description: {
        ko: 'children 사이의 간격. 간격 스케일이라 5는 20 논리 픽셀입니다. size가 고르는 간격 대신 쓰이고, NebaProvider의 spacing으로 모든 Form에 한 번에 정할 수 있습니다',
        en: "The gap between the children, on the spacing scale: 5 is 20 logical pixels. Takes over from the gap size picks, and NebaProvider's spacing sets it for every Form"
      }
    }),
    semanticLabelRow,
    from('Form', 'children', { type: `List<${WIDGET}>`, default: '[]' })
  ],

  FormField: [
    {
      name: 'name',
      type: 'String',
      required: true,
      description: {
        ko: 'field를 가리키는 이름. onSubmit이 받는 값과 errors의 키가 됩니다',
        en: 'What identifies the field: the key of its value in what onSubmit is handed, and of its error in errors'
      }
    },
    {
      name: 'builder',
      type: 'Widget Function(NebaFormFieldState<T> field)',
      required: true,
      description: {
        ko: 'field를 만듭니다. 받은 상태에서 error를 가져가고, 값이 바뀔 때마다 didChange를 부르게 하세요',
        en: 'Builds the field. Take its error from the state it is handed, and have it call didChange on every change'
      }
    },
    {
      name: 'initialValue',
      type: 'T?',
      description: {
        ko: 'field가 처음 가지는 값. builder가 만드는 field도 이 값에서 시작해야 합니다',
        en: 'The value the field starts with, which the field the builder builds should start from too'
      }
    },
    {
      name: 'validator',
      type: 'FormFieldValidator<T>?',
      description: {
        ko: '값을 검사해 무엇이 잘못됐는지 말하는 문장을, 유효하면 null을 돌려줍니다. required나 이메일 형식을 대신 검사해 줄 브라우저가 없으므로 모든 규칙과 문구가 이 함수의 몫입니다',
        en: 'Checks the value: a message saying what is wrong, or null when it is valid. There is no browser to check required or an email’s shape, so every rule and its words are this function’s'
      }
    },
    {
      name: 'disabled',
      type: 'bool',
      default: 'false',
      description: {
        ko: 'field를 form에서 뺍니다. 검사하지 않고, 값에 넣지 않고, 오류도 보이지 않습니다. 비활성 Fieldset 안에 있어도 같습니다',
        en: 'Leaves the field out of the form: not checked, not in the values and showing no error. A disabled Fieldset around it does the same'
      }
    }
  ]
} satisfies Record<string, PropRow[]>;
