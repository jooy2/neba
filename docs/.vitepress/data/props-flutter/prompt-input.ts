import {
  COLOR,
  WIDGET,
  densityRow,
  elevationRow,
  focusRows,
  from,
  renamed,
  sizeRow,
  variantRow,
  type PropRow
} from './shared';

export default {
  PromptInput: [
    renamed('PromptInput', 'value', 'controller', {
      type: 'TextEditingController?',
      description: {
        ko: '입력란의 내용. 직접 다룰 때 넘기며, 보낸 뒤 비우는 것도 이 컨트롤러로 합니다',
        en: 'What is in the field, for a caller that drives it; clearing it once a message has gone is done through it too'
      }
    }),
    renamed('PromptInput', 'defaultValue', 'initialValue', { type: 'String?', default: undefined }),
    renamed('PromptInput', 'onValueChange', 'onChanged', { type: 'ValueChanged<String>?' }),
    from('PromptInput', 'onSubmit', {
      type: 'ValueChanged<String>?',
      description: {
        ko: '키나 버튼, 터치 키보드의 보내기 키로 보낼 때 그 내용과 함께 불립니다. 공백뿐인 입력란은 보내지 않으며, 보낸 뒤에도 입력란을 비우지 않습니다',
        en: "Called with the text when the field is sent, by the key, by the button or by a touch keyboard's send key. A field of only whitespace never sends, and sending does not clear the field"
      }
    }),
    from('PromptInput', 'submitting', { type: 'bool' }),
    from('PromptInput', 'onStop', { type: 'VoidCallback?' }),
    from('PromptInput', 'submitKey', {
      type: 'NebaPromptSubmitKey',
      default: 'NebaPromptSubmitKey.enter'
    }),
    from('PromptInput', 'label', {
      type: `${WIDGET}?`,
      description: {
        ko: '입력란의 이름. 보통 Text이며, 스크린 리더만 읽고 화면에는 그리지 않습니다',
        en: 'The field’s name, usually a Text, read by a screen reader and drawn for nobody'
      }
    }),
    {
      name: 'placeholder',
      type: 'String?',
      description: {
        ko: '입력란이 비어 있는 동안 보이는 글',
        en: 'What shows while the field is empty'
      }
    },
    from('PromptInput', 'minRows', { type: 'int' }),
    from('PromptInput', 'maxRows', { type: 'int' }),
    from('PromptInput', 'start', { type: `List<${WIDGET}>`, default: 'const []' }),
    from('PromptInput', 'end', { type: `List<${WIDGET}>`, default: 'const []' }),
    variantRow('PromptInput', 'NebaVariant.outline'),
    sizeRow('PromptInput'),
    from('PromptInput', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' }),
    densityRow('PromptInput'),
    elevationRow('PromptInput'),
    {
      name: 'disabled',
      type: 'bool',
      default: 'false',
      description: {
        ko: '회색으로 바뀌고 focus 순서에서 빠지며, 보내지 않습니다',
        en: 'Greyed out, out of the focus order, and never sends'
      }
    },
    {
      name: 'readOnly',
      type: 'bool',
      default: 'false',
      description: {
        ko: '글은 보이지만 입력을 받지 않으며, 보내지 않습니다',
        en: 'Shows its text but takes none, and never sends'
      }
    },
    {
      name: 'shortcuts',
      type: 'Map<ShortcutActivator, VoidCallback>?',
      description: {
        ko: '입력란이 키를 읽기 전에 먼저 처리할 키 조합. 입력란 위에 열린 멘션 목록이 Enter를 가져가는 방법이며, React의 onKeyDown에서 preventDefault하는 것에 해당합니다',
        en: "Key combinations to act on before the field reads a key itself: how a mention list open over the field takes Enter, React's preventDefault in onKeyDown"
      }
    },
    from('PromptInput', 'locale', {
      type: 'Locale?',
      description: {
        ko: '두 버튼 라벨을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것입니다',
        en: "Which language the two button labels are in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('PromptInput', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 단어들을 직접 씁니다. 키는 send · stop',
        en: 'Those words, written out, under send · stop'
      }
    }),
    ...focusRows,
    renamed('PromptInput', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
