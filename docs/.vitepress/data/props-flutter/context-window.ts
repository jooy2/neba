import { COLOR, WIDGET, from, renamed, sizeRow, type PropRow } from './shared';

export default {
  ContextWindow: [
    from('ContextWindow', 'max', { type: 'double' }),
    from('ContextWindow', 'used', { type: 'double?' }),
    from('ContextWindow', 'tokens', { type: 'NebaContextTokens?' }),
    from('ContextWindow', 'cost', { type: 'double?' }),
    {
      name: 'formatCost',
      type: 'String Function(double cost)?',
      default: { ko: '미국 달러, 센트까지 ($0.42)', en: 'US dollars to the cent ($0.42)' },
      description: {
        ko: '비용을 씁니다. 위젯 계층에는 Intl이 없으므로 React의 currency는 여기서 호출하는 쪽의 함수입니다',
        en: "Writes the cost. The widgets layer has no Intl, so React's currency is a function of the caller's here"
      }
    },
    {
      name: 'format',
      type: 'String Function(double tokens)?',
      default: { ko: '천부터 줄여 씀 (12.4K)', en: 'compacted from a thousand up (12.4K)' },
      description: {
        ko: '토큰 수를 씁니다. 없으면 React가 영어로 쓰는 대로 천 단위부터 소수 한 자리로 줄이며, 다른 언어의 숫자는 이 함수로 씁니다',
        en: 'Writes a count. Left out, it is compacted from a thousand up with one digit after the point, as React writes it in English; another language’s numbers are this function'
      }
    },
    from('ContextWindow', 'thresholds', { type: 'List<NebaThreshold>?' }),
    from('ContextWindow', 'label', { type: `${WIDGET}?` }),
    from('ContextWindow', 'breakdown', { type: 'bool' }),
    sizeRow('ContextWindow'),
    from('ContextWindow', 'color', { type: `${COLOR}?`, default: 'NebaColor.primary' }),
    from('ContextWindow', 'locale', {
      type: 'Locale?',
      description: {
        ko: '게이지의 단어를 쓸 언어. 기본값은 NebaProvider의 것, 그다음 앱의 것입니다. 숫자와 돈은 format과 formatCost가 씁니다',
        en: "Which language the gauge's own words are in. Defaults to NebaProvider's, then the app's. The numbers and the money are format's and formatCost's"
      }
    }),
    from('ContextWindow', 'labels', {
      type: 'Map<String, String>?',
      description: {
        ko: '그 단어들을 직접 씁니다. 키는 React와 같은 label · input · output · reasoning · cached · cost · usage이고, usage에는 {used}와 {max}가 들어갑니다',
        en: 'Those words, written out, under the React keys: label · input · output · reasoning · cached · cost · usage, with a {used} and a {max} in usage'
      }
    }),
    renamed('ContextWindow', 'children', 'child', { type: `${WIDGET}?` })
  ],

  ContextTokens: [
    from('ContextTokens', 'input', { type: 'double?' }),
    from('ContextTokens', 'output', { type: 'double?' }),
    from('ContextTokens', 'reasoning', { type: 'double?' }),
    from('ContextTokens', 'cached', { type: 'double?' })
  ]
} satisfies Record<string, PropRow[]>;
