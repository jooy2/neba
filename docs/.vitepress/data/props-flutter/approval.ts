import {
  COLOR,
  VARIANT,
  WIDGET,
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  type PropRow
} from './shared';

export default {
  Approval: [
    from('Approval', 'options', { type: 'List<NebaApprovalOption>' }),
    from('Approval', 'title', { type: `${WIDGET}?` }),
    from('Approval', 'description', { type: `${WIDGET}?` }),
    from('Approval', 'details', {
      type: `${WIDGET}?`,
      description: {
        ko: '에이전트가 하려는 일. 평범한 Text는 서식 있는 텍스트로, 그 밖의 위젯은 그대로 그리므로 인자를 고칠 수 있는 폼이 들어가는 자리가 됩니다',
        en: 'What the agent is asking to do. A plain Text is drawn as preformatted text; any other widget is drawn as it is, which is where an editable form of the arguments goes'
      }
    }),
    from('Approval', 'risk', { type: 'NebaApprovalRisk?' }),
    from('Approval', 'decision', {
      type: 'String?',
      description: {
        ko: '고른 option의 value. 값이 있으면 늘 그 답을 보여 주고, null이면 버튼을 보여 주며 controlled가 아닐 때는 눌린 버튼을 기억합니다',
        en: 'Which option was taken. A value always shows that answer; null shows the buttons, and the card then remembers the one pressed unless controlled'
      }
    }),
    {
      name: 'controlled',
      type: 'bool',
      default: 'false',
      description: {
        ko: 'null까지 포함해 decision을 그대로 따를지. 호출한 쪽이 답을 넘길 때까지 버튼을 보여 주며, React의 decision={null}에 해당합니다',
        en: "Whether decision is the whole truth, null included: the buttons stay until the caller hands an answer over, React's decision={null}"
      }
    },
    from('Approval', 'onDecide', { type: 'ValueChanged<String>?' }),
    from('Approval', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '맨 앞의 글리프를 바꿉니다. 없으면 색 계열의 severity 표시입니다',
        en: "Replaces the glyph at the start, which is otherwise the family's severity mark"
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '글리프를 그릴지 여부. false면 생략하며, React의 icon={false}에 해당합니다',
        en: "Whether a glyph is drawn at all; false drops it, React's icon={false}"
      }
    },
    from('Approval', 'disabled', { type: 'bool' }),
    variantRow('Approval', 'NebaVariant.outline'),
    sizeRow('Approval'),
    from('Approval', 'color', { type: `${COLOR}?`, default: 'NebaColor.warning' }),
    densityRow('Approval'),
    elevationRow('Approval'),
    from('Approval', 'locale', {
      type: 'Locale?',
      description: {
        ko: '기본 제목, 답 줄, 위험 칩을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the default heading, the record line and the risk chip are written in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    from('Approval', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 단어들을 직접 씁니다. 키는 React와 같은 request · answered · low · medium · high',
        en: 'Those words, written out, under the React keys: request · answered · low · medium · high'
      }
    }),
    renamed('Approval', 'children', 'child', { type: `${WIDGET}?` })
  ],

  ApprovalOption: [
    from('ApprovalOption', 'value', { type: 'String' }),
    from('ApprovalOption', 'label', { type: WIDGET }),
    from('ApprovalOption', 'description', { type: `${WIDGET}?` }),
    from('ApprovalOption', 'color', { type: `${COLOR}?` }),
    from('ApprovalOption', 'variant', { type: `${VARIANT}?`, default: 'NebaVariant.outline' }),
    from('ApprovalOption', 'icon', { type: `${WIDGET}?` }),
    from('ApprovalOption', 'disabled', { type: 'bool' })
  ]
} satisfies Record<string, PropRow[]>;
