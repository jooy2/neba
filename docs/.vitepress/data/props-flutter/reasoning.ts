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
  Reasoning: [
    from('Reasoning', 'streaming', { type: 'bool' }),
    from('Reasoning', 'duration', {
      type: 'Duration?',
      description: {
        ko: '사고에 걸린 시간. 주지 않으면 streaming이 켜진 시점부터 스스로 재고, 멈출 때 한 번 더 재서 그 값을 유지합니다',
        en: 'How long the thinking took. Left out, the panel times its own stream and measures it once more when it stops'
      }
    }),
    from('Reasoning', 'open', {
      type: 'bool?',
      description: {
        ko: '패널이 열려 있는지. 직접 제어할 때 씁니다. null이면 defaultOpen에서 시작해 상태를 스스로 관리합니다',
        en: 'Whether the panel is showing, for a controlled Reasoning. Left null, it keeps its own state, starting from defaultOpen'
      }
    }),
    from('Reasoning', 'defaultOpen', { type: 'bool' }),
    from('Reasoning', 'onOpenChange', { type: 'ValueChanged<bool>?' }),
    from('Reasoning', 'autoOpen', { type: 'bool' }),
    from('Reasoning', 'autoClose', { type: 'bool' }),
    renamed('Reasoning', 'hiddenUntilFound', 'keepMounted', {
      type: 'bool',
      description: {
        ko: '닫힌 패널의 사고 내용을 빌드된 채로 남깁니다. 끄면 닫힌 동안에는 내려놓습니다',
        en: 'Keeps the thinking built while the panel is closed. Off, a closed panel lets it go'
      }
    }),
    from('Reasoning', 'label', { type: `${WIDGET}?` }),
    from('Reasoning', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '맨 앞의 표시를 바꿉니다. 없으면 스트림이 도는 동안 도는 링입니다',
        en: 'Replaces the mark at the start, which is otherwise the turning ring while the stream runs'
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
    variantRow('Reasoning', 'NebaVariant.text'),
    sizeRow('Reasoning'),
    from('Reasoning', 'color', { type: `${COLOR}?`, default: 'NebaColor.secondary' }),
    densityRow('Reasoning'),
    elevationRow('Reasoning'),
    from('Reasoning', 'locale', {
      type: 'Locale?',
      description: {
        ko: '헤더의 문장을 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것이며, 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the header's own sentence is written in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    from('Reasoning', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 문장들을 직접 씁니다. 키는 React와 같은 thinking · thought · done이고, thought에는 {duration}이 들어갑니다',
        en: 'Those sentences, written out, under the React keys: thinking · thought · done, with a {duration} in thought'
      }
    }),
    renamed('Reasoning', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
