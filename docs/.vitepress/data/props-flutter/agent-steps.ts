import { COLOR, WIDGET, densityRow, from, renamed, sizeRow, type PropRow } from './shared';

export default {
  AgentSteps: [
    from('AgentSteps', 'running', {
      type: 'bool',
      description: {
        ko: '아직 남은 것이 있다는 것을, 마지막 단계 아래에 표시 하나를 더 그려 알립니다. 그 단계의 제목은 runningTitle입니다',
        en: 'That there is more to come, drawn as one more marker under the last step. Its title is runningTitle'
      }
    }),
    {
      name: 'runningTitle',
      type: `${WIDGET}?`,
      description: {
        ko: 'running일 때 덧붙는 단계의 제목. React의 running에 노드를 넘긴 것에 해당하며, 없으면 제목 없이 상태만 읽힙니다',
        en: 'The title of the step running adds: React’s running given a node. Left out, the step has none and only its status is read'
      }
    },
    sizeRow('AgentSteps'),
    from('AgentSteps', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' }),
    densityRow('AgentSteps'),
    from('AgentSteps', 'locale', {
      type: 'Locale?',
      description: {
        ko: '단계의 상태를 읽어 줄 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language a step's status is read out in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    from('AgentSteps', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 네 단어를 직접 씁니다. 키는 pending · running · success · error',
        en: 'Those four words, written out, under pending · running · success · error'
      }
    }),
    from('AgentSteps', 'children', {
      type: `List<${WIDGET}>`,
      required: true,
      description: {
        ko: '단계들. 보통 NebaAgentStep이며, 일어난 순서대로 놓습니다',
        en: 'The steps, usually NebaAgentSteps, in the order they happened'
      }
    })
  ],

  AgentStep: [
    from('AgentStep', 'title', { type: `${WIDGET}?` }),
    from('AgentStep', 'status', { type: 'NebaRunStatus', default: 'NebaRunStatus.success' }),
    from('AgentStep', 'duration', {
      type: 'Duration?',
      description: {
        ko: '걸린 시간. 주지 않으면 running인 단계가 스스로 셉니다',
        en: 'How long it took. Left out, a running step counts its own'
      }
    }),
    from('AgentStep', 'meta', { type: `${WIDGET}?` }),
    from('AgentStep', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: 'status의 표시를 바꿉니다. 상태는 그대로 읽힙니다',
        en: 'Replaces the status mark. The status is still read out'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '표시를 그릴지 여부. false면 빈 원만 남으며, React의 icon={false}에 해당합니다',
        en: "Whether a mark is drawn at all; false leaves the circle empty, React's icon={false}"
      }
    },
    from('AgentStep', 'color', { type: `${COLOR}?` }),
    renamed('AgentStep', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
