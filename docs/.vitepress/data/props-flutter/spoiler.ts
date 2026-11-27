import {
  colorRow,
  densityRow,
  elevationRow,
  from,
  renamed,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Spoiler: [
    from('Spoiler', 'revealed', {
      type: 'bool?',
      description: {
        ko: '내용이 열려 있는지. 직접 제어할 때 씁니다. null이면 defaultRevealed에서 시작해 상태를 스스로 관리합니다',
        en: 'Whether the content is uncovered, for a controlled Spoiler. Left null, it keeps its own state, starting from defaultRevealed'
      }
    }),
    from('Spoiler', 'defaultRevealed', { type: 'bool' }),
    from('Spoiler', 'onRevealedChange', { type: 'ValueChanged<bool>?' }),
    from('Spoiler', 'locale', {
      type: 'Locale?',
      default: undefined,
      description: {
        ko: '기본 라벨과 안내 문구의 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다. 등록하지 않은 언어는 영어로 돌아갑니다',
        en: "Which language the default label and notice are written in. Defaults to NebaProvider's, then the app's; a language that was never registered falls back to English"
      }
    }),
    from('Spoiler', 'label', { type: `${WIDGET}?` }),
    from('Spoiler', 'hideLabel', { type: `${WIDGET}?` }),
    from('Spoiler', 'description', {
      type: `${WIDGET}?`,
      description: {
        ko: '버튼 위의 안내 문구. 기본값은 locale이 정합니다',
        en: 'The line above the button. Defaults to the locale’s wording'
      }
    }),
    {
      name: 'showDescription',
      type: 'bool',
      default: 'true',
      description: {
        ko: '버튼 위의 안내 문구를 쓸지 여부. false면 덮개에 아무것도 쓰지 않으며, React의 description={false}에 해당합니다',
        en: "Whether the line above the button is written at all; false leaves the cover with nothing written on it, React's description={false}"
      }
    },
    from('Spoiler', 'action', { type: `${WIDGET}?` }),
    from('Spoiler', 'reversible', { type: 'bool' }),
    from('Spoiler', 'maxHeight', {
      type: 'double?',
      description: {
        ko: '가려진 상자의 높이를 논리 픽셀로 제한합니다. 열면 풀립니다',
        en: 'Clamps the covered box to this height, in logical pixels. Revealing releases it'
      }
    }),
    from('Spoiler', 'blur', { type: 'double' }),
    from('Spoiler', 'padded', { type: 'bool' }),
    variantRow('Spoiler', 'NebaVariant.outline'),
    sizeRow('Spoiler'),
    colorRow('Spoiler'),
    densityRow('Spoiler'),
    elevationRow('Spoiler'),
    renamed('Spoiler', 'children', 'child', { type: `${WIDGET}?` })
  ]
} satisfies Record<string, PropRow[]>;
