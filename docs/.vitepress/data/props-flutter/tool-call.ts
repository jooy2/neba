import {
  COLOR,
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
  ToolCall: [
    from('ToolCall', 'name', { type: WIDGET }),
    from('ToolCall', 'status', { type: 'NebaRunStatus', default: 'NebaRunStatus.pending' }),
    from('ToolCall', 'args', {
      type: `${WIDGET}?`,
      description: {
        ko: '도구에 넘긴 인자. 평범한 Text는 고정폭 글꼴의 서식 있는 텍스트로, 그 밖의 위젯은 그대로 그립니다',
        en: 'What the tool was called with. A plain Text is drawn as preformatted text in the monospaced face; any other widget is drawn as it is'
      }
    }),
    from('ToolCall', 'result', { type: `${WIDGET}?` }),
    from('ToolCall', 'error', { type: `${WIDGET}?` }),
    from('ToolCall', 'duration', {
      type: 'Duration?',
      description: {
        ko: '호출에 걸린 시간. 주지 않으면 running인 동안 스스로 세고, 첫 1초 동안은 아무 말도 하지 않습니다',
        en: 'How long the call took. Left out, a running call counts its own time and says nothing for the first second'
      }
    }),
    from('ToolCall', 'meta', { type: `${WIDGET}?` }),
    from('ToolCall', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '맨 앞의 표시를 바꿉니다. 없으면 status에 딸린 표시입니다',
        en: 'Replaces the mark at the start, which is otherwise the one that goes with status'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '표시를 그릴지 여부. false면 생략하며, React의 icon={false}에 해당합니다',
        en: "Whether a mark is drawn at all; false drops it, React's icon={false}"
      }
    },
    from('ToolCall', 'open', {
      type: 'bool?',
      description: {
        ko: '패널이 열려 있는지. 직접 제어할 때 씁니다. null이면 defaultOpen에서 시작해 상태를 스스로 관리합니다',
        en: 'Whether the panel is showing, for a controlled ToolCall. Left null, it keeps its own state, starting from defaultOpen'
      }
    }),
    from('ToolCall', 'defaultOpen', { type: 'bool' }),
    from('ToolCall', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    renamed('ToolCall', 'hiddenUntilFound', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '닫힌 패널의 내용을 빌드된 채로 남깁니다. 결과가 긴 호출이 많은 transcript라면 꺼서, 패널이 열릴 때만 만들게 하세요',
        en: 'Keeps what a closed panel holds built. Turn it off for a transcript of many calls with long results, so each panel is built only when it is opened'
      }
    }),
    variantRow('ToolCall', 'NebaVariant.outline'),
    sizeRow('ToolCall'),
    from('ToolCall', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' }),
    densityRow('ToolCall'),
    elevationRow('ToolCall'),
    from('ToolCall', 'locale', {
      type: 'Locale?',
      description: {
        ko: '상태와 두 제목을 말할 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the status and the two headings are said in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    from('ToolCall', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 단어들을 직접 씁니다. 키는 React와 같은 pending · running · success · error · arguments · result',
        en: 'Those words, written out, under the React keys: pending · running · success · error · arguments · result'
      }
    }),
    renamed('ToolCall', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
